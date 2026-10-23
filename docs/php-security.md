# Read-only PHP exposure audit

Run the bounded local discovery from Dotmac's root:

```sh
python3 scripts/php-security-check
python3 scripts/php-security-check --json
python3 tests/test-php-security-check.py -v
```

The checker is deliberately small and read-only. It does not download, install,
update, remove, or configure software; it does not write files; and it never
executes PHP binaries or application code. It probes a bounded number of PATH
entries and checks fixed Homebrew `opt`/`Cellar` roots, common MAMP/XAMPP/Herd/
Local paths, fixed Apache configuration locations, and process **names only**.
The Homebrew CLI is only detected by path. Package metadata is read from fixed
Homebrew `INSTALL_RECEIPT.json` files; the `brew` command is never run. Apache
files are read for PHP directives only; modules are never loaded. Process
discovery uses `ps -axo comm=` rather than arguments or environments, reducing
accidental disclosure. `--json` emits a versioned machine-readable report.

## Interpreting status

- **candidate PHP present** means at least one checked signal exists: a PHP
  binary path, Homebrew PHP package metadata, a PHP-named process, or an Apache
  PHP reference. It is a lead for manual review, not proof of exposure or of a
  running web service.
- **no PHP found in checked locations** means only that these bounded probes
  found no PHP signal and no known Docker visibility. It is not a guarantee
  that PHP is absent or safe.
- **unknown visibility** means at least one probe was incomplete or a Docker
  CLI/daemon was observed but containers could not be checked.

The report lists the checked candidates, PHP process names, Apache reference
categories and line numbers, relevant Homebrew metadata, and limitations. It
never prints full process arguments or environment values. The Docker CLI is
only detected by path; Docker is never contacted or started, and no containers
are inspected. Apache checks do not follow `Include` directives. Other app
locations, custom PHP builds, launchd configuration, containers, remote hosts,
web routing and live worker configuration can therefore be missed. Process
names alone do not reveal service ownership or whether a worker serves requests.

## Advisory baseline (2026-10-21 only)

As an explicitly dated baseline, the [PHP 2026 news archive](https://www.php.net/archive/2026.php)
reports CVE-2026-109618 and CVE-2026-109619 fixed in PHP **8.5.12, 8.4.27,
8.3.36, and 8.2.35**. The checker compares only versions found as Homebrew
Cellar metadata with those fixed patch levels for the matching minor lines.
It does not infer a version from a path, invoke `php -v`, inspect other package
managers, or establish the version of any executable or live worker. For other
minor lines, it reports that this baseline does not apply; it does not infer
vulnerability status. Package metadata meeting a threshold is not proof that
the active server uses that package, that all workers use it, or that workers
have restarted.

**Patching to a fixed release and restarting/redeploying every affected worker
is the fix.** Isolation and request restrictions are interim risk reduction,
not a safe or complete substitute. The cited advisory notes disabling
`session.upload_progress.enabled` and restarting workers as a mitigation for
one attack path; verify current vendor guidance and impact before applying it.
Do not use a blanket `memory_limit=-1` recommendation on Macs. No remediation is
performed by this audit.

## Test safety

Tests use temporary synthetic filesystem trees, fake subprocess results, and
mocks. They assert that neither discovered PHP paths nor Docker are invoked.
No cleanup is performed outside automatic removal of the temporary fixture
folder.
