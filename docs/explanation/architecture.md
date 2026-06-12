# Architecture

This document explains the design principles and mechanisms behind the `brainxio/cicd` reusable workflows.

## Why Reusable Workflows Exist

### The DRY Principle Across Repositories

Before reusable workflows, each repository maintained its own CI/CD logic. This created several problems:

- **Inconsistency**: Different repos used different linting rules, test configurations, and deployment steps
- **Maintenance burden**: Fixing a bug or adding a feature required changes across dozens of repositories
- **Knowledge duplication**: Each repo owner needed to understand GitHub Actions internals

Reusable workflows solve this through the **Don't Repeat Yourself (DRY)** principle:

```yaml
# Consumer repo: single line to inherit full CI pipeline
jobs:
  ci:
    uses: brainxio/cicd/.github/workflows/ci-python.yml@v1
    with:
      python-version: "3.12"
```

The workflow definition lives in one place. Updates propagate to all consumers when they bump the version tag. This centralization enables:

- **Standardization**: All repos follow the same quality gates
- **Rapid iteration**: Improvements benefit all consumers immediately
- **Reduced cognitive load**: Repo owners specify what they need, not how it works

## How the Workflow Calling Mechanism Works

### The `uses:` Syntax

GitHub Actions provides the `workflow_call` trigger that enables one workflow to invoke another:

```yaml
# In brainxio/cicd/.github/workflows/ci-python.yml
on:
  workflow_call:
    inputs:
      python-version:
        type: string
        default: "3.10"
```

Consumers invoke via the `uses:` key:

```yaml
# In consumer repo
jobs:
  lint-and-test:
    uses: brainxio/cicd/.github/workflows/ci-python.yml@v1
    with:
      python-version: "3.12"
```

### Version Resolution

The `@v1` suffix is a **floating tag** that points to the latest `v1.x.x` semantic version release. GitHub resolves this at workflow queue time:

1. Consumer specifies `@v1`
1. GitHub resolves `v1` → `v1.2.3` (current latest)
1. Workflow runs pinned to that specific commit
1. Next run may resolve to `v1.2.4` if updated

This design balances **stability** (semantic versioning) with **convenience** (floating major version tag).

### Input and Secret Contracts

Reusable workflows define explicit contracts:

```yaml
inputs:
  python-version:
    type: string
    default: "3.10"
  coverage-fail-under:
    type: number
    default: 80

secrets:
  PYPI_TOKEN:
    required: false
```

Inputs flow through the `with:` block. Secrets flow through the `secrets:` block. This separation ensures sensitive values never appear in logs or workflow definitions.

## Job Dependency Chains and Fail-Fast

### Sequential Dependencies

The Python CI workflow defines a strict execution order:

```
lint → typecheck → test → build-verify
                ↘
                 mcp-integration (optional)
```

Expressed in YAML:

```yaml
jobs:
  lint:
    # runs first

  typecheck:
    needs: lint  # waits for lint

  test:
    needs: [lint, typecheck]  # waits for both

  build-verify:
    needs: test  # waits for test
```

### Why Fail-Fast Matters

This dependency chain implements **fail-fast** behavior:

1. If `lint` fails (formatting issues, secrets detected), `typecheck` never runs
1. If `typecheck` fails (type errors), `test` never runs
1. If `test` fails (assertions fail), `build-verify` never runs

Benefits:

- **Resource efficiency**: No point running expensive tests if code doesn't compile
- **Faster feedback**: Developers learn about lint issues in seconds, not minutes
- **Clear signal**: The first failing job is the one to fix

The `mcp-integration` job is conditional (`if: inputs.run-mcp-integration`) and only runs when explicitly requested. This keeps the common case fast while enabling deeper validation when needed.

## Composite Actions

### What They Are

Composite actions bundle multiple steps into a single reusable unit. They live in `.github/actions/` and use `runs: using: composite`:

```yaml
# .github/actions/setup-python-workspace/action.yml
runs:
  using: composite
  steps:
    - uses: actions/checkout@v6
    - uses: brainxio/actions/common-setup@v1
    - name: Sync dependencies
      shell: bash
      run: uv sync
```

### Why They Exist

Composite actions provide **encapsulation** for common patterns:

| Action                   | Purpose                                                    |
| ------------------------ | ---------------------------------------------------------- |
| `setup-python-workspace` | Checkout, install Python via `common-setup`, run `uv sync` |
| `setup-node-workspace`   | Checkout, install Node, validate package manager           |

Benefits:

- **Reduced duplication**: Workflows reference the action instead of repeating steps
- **Consistent setup**: Every job gets identical environment preparation
- **Single point of update**: Changing the setup logic updates all consumers

### Input Validation

Composite actions can validate inputs before proceeding:

```yaml
- name: Validate package manager
  shell: bash
  env:
    PM: ${{ inputs.package-manager }}
  run: |
    case "$PM" in
      npm|pnpm|yarn) ;;
      *) echo "ERROR: unsupported package manager: $PM" >&2; exit 1 ;;
    esac
```

This fails fast with a clear message if an invalid package manager is specified.

## Self-CI Synthetic Tests

### The Problem

How do you test that your CI workflows actually work? You cannot rely on external repositories to validate changes — that creates a circular dependency.

### The Solution: Synthetic Projects

The `self-ci.yml` workflow creates **synthetic projects** in temporary directories and runs the same quality gates that consumers use:

```yaml
- name: Create synthetic Python project
  shell: bash
  run: |
    TEST_DIR=$(mktemp -d)
    mkdir -p "$TEST_DIR/src/test_pkg"
    # Create pyproject.toml, source files, tests...
```

### Test Matrix

| Synthetic Test                  | Validates                             |
| ------------------------------- | ------------------------------------- |
| `test-ci-python-synthetic`      | Python lint, typecheck, test, build   |
| `test-ci-typescript-synthetic`  | TypeScript lint, typecheck, test      |
| `test-ci-go-synthetic`          | Go fmt, vet, test, build              |
| `test-ci-rust-synthetic`        | Rust fmt, clippy, test, build         |
| `test-doc-quality-synthetic`    | Markdown formatting, YAML lint        |
| `test-starter-checks-synthetic` | Secret scan, merge conflict detection |
| `test-publish-pypa-synthetic`   | Python package build                  |
| `test-publish-npm-synthetic`    | npm package build                     |
| `test-publish-cargo-synthetic`  | Rust crate build                      |

### Why This Matters

Synthetic tests provide:

1. **Regression detection**: If a workflow change breaks the CI pipeline, self-ci catches it before merge
1. **Documentation by example**: The synthetic projects show minimal valid configurations
1. **Confidence in releases**: Each version tag is validated against real workflow execution

The `self-ci` job aggregates all synthetic test results and only passes if every validation succeeds.
