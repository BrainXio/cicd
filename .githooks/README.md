# BrainXio Git Hooks

Standardized git hooks for BrainXio template repositories. These hooks ensure consistent validation across all template repos.

## Installation

Template repos can install these hooks by adding this repository as a git submodule and configuring git to use the hooks path.

### Option 1: Git Submodule (Recommended)

```bash
# Add cicd as a submodule
git submodule add git@github.com:brainxio/brainxio-cicd.git .cicd

# Configure git to use the hooks
git config core.hooksPath .cicd/.githooks
```

### Option 2: Copy Hooks Directly

```bash
# Copy hooks to your repo's .git/hooks directory
cp .cicd/.githooks/* .git/hooks/
chmod +x .git/hooks/*
```

### Option 3: Symlink (Development)

```bash
# Create symlinks to the hooks
ln -sf ../../.cicd/.githooks/commit-msg .git/hooks/
ln -sf ../../.cicd/.githooks/pre-commit .git/hooks/
ln -sf ../../.cicd/.githooks/pre-push .git/hooks/
```

## Hooks

### `commit-msg`

Validates commit messages before the commit is created.

**Checks:**
- Conventional Commits format: `type(scope): description`
- Valid types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`, `build`, `perf`
- Rejects AI attribution patterns (Co-Authored-By, AI-generated, etc.)

**Examples:**
```
feat: add user authentication
fix(auth): resolve token expiry bug
chore(deps): bump actions/checkout from 4 to 5
```

### `pre-commit`

Runs on every `git commit`. Validates staged files.

**Checks:**
- YAML files parse correctly (skips `.github/` directory)
- Jinja2 templates compile (skips `.github/` directory)
- Files with Jinja2 syntax are skipped in YAML validation (deferred to pre-push)

### `pre-push`

Runs on every `git push`. Performs comprehensive validation.

**Checks:**
- Full YAML validation for all non-`.github` YAML files
- Full Jinja2 template compilation validation
- Ensures all templates render without syntax errors

## Requirements

These hooks require:
- `uv` package manager (for Python tooling)
- `yamllint` (installed automatically via uvx)
- `jinja2` (installed automatically via uv)

## Bypassing Hooks

For emergency situations only:

```bash
# Skip pre-commit hook
git commit --no-verify -m "message"

# Skip pre-push hook  
git push --no-verify
```

**Note:** Bypassing hooks is discouraged and may be blocked by repository policies.

## Development

To test hooks locally:

```bash
# Test commit-msg hook
echo "feat: test message" | .githooks/commit-msg /dev/stdin

# Test pre-commit hook
git add . && .githooks/pre-commit

# Test pre-push hook
.githooks/pre-push
```
