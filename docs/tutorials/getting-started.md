# Getting Started with BrainXio CI/CD

This tutorial guides you through setting up and running BrainXio CI/CD workflows for your project. By the end, you will have a working continuous integration pipeline that checks your code quality, runs tests, and verifies builds.

## Prerequisites

Before starting, ensure you have:

- A [GitHub account](https://github.com/signup)
- A GitHub repository with code you want to test
- Basic familiarity with GitHub Actions concepts (workflows, jobs, steps)

## Choosing the Right Workflow

BrainXio provides language-specific workflows. Select the one that matches your project:

| Workflow            | Use For                          |
| ------------------- | -------------------------------- |
| `ci-python.yml`     | Python packages and applications |
| `ci-rust.yml`       | Rust crates and binaries         |
| `ci-go.yml`         | Go modules and services          |
| `ci-typescript.yml` | TypeScript/JavaScript projects   |

This tutorial uses `ci-python.yml` as an example. The setup process is similar for other languages.

## Setting Up the Workflow

### Step 1: Create the Workflow File

In your repository, create a new file at `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  build:
    uses: brainxio/cicd/.github/workflows/ci-python.yml@v1
```

This configuration:

- Triggers the workflow on pushes and pull requests to main branches
- Calls the BrainXio Python CI workflow as a reusable workflow
- Uses version `v1` which tracks stable releases

### Step 2: Configure Workflow Inputs (Optional)

The Python CI workflow accepts optional inputs to customize behavior:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    uses: brainxio/cicd/.github/workflows/ci-python.yml@v1
    with:
      python-version: "3.11"
      src-path: src
      test-path: tests
      coverage-fail-under: 80
```

Available inputs for `ci-python.yml`:

| Input                 | Default   | Description                      |
| --------------------- | --------- | -------------------------------- |
| `python-version`      | `"3.10"`  | Python version to use            |
| `src-path`            | `"src"`   | Path to source code directory    |
| `test-path`           | `"tests"` | Path to test directory           |
| `coverage-fail-under` | `80`      | Minimum test coverage percentage |
| `mypy-target`         | (auto)    | Package for type checking        |
| `run-mcp-integration` | `false`   | Enable MCP integration tests     |

## Running the Workflow

### Step 1: Commit and Push

Commit your workflow file and push to GitHub:

```bash
git add .github/workflows/ci.yml
git commit -m "feat: add CI workflow"
git push
```

### Step 2: Watch CI Execution

Navigate to the **Actions** tab in your GitHub repository. You will see the CI workflow running:

1. Click on the workflow run (usually titled "CI")
1. Watch as each job executes:
   - **Lint and Format** — Checks code style with ruff
   - **Type Check** — Runs mypy for type validation
   - **Test and Coverage** — Executes pytest with coverage reporting
   - **Build Verify** — Builds the package to verify it compiles

Jobs run sequentially. A green checkmark indicates success. A red X indicates failure.

## Interpreting Results

### Successful Run

A successful run shows all jobs with green checkmarks:

```
✓ Lint and Format
✓ Type Check
✓ Test and Coverage
✓ Build Verify
```

Your code passes all quality gates. You can safely merge pull requests or deploy.

### Failed Run

When a job fails, click on it to see the error output. Common failures:

**Lint Failure**

```
E: Missing trailing comma
W: Unused import 'os'
```

Fix by running ruff locally:

```bash
uv run ruff check --fix
uv run ruff format
```

**Type Check Failure**

```
error: Argument 1 has incompatible type "str"; expected "int"
```

Fix by correcting the type mismatch in your code.

**Test Failure**

```
FAILED tests/test_app.py::test_login - AssertionError: expected 200, got 401
```

Fix by correcting the failing test or the code under test.

**Coverage Below Threshold**

```
FAIL Required coverage is 80% but only 65% covered
```

Fix by writing additional tests for uncovered code paths.

## Next Steps

After your CI workflow passes consistently:

1. **Add publishing** — Set up `publish-pypa.yml` for Python packages
1. **Enable MCP integration tests** — Set `run-mcp-integration: true` if your project has MCP servers
1. **Customize thresholds** — Adjust `coverage-fail-under` based on project needs
1. **Add more languages** — Include additional workflows for polyglot projects

## Troubleshooting

**Workflow not found error**

Ensure you reference the workflow correctly:

```yaml
uses: brainxio/cicd/.github/workflows/ci-python.yml@v1
```

**Permission denied errors**

The workflow runs with `contents: read` by default. If you need to publish artifacts, ensure your repository allows workflow permissions.

**Dependency installation fails**

Ensure your project has a `pyproject.toml` file. The workflow runs `uv sync` to install dependencies.
