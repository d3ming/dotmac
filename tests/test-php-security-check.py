#!/usr/bin/env python3
"""Tests for the bounded, read-only PHP discovery utility."""

import contextlib
import importlib.machinery
import importlib.util
import io
import json
import os
import tempfile
import unittest
from pathlib import Path
from unittest import mock

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "php-security-check"
SPEC = importlib.machinery.ModuleSpec("php_security_check", importlib.machinery.SourceFileLoader("php_security_check", str(SCRIPT)))
if SPEC.loader is None:
    raise RuntimeError("could not load PHP security audit script")
AUDIT = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(AUDIT)


class FakeCompletedProcess:
    def __init__(self, stdout="", returncode=0):
        self.stdout = stdout
        self.returncode = returncode


class PhpSecurityCheckTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.home = "/Users/audit-test"
        self.bin_dir = self.root / "test-bin"
        self.bin_dir.mkdir()
        self._touch("/test-bin/brew")
        self._touch("/bin/ps")
        self.env = {"HOME": self.home, "PATH": "/test-bin"}
        self.calls = []

    def _touch(self, absolute_path, content=b"placeholder\n"):
        path = self.root / absolute_path.lstrip("/")
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(content)
        return path

    def runner(self, command, **kwargs):
        self.calls.append((command, kwargs))
        # The audit must not invoke discovered PHP binaries or Docker.
        self.assertNotIn("docker", [str(part).lower() for part in command])
        self.assertFalse(any(Path(str(part)).name in AUDIT.PHP_NAMES for part in command))
        self.assertTrue(kwargs.get("timeout"))
        self.assertEqual(kwargs.get("stderr"), AUDIT.subprocess.DEVNULL)
        self.assertEqual(Path(command[0]).name, "ps")
        self.assertEqual(command[1:], ["-axo", "comm="])
        return FakeCompletedProcess("php-fpm\n/Applications/Docker.app/Contents/MacOS/com.docker.backend\n")

    def audit(self):
        return AUDIT.audit(root=str(self.root), home=self.home, env=self.env, runner=self.runner)

    def test_discovers_bounded_path_brew_apps_and_fixed_apache_references(self):
        self._touch("/opt/homebrew/Cellar/php/8.4.26/INSTALL_RECEIPT.json", b'{"source":{"versions":{"stable":"8.4.26"}}}')
        self._touch("/opt/homebrew/Cellar/php@8.5/8.5.12/INSTALL_RECEIPT.json", b'{"source":{"versions":{"stable":"8.5.12"}}}')
        php = self._touch("/test-bin/php")
        herd_php = self._touch(self.home + "/Library/Application Support/Herd/bin/php83/php")
        local_php = self._touch(self.home + "/Library/Application Support/Local/lightning-services/php-8.3/bin/darwin-arm64/php")
        self._touch("/opt/homebrew/opt/php@8.4/bin/php-fpm")
        self._touch("/Applications/MAMP/bin/php/php8.4.3/bin/php")
        self._touch("/etc/apache2/httpd.conf", b"""# commented LoadModule php_module
LoadModule php_module /opt/homebrew/opt/php/lib/httpd/modules/libphp.so
SetHandler "proxy:fcgi://127.0.0.1:9000"
AddHandler application/x-httpd-php .php
""")

        report = self.audit()

        self.assertEqual(report["status"], "candidate PHP present")
        paths = {candidate["path"] for candidate in report["candidates"]}
        self.assertIn("/test-bin/php", paths)
        self.assertIn(self.home + "/Library/Application Support/Herd/bin/php83/php", paths)
        self.assertIn(self.home + "/Library/Application Support/Local/lightning-services/php-8.3/bin/darwin-arm64/php", paths)
        self.assertIn("/opt/homebrew/opt/php@8.4/bin/php-fpm", paths)
        self.assertIn("/Applications/MAMP/bin/php/php8.4.3/bin/php", paths)
        self.assertEqual(php.read_bytes(), b"placeholder\n")
        self.assertEqual(herd_php.read_bytes(), b"placeholder\n")
        self.assertEqual(local_php.read_bytes(), b"placeholder\n")
        self.assertEqual(report["apache_configuration"]["references"][0]["matching_line_numbers_by_category"], {
            "fastcgi_php": [3], "mod_php": [2], "php_handler": [4]
        })
        self.assertEqual(report["processes"]["php_process_names"], ["php-fpm"])
        self.assertEqual(report["docker"]["daemon_process_names"], ["com.docker.backend"])
        self.assertEqual(report["docker"]["container_inventory"], "not queried; Docker is never started or contacted")
        self.assertEqual(report["homebrew"]["packages"], [
            {"formula": "php", "package_metadata_versions": ["8.4.26"], "advisory_baseline": [
                {"version": "8.4.26", "assessment": "below_baseline"}
            ]},
            {"formula": "php@8.5", "package_metadata_versions": ["8.5.12"], "advisory_baseline": [
                {"version": "8.5.12", "assessment": "at_or_above_baseline"}
            ]},
        ])
        self.assertEqual(len(self.calls), 1)

    def test_no_php_indicators_reports_checked_locations_not_safe(self):
        self._touch("/etc/apache2/httpd.conf", b"ServerRoot /etc/apache2\n")
        self.env["PATH"] = "/test-bin"
        self.runner = lambda command, **kwargs: FakeCompletedProcess("")

        report = self.audit()

        self.assertEqual(report["status"], "no PHP found in checked locations")
        self.assertEqual(report["summary"]["candidate_count"], 0)
        self.assertTrue(report["limitations"])

    def test_process_failure_is_unknown_and_does_not_leak_error_text(self):
        def failing_runner(command, **kwargs):
            raise OSError("sensitive /Users/private/path")

        report = AUDIT.audit(root=str(self.root), home=self.home, env=self.env, runner=failing_runner)

        self.assertEqual(report["status"], "unknown visibility")
        serialized = json.dumps(report)
        self.assertNotIn("sensitive", serialized)
        self.assertNotIn("/Users/private/path", serialized)
        self.assertTrue(report["probe_issues"])

    def test_nonzero_process_probe_is_unknown(self):
        report = AUDIT.audit(root=str(self.root), home=self.home, env=self.env,
                             runner=lambda *a, **k: FakeCompletedProcess('', 1))
        self.assertEqual(report['status'], 'unknown visibility')
        self.assertIn('process listing incomplete', report['probe_issues'])

    def test_version_threshold_boundaries(self):
        self.assertEqual(AUDIT._assess_version('8.4.26'), 'below_baseline')
        self.assertEqual(AUDIT._assess_version('8.4.27'), 'at_or_above_baseline')
        self.assertEqual(AUDIT._assess_version('8.4.27_1'), 'at_or_above_baseline')
        self.assertEqual(AUDIT._assess_version('8.1.99'), 'outside_this_baseline')
        self.assertEqual(AUDIT._assess_version('8.6.0RC1'), 'not_comparable_from_package_metadata')

    def test_truncated_config_is_unknown(self):
        self._touch('/etc/apache2/httpd.conf', b'#' * (AUDIT.MAX_CONFIG_BYTES + 1))
        self.runner = lambda *a, **k: FakeCompletedProcess('')
        self.assertEqual(self.audit()['status'], 'unknown visibility')

    def test_json_cli_emits_machine_readable_report(self):
        sample = {"schema_version": 1, "status": "candidate PHP present"}
        stdout = io.StringIO()
        with mock.patch.object(AUDIT, "audit", return_value=sample), contextlib.redirect_stdout(stdout):
            code = AUDIT.main(["--json"])
        self.assertEqual(code, 0)
        self.assertEqual(json.loads(stdout.getvalue()), sample)

    def test_only_bounded_safe_commands_are_requested(self):
        self._touch("/test-bin/php-cgi")
        report = self.audit()

        brew_call = next(command for command, _ in self.calls if Path(command[0]).name == "ps")
        self.assertEqual(brew_call[1:], ["-axo", "comm="])
        self.assertEqual(len(self.calls), 1)
        self.assertEqual(report["summary"]["docker_cli_present"], False)


if __name__ == "__main__":
    unittest.main()
