# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Makefile for git hooks setup
- `ci-templates` reusable workflow for template repositories
- Standardized githook scripts for template repositories
- Enhanced pre-push hook with standalone jinja template support

### Changed
- Improved workflow validation and hook patterns
- Updated workflow-inputs.md for new yamllint-config input

### Fixed
- Handle unbound GITHUB_EVENT_BEFORE in commit message check
- Use valid trufflehog version tag v3.95.5
- Prevent commit-msg false positive on word 'assistant'

### Documentation
- Added restrictive gitignore and README docs reference
- Added Diataxis framework documentation

## [1.0.5] - 2026-06-13

### Added
- Standardized githook scripts for template repositories
- `ci-templates` reusable workflow for template repositories
- Enhanced pre-push hook with standalone jinja template support

### Changed
- Improved workflow validation and hook patterns

### Fixed
- Handle unbound GITHUB_EVENT_BEFORE in commit message check
- Use valid trufflehog version tag v3.95.5

### Documentation
- Added restrictive gitignore and README docs reference
- Added Diataxis framework documentation

## [1.0.4] - 2026-06-12

### Fixed
- Audit and harden all reusable CI workflows
- Command injection, path traversal, and MCP env var sanitization
- Correct cargo binary name, starter-checks grep target, doc-quality test inputs
- Remove unused pypa secret
- Add --with build to synthetic pypa publish test
- Remove premature trap cleanup that deleted temp dirs before subsequent steps
- Replace uv pip install --system with uv run --with for externally managed python
- Use duplicate keys in bad.yml to trigger yamllint error exit code
- Use mdformat-detectable content in test-doc-quality-synthetic
- Add PYPI_TOKEN and TEST_PYPI_TOKEN secrets to publish-pypa workflow

### Changed
- Update action versions to semantic tags and bump runtime defaults

### CI
- Add needs chains, composite actions, and expanded self-ci synthetic tests
- Add self-ci job for branch protection status check

## [1.0.3] - 2026-06-11

### Fixed
- Remove invalid secrets context from if expression in ci-python workflow
- Make gitleaks step conditional on secret presence
- Add uv sync step to each job in ci-python workflow
- Fix ci-python extra-deps not installed, lychee-action invalid SHA

### Added
- Githooks for quality gates
- Diffstat gate for scope creep mitigation
- Self-ci workflow for synthetic toolchain validation
- GitHub release creation to publish workflow

### Changed
- Pin trufflehog to SHA in starter-checks
- Add gitleaks detect to python ci workflow
- Remove auto-approve from dependabot-auto-merge and default major-actions to false
- Use direct tool setup in self-ci instead of common-setup

### Fixed
- Handle no-common-ancestor case for commitlint check
- Use correct upload-artifact action SHA
- Replace publish step with artifact upload
- Add id-token write permission for pypi publish job

### Style
- Format README with mdformat-frontmatter and gfm

## [1.0.2] - 2026-06-10

### Fixed
- Make doc-quality workflow work without pyproject.toml

## [1.0.1] - 2026-06-09

### Fixed
- Replace gitleaks with TruffleHog (open source, no license required)

## [1.0.0] - 2026-06-08

### Added
- Initial release of reusable CI/CD workflows
- ci-python.yml, ci-go.yml, ci-rust.yml, ci-typescript.yml
- publish-pypa.yml, publish-npm.yml, publish-cargo.yml
- starter-checks.yml, doc-quality.yml, sync-defaults.yml
- dependabot-auto-merge.yml