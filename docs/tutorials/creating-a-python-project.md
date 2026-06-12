# Creating a Python Project with BrainXio CI/CD

This tutorial walks you through creating a new Python project from scratch and setting up continuous integration using BrainXio's `ci-python.yml` workflow. You will build a small package, write tests, and watch CI validate everything.

## Prerequisites

- A [GitHub account](https://github.com/signup)
- `uv` installed locally (`curl -LsSf https://astral.sh/uv/install.sh | sh`)
- Basic Python knowledge

## Step 1: Create a New Repository

Create a new repository on GitHub:

1. Go to https://github.com/new
1. Name your repository (e.g., `my-python-package`)
1. Keep it public or private as needed
1. Do **not** initialize with README, .gitignore, or license yet
1. Click **Create repository**

Clone the empty repository locally:

```bash
git clone git@github.com:your-username/my-python-package.git
cd my-python-package
```

## Step 2: Initialize the Project with uv

Initialize a new Python project using `uv`:

```bash
uv init --package my_package
```

This creates a basic project structure. We will customize it for our needs.

## Step 3: Set Up pyproject.toml with Hatchling

Edit `pyproject.toml` to use hatchling as the build backend:

```toml
[project]
name = "my-package"
version = "0.1.0"
description = "A sample Python package"
readme = "README.md"
requires-python = ">=3.10"
license = { text = "MIT" }
authors = [
    { name = "Your Name", email = "you@example.com" }
]
dependencies = []

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.hatch.build.targets.wheel]
packages = ["src/my_package"]

[tool.ruff]
line-length = 88
target-version = "py310"

[tool.ruff.lint]
select = ["E", "F", "W", "I"]

[tool.mypy]
python_version = "3.10"
strict = true

[tool.pytest.ini_options]
testpaths = ["tests"]
```

## Step 4: Create the Package Structure

Create the source directory and package:

```bash
mkdir -p src/my_package tests
```

Create `src/my_package/__init__.py`:

```python
"""My Package - A sample Python package."""

__version__ = "0.1.0"


def greet(name: str) -> str:
    """Return a greeting message.

    Args:
        name: The name to greet.

    Returns:
        A greeting string.
    """
    return f"Hello, {name}!"


def add(a: int, b: int) -> int:
    """Add two integers.

    Args:
        a: First integer.
        b: Second integer.

    Returns:
        The sum of a and b.
    """
    return a + b
```

Create `src/my_package/calculator.py`:

```python
"""Calculator module."""


def multiply(a: int, b: int) -> int:
    """Multiply two integers."""
    return a * b


def divide(a: float, b: float) -> float:
    """Divide a by b.

    Raises:
        ValueError: If b is zero.
    """
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b
```

## Step 5: Write Tests

Create `tests/__init__.py` (empty file to make tests a package).

Create `tests/test_package.py`:

```python
"""Tests for my_package."""

import pytest
from my_package import greet, add
from my_package.calculator import multiply, divide


class TestGreet:
    """Tests for the greet function."""

    def test_greet_returns_string(self) -> None:
        """greet should return a string."""
        result = greet("World")
        assert isinstance(result, str)

    def test_greet_includes_name(self) -> None:
        """greet should include the provided name."""
        result = greet("Alice")
        assert "Alice" in result
        assert result == "Hello, Alice!"


class TestAdd:
    """Tests for the add function."""

    def test_add_positive_numbers(self) -> None:
        """add should work with positive numbers."""
        assert add(2, 3) == 5

    def test_add_negative_numbers(self) -> None:
        """add should work with negative numbers."""
        assert add(-1, -1) == -2

    def test_add_mixed_numbers(self) -> None:
        """add should work with mixed positive and negative."""
        assert add(-1, 1) == 0


class TestMultiply:
    """Tests for the multiply function."""

    def test_multiply_positive_numbers(self) -> None:
        """multiply should work with positive numbers."""
        assert multiply(3, 4) == 12


class TestDivide:
    """Tests for the divide function."""

    def test_divide_returns_float(self) -> None:
        """divide should return a float."""
        result = divide(10, 2)
        assert isinstance(result, float)
        assert result == 5.0

    def test_divide_by_zero_raises(self) -> None:
        """divide should raise ValueError when dividing by zero."""
        with pytest.raises(ValueError, match="Cannot divide by zero"):
            divide(10, 0)
```

## Step 6: Verify Locally

Before pushing, verify everything works locally:

```bash
# Sync dependencies
uv sync

# Run linter
uv run ruff check src/ tests/

# Run formatter check
uv run ruff format --check src/ tests/

# Run type checker
uv run mypy src/

# Run tests with coverage
uv run pytest --cov --cov-fail-under=80
```

All commands should pass. Fix any issues before proceeding.

## Step 7: Create the CI Workflow

Create `.github/workflows/ci.yml`:

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
      python-version: "3.10"
      src-path: src
      test-path: tests
      coverage-fail-under: 80
```

## Step 8: Commit and Push

Initialize git and push:

```bash
git add .
git commit -m "feat: initial Python package with CI"
git push -u origin main
```

## Step 9: Watch CI Pass

Navigate to your repository on GitHub and click the **Actions** tab. You will see the CI workflow running.

Watch as each job completes:

1. **Lint and Format** — Validates code style
1. **Type Check** — Runs mypy in strict mode
1. **Test and Coverage** — Runs pytest with coverage threshold
1. **Build Verify** — Builds the wheel to ensure packaging works

When all jobs show green checkmarks, your CI is working correctly.

## Step 10: Add the Publish Workflow

Now set up automatic publishing to PyPI.

### Create a PyPI Account

1. Go to https://pypi.org/account/register/
1. Create an account
1. Create an API token at https://pypi.org/manage/account/token/
1. Copy the token

### Add the Token to GitHub Secrets

1. Go to your repository **Settings** > **Secrets and variables** > **Actions**
1. Click **New repository secret**
1. Name: `PYPI_TOKEN`
1. Value: Paste your PyPI token
1. Click **Add secret**

### Create the Publish Workflow

Create `.github/workflows/publish.yml`:

```yaml
name: Publish

on:
  release:
    types: [published]

jobs:
  publish:
    uses: brainxio/cicd/.github/workflows/publish-pypa.yml@v1
    secrets:
      PYPI_TOKEN: ${{ secrets.PYPI_TOKEN }}
```

This workflow triggers when you publish a GitHub release. It builds your package and uploads it to PyPI.

### Publish Your First Release

1. Go to your repository **Releases**
1. Click **Create a new release**
1. Tag version: `v0.1.0`
1. Release title: `v0.1.0`
1. Click **Publish release**

The publish workflow will run automatically. Check the **Actions** tab to monitor progress.

## Summary

You have created:

- A Python package with proper structure
- Unit tests with 80% coverage threshold
- CI that validates lint, types, tests, and builds
- CD that publishes to PyPI on release

## Next Steps

- Add more features to your package
- Increase test coverage
- Configure additional CI inputs like MCP integration tests
- Set up automatic version bumping with tools like `uv version`
