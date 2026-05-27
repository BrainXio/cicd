# BrainXio Git Hooks

Canonical git hooks for all BrainXio repositories. Install as a git submodule and configure
each repo to use this directory.

## Usage

```bash
git config core.hooksPath ../.githooks
```

This path is relative to each submodule in `gitmodules/` and resolves to this directory.

## Hooks

### `pre-commit`

Runs on every `git commit`:

1. **Standards guard** — blocks manifesto content, phantom repo links, disallowed email domains, AI attribution (README.md, CONTRIBUTING.md, SECURITY.md only)
1. **Universal checks** — mdformat with plugins, yamllint, JSON validation
1. **Attribution guard** — blocks AI attribution patterns in all staged docs and scripts
1. **Claude standards guard** — delegates to `claude-standards-guard` via uvx for broader standards enforcement
1. **Language-specific** — Python (ruff), Rust (cargo fmt/clippy), Go (go fmt/vet), JS/TS (eslint/prettier), Shell (shellcheck)

### `commit-msg`

Blocks AI attribution patterns in commit messages.
