# Workflow Inputs Reference

Complete reference of all inputs for reusable workflows in this repository.

## ci-python.yml

Python CI workflow inputs.

| Input                 | Type    | Default       | Description                                                                          |
| --------------------- | ------- | ------------- | ------------------------------------------------------------------------------------ |
| `python-version`      | string  | `"3.10"`      | Python version                                                                       |
| `src-path`            | string  | `"src"`       | Source directory path                                                                |
| `test-path`           | string  | `"tests"`     | Test directory path                                                                  |
| `mypy-target`         | string  | `""`          | Package for mypy (empty = auto-detect from src-path)                                 |
| `coverage-fail-under` | number  | `80`          | Minimum coverage percentage                                                          |
| `coverage-source`     | string  | `""`          | Coverage source path (empty = auto-detect from src-path)                             |
| `run-mcp-integration` | boolean | `false`       | Run MCP integration tests                                                            |
| `mcp-test-path`       | string  | `"tests/mcp"` | Path for MCP integration tests                                                       |
| `mcp-env-vars`        | string  | `""`          | Extra env vars for MCP tests (KEY=VALUE per line)                                    |
| `extra-deps`          | string  | `""`          | Extra uv sync dependency groups (comma-separated, alphanumeric/dash/underscore only) |
| `wheel-entry-points`  | string  | `""`          | Expected entry point names in wheel (space-separated, empty skips check)             |

## ci-typescript.yml

TypeScript CI workflow inputs.

| Input              | Type   | Default          | Description                           |
| ------------------ | ------ | ---------------- | ------------------------------------- |
| `node-version`     | string | `"22"`           | Node.js version                       |
| `package-manager`  | string | `"npm"`          | Package manager: npm, pnpm, or yarn   |
| `lint-script`      | string | `"lint"`         | package.json lint script name         |
| `format-script`    | string | `"format:check"` | package.json format check script name |
| `typecheck-script` | string | `"typecheck"`    | package.json typecheck script name    |
| `test-script`      | string | `"test"`         | package.json test script name         |
| `build-script`     | string | `"build"`        | package.json build script name        |

## ci-go.yml

Go CI workflow inputs.

| Input        | Type   | Default  | Description |
| ------------ | ------ | -------- | ----------- |
| `go-version` | string | `"1.24"` | Go version  |

## ci-rust.yml

Rust CI workflow inputs.

| Input                  | Type    | Default    | Description                                |
| ---------------------- | ------- | ---------- | ------------------------------------------ |
| `toolchain`            | string  | `"stable"` | Rust toolchain version                     |
| `clippy-deny-warnings` | boolean | `true`     | Treat clippy warnings as errors            |
| `run-audit`            | boolean | `false`    | Run cargo audit for vulnerability scanning |

## publish-pypa.yml

Python package publishing workflow inputs and secrets.

### Inputs

| Input            | Type   | Default                                                        | Description                                                                                                                                                                                                                  |
| ---------------- | ------ | -------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `repository-url` | string | `"https://pypi.pkg.github.com/${{ github.repository_owner }}"` | Package registry URL. Default GitHub Packages (uses GITHUB_TOKEN). For pypi.org use https://upload.pypi.org/legacy/ and provide PYPI_TOKEN. For test.pypi.org use https://test.pypi.org/legacy/ and provide TEST_PYPI_TOKEN. |

### Secrets

| Secret           | Required | Description                                                |
| ---------------- | -------- | ---------------------------------------------------------- |
| `PYPI_TOKEN`     | No       | PyPI API token. Required for pypi.org publishing.          |
| `TESTPYPI_TOKEN` | No       | TestPyPI API token. Required for test.pypi.org publishing. |

## publish-npm.yml

npm package publishing workflow inputs.

| Input             | Type   | Default                        | Description                         |
| ----------------- | ------ | ------------------------------ | ----------------------------------- |
| `registry-url`    | string | `"https://npm.pkg.github.com"` | npm registry URL                    |
| `scope`           | string | `"@brainxio"`                  | npm scope                           |
| `node-version`    | string | `"22"`                         | Node.js version                     |
| `package-manager` | string | `"npm"`                        | Package manager: npm, pnpm, or yarn |

## publish-cargo.yml

Cargo crate publishing workflow inputs.

| Input       | Type   | Default       | Description            |
| ----------- | ------ | ------------- | ---------------------- |
| `registry`  | string | `"crates-io"` | Cargo registry name    |
| `toolchain` | string | `"stable"`    | Rust toolchain version |

## doc-quality.yml

Documentation quality workflow inputs.

| Input              | Type    | Default     | Description                                     |
| ------------------ | ------- | ----------- | ----------------------------------------------- |
| `md-paths`         | string  | `"."`       | Paths/globs for mdformat (space-separated)      |
| `yaml-paths`       | string  | `".github"` | Paths for yamllint                              |
| `typos-config`     | string  | `""`        | Path to .typos.toml (empty to skip typos check) |
| `link-check-paths` | string  | `""`        | Paths for lychee link check (empty to skip)     |
| `link-check-base`  | string  | `"."`       | Base path for relative link resolution          |
| `link-check-fail`  | boolean | `false`     | Fail workflow on broken links                   |

## starter-checks.yml

Starter checks workflow inputs.

| Input                   | Type    | Default | Description                           |
| ----------------------- | ------- | ------- | ------------------------------------- |
| `check-commit-messages` | boolean | `true`  | Validate conventional commit messages |

## sync-defaults.yml

Defaults synchronization workflow inputs and secrets.

### Inputs

| Input           | Type    | Default      | Description                                                   |
| --------------- | ------- | ------------ | ------------------------------------------------------------- |
| `target-repo`   | string  | (required)   | Target repository to sync defaults to (e.g., BrainXio/myrepo) |
| `dry-run`       | boolean | `false`      | Show changes without applying                                 |
| `fail-on-drift` | boolean | `false`      | Fail if drift is detected instead of applying                 |
| `defaults-path` | string  | `"defaults"` | Path within this repo to the defaults directory               |

### Secrets

| Secret       | Required | Description                                                    |
| ------------ | -------- | -------------------------------------------------------------- |
| `SYNC_TOKEN` | Yes      | GitHub token with repo and workflow scopes for the target repo |
