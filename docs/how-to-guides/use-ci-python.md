# Use the Python CI workflow

This guide shows how to integrate the Python CI workflow into your project.

## Prerequisites

Your project must have:

- `pyproject.toml` with build system configuration
- `src/` directory layout (e.g., `src/your_package/`)
- `tests/` directory with pytest-compatible tests

## Basic setup

Create a workflow file in your repository (e.g., `.github/workflows/ci.yml`):

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  python-ci:
    uses: brainxio/brainxio-cicd/.github/workflows/ci-python.yml@main
    with:
      python-version: '3.12'
      src-path: 'src'
      test-path: 'tests'
      coverage-fail-under: 80
```

## Workflow inputs

| Input                 | Default   | Description                 |
| --------------------- | --------- | --------------------------- |
| `python-version`      | `'3.12'`  | Python version to use       |
| `src-path`            | `'src'`   | Path to source directory    |
| `test-path`           | `'tests'` | Path to test directory      |
| `coverage-fail-under` | `80`      | Minimum coverage percentage |

## Common customizations

### Add extra dependencies

```yaml
jobs:
  python-ci:
    uses: brainxio/brainxio-cicd/.github/workflows/ci-python.yml@main
    with:
      python-version: '3.12'
      extra-deps: 'pytest-cov pytest-asyncio'
```

### Enable strict type checking

```yaml
jobs:
  python-ci:
    uses: brainxio/brainxio-cicd/.github/workflows/ci-python.yml@main
    with:
      python-version: '3.12'
      mypy-target: 'src'
      mypy-strict: true
```

### Run against multiple Python versions

```yaml
jobs:
  test:
    strategy:
      matrix:
        python-version: ['3.11', '3.12', '3.13']
    uses: brainxio/brainxio-cicd/.github/workflows/ci-python.yml@main
    with:
      python-version: ${{ matrix.python-version }}
      src-path: 'src'
      test-path: 'tests'
```

## Troubleshooting

**Coverage threshold not met:** Increase test coverage or lower `coverage-fail-under` temporarily.

**Mypy errors:** Run `uvx mypy src` locally to see detailed errors before pushing.

**Missing dependencies:** Add them to `pyproject.toml` or use `extra-deps` input.
