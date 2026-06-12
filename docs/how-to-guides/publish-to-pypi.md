# Publish a Python package to PyPI

This guide shows how to publish a Python package using the CI workflow.

## Prerequisites

Before publishing:

1. Bump the version in `pyproject.toml`
1. Update `CHANGELOG.md` with release notes
1. Ensure all tests pass locally
1. Verify the package builds: `uv build`

## Configure secrets

Add the following secrets to your repository:

| Secret           | Description                                |
| ---------------- | ------------------------------------------ |
| `PYPI_TOKEN`     | API token from pypi.org (for production)   |
| `TESTPYPI_TOKEN` | API token from test.pypi.org (for testing) |

Generate tokens at:

- Production: https://pypi.org/manage/account/token/
- TestPyPI: https://test.pypi.org/manage/account/token/

## Publish to PyPI (production)

```yaml
name: Release

on:
  release:
    types: [published]

jobs:
  publish:
    uses: brainxio/brainxio-cicd/.github/workflows/publish-pypa.yml@main
    with:
      repository: 'pypi'
      python-version: '3.12'
    secrets:
      PYPI_TOKEN: ${{ secrets.PYPI_TOKEN }}
```

## Publish to TestPyPI (testing)

```yaml
name: Test Release

on:
  push:
    tags:
      - 'v*'

jobs:
  publish:
    uses: brainxio/brainxio-cicd/.github/workflows/publish-pypa.yml@main
    with:
      repository: 'testpypi'
      python-version: '3.12'
    secrets:
      PYPI_TOKEN: ${{ secrets.TESTPYPI_TOKEN }}
```

## Publish to GitHub Packages

```yaml
name: Release to GitHub Packages

on:
  release:
    types: [published]

jobs:
  publish:
    uses: brainxio/brainxio-cicd/.github/workflows/publish-pypa.yml@main
    with:
      repository: 'github'
      python-version: '3.12'
    secrets:
      PYPI_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Registry comparison

| Registry        | URL                              | Use case                  |
| --------------- | -------------------------------- | ------------------------- |
| PyPI            | https://pypi.org                 | Production releases       |
| TestPyPI        | https://test.pypi.org            | Testing before production |
| GitHub Packages | https://github.com/orgs/packages | Internal/private packages |

## Workflow inputs

| Input            | Default  | Description                                   |
| ---------------- | -------- | --------------------------------------------- |
| `repository`     | `'pypi'` | Target registry: `pypi`, `testpypi`, `github` |
| `python-version` | `'3.12'` | Python version for building                   |
| `skip-existing`  | `false`  | Skip if version already exists                |

## Troubleshooting

**403 Forbidden:** Verify your API token has correct permissions.

**Version already exists:** Bump the version in `pyproject.toml`. Set `skip-existing: true` to allow re-runs.

**Build fails:** Run `uv build` locally to see detailed errors.
