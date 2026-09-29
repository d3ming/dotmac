# Local LLM evaluation

A basic [Promptfoo](https://www.promptfoo.dev/) harness for local Ollama models.
It records bounded workflow behavior, not autonomous-agent or coding quality.
Nothing here changes Pi, OpenCode, Hermes, macOS preferences, or services.

## What it tests

- `promptfooconfig.yaml`: six small tasks covering extraction, routing,
  grounded answers, missing evidence, embedded instructions, and code reasoning.
  JSON must be valid and exactly match the expected fields/values. Key order and
  whitespace do not matter; markdown fences and extra fields fail.
- `tools.yaml`: one native `repo_status` call with a checked argument. No tool
  implementation, command execution, or agent loop is involved. A JSON text
  imitation of a native call fails.
- `assertion-checks.yaml`: thirteen prerecorded positive/negative checks for
  the grading rules. `providerOutput` skips inference; these run offline.

Four candidate tags are configured: `gemma4:e4b`, `gemma4:12b`,
`gemma4:e4b-mlx`, and `qwen3.5:4b-mlx`. These are candidates, not a recommended
install list. The harness never pulls models or starts Ollama. Use provider
filters to test only installed tags. Missing tags are errors, not quality scores.

Calls are serial, at 8K context / 2048 output tokens, temperature 0, seed 42,
and thinking disabled. Models unload after every request (`keep_alive: 0`).
**Latency includes loading; this is not a warm-throughput benchmark.** Update
both live configs together when changing these shared runtime settings.

No grammar-constrained `format` is requested: JSON tests measure prompt-following
and content. They do not establish MLX structured-output compatibility. Tool
schemas belong in `provider.config.tools`; the tested Ollama provider does not
forward `test.options.tools` to the API.

## Prerequisites

Inspect the installed tools and the loopback-only Ollama service first:

```sh
command -v promptfoo ollama
curl --noproxy '*' --max-time 5 http://127.0.0.1:11434/api/version
ollama list
ollama ps
```

If Promptfoo is absent, review its [installation docs][install] and Homebrew
package/dependencies before an authorized installation:

```sh
brew info promptfoo
brew deps --tree promptfoo
# Only after installation is authorized:
HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 brew install promptfoo
```

Homebrew may install or update required dependencies, including its Node runtime.
Do not run broad upgrades or cleanup. The initial harness was tested with
Promptfoo 0.123.1 and Ollama 0.34.4; newer releases need revalidation. Homebrew's
Promptfoo uses its own Node executable without changing the shell's Node choice.

## Start a local-only evaluation session

Run commands **from this directory**: Promptfoo's JSON references depend on the
working directory. From any shell, start with:

```sh
cd "$HOME/projects/dotmac/evals/local-llm"
repo_root=$(git rev-parse --show-toplevel)
results="$repo_root/.agent-local/llm"
mkdir -p "$results"

export PROMPTFOO_DISABLE_TELEMETRY=1
export PROMPTFOO_DISABLE_UPDATE=1
export PROMPTFOO_DISABLE_SHARING=1
export PROMPTFOO_DISABLE_REMOTE_GENERATION=1
export PROMPTFOO_CONFIG_DIR="$results/promptfoo"
export PROMPTFOO_LOG_DIR="$results/logs"
export OLLAMA_BASE_URL=http://127.0.0.1:11434
export NO_PROXY="127.0.0.1,localhost${NO_PROXY:+,$NO_PROXY}"
promptfoo --version
```

The configs also fix the Ollama URL to loopback, suppress API credentials, and
set a 120-second request timeout. There are no model graders, cloud providers,
remote test files, or share links. These controls are not an OS network sandbox.
Do not use cloud/login/share, generated tests, or prompt suggestions for this
suite. Installation and documentation lookup still require network access.

Storage, logs, and exported results stay under ignored `.agent-local/llm/`;
Git ignore is not encryption. Keep real private inputs out of tracked configs.
The examples here are synthetic and do not inspect live repositories.

## Validate and smoke-test

After the session setup above:

```sh
for config in promptfooconfig.yaml tools.yaml assertion-checks.yaml; do
  promptfoo validate config -c "$config" || break
done
promptfoo eval -c assertion-checks.yaml --no-write --no-cache --no-share

# One small live request:
promptfoo eval -c promptfooconfig.yaml \
  --filter-providers '^gemma-e4b-gguf$' --filter-first-n 1 \
  --no-cache --no-share
ollama ps
```

The prerecorded checks should all pass. Live failures are observations: do not
relax grading just to obtain green results. In the tested CLI, exit 100 means
assertion failures; inspect the report for quality failures versus API errors.

## Compare candidates

```sh
run=$(date '+%Y%m%d-%H%M%S')
promptfoo eval -c promptfooconfig.yaml --repeat 2 \
  --no-cache --no-share --max-concurrency 1 \
  -o "$results/$run-workflows.json" "$results/$run-workflows.html"
promptfoo eval -c tools.yaml --repeat 2 \
  --no-cache --no-share --max-concurrency 1 \
  -o "$results/$run-tools.json" "$results/$run-tools.html"
ollama ps
```

To narrow a comparison, add `--filter-providers '^qwen-4b-mlx$'` or
`--filter-providers 'gguf$'` to either eval command. For a workflow slice, use
`--filter-metadata workflow=extraction` on the text suite.

Open the exported HTML directly for a static report; no viewer service is
started. Do not share results. After interruption or a timeout, inspect
`ollama ps`; if a tested model is still resident, unload that specific tag with
`ollama stop TAG`. Do not stop the service or other users' work incidentally.

## Interpret results and choose the next experiment

Record locally: config revision/hash, model digest/format/quantization when
reported, runtime/API/harness versions, context and decoding settings, task
results, failures, interventions, elapsed time, and memory when measured.
Different model artifacts/quantizations make this an end-to-end comparison,
not proof that one runtime is superior. Repeats at a fixed seed check stability;
they are not independent samples or evidence of reliability on new inputs.

Keep these decisions separate:

1. **Short workflow helpers:** try extraction, note triage, routing, or grounded
   questions with deterministic validation and a human fallback. Cloud fallback
   needs separate authorization/privacy review; do not forward private inputs.
2. **Coding assistance:** use a disposable fixture/repository task with actual
   patch-and-test checks before adopting a model. Code comprehension here does
   not establish coding capability; tool-call success is not agent competence.
3. **Automation authority:** keep models advisory. Do not let a classifier or
   extracted command bypass approval for installs, deletion, accounts, security,
   or system changes. Test embedded-instruction handling before accepting
   untrusted documents.

Useful next pilots include turning sanitized handoffs into draft action lists,
triaging notes into known projects, proposing commit/test summaries, or answering
questions over a small supplied documentation excerpt. Pick one workflow with
an observable success criterion before choosing a permanent default model.

[install]: https://www.promptfoo.dev/docs/installation/

## References

- [Ollama provider](https://www.promptfoo.dev/docs/providers/ollama/)
- [CLI and filtering](https://www.promptfoo.dev/docs/usage/command-line/)
- [Configuration](https://www.promptfoo.dev/docs/configuration/reference/)
- [Deterministic assertions][assertions]
- [Telemetry and update controls][telemetry]

[assertions]: https://www.promptfoo.dev/docs/configuration/expected-outputs/deterministic/
[telemetry]: https://www.promptfoo.dev/docs/configuration/telemetry/
