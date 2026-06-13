# brainxio/cicd

Reusable GitHub Actions workflows for CI/CD, quality gates, and repository automation.

All external GitHub Actions used in these workflows are pinned to specific SHA-1 hashes for security. See [Security Model](docs/explanation/security-model.md) for details.

## Usage

Always pin to a stable release tag such as `@v1` or a full semantic version like `@v1.0.0`.

```yaml
jobs:
  lint-and-test:
    uses: brainxio/cicd/.github/workflows/ci-python.yml@v1
    with:
      python-version: "3.12"
      src-path: "src"
      test-path: "tests"
```

## Available Workflows

| Workflow                    | Purpose                                                |
| --------------------------- | ------------------------------------------------------ |
| `ci-python.yml`             | Lint, typecheck, test, and coverage for Python         |
| `ci-go.yml`                 | Format check, build, vet, and test for Go              |
| `ci-rust.yml`               | Format check, clippy, test for Rust                    |
| `ci-typescript.yml`         | Lint, typecheck, and test for TypeScript               |
| `publish-pypa.yml`          | Build and publish Python packages                      |
| `publish-npm.yml`           | Publish npm packages                                   |
| `publish-cargo.yml`         | Publish Rust crates                                    |
| `starter-checks.yml`        | Secret scan, merge conflict, commit message validation |
| `doc-quality.yml`           | Markdown formatting, YAML lint, spell check            |
| `sync-defaults.yml`         | Sync labels and defaults across repos                  |
| `self-ci.yml`               | Validate workflows and run synthetic integration tests |

## Documentation

Full documentation follows the [Diataxis](https://diataxis.fr/) framework:

- [Tutorials](docs/tutorials/getting-started.md) — Learning-oriented step-by-step guides
- [How-To Guides](docs/how-to-guides/) — Problem-oriented guides for specific tasks
  - [Maintain GitHub Actions](docs/how-to-guides/maintain-actions.md) — Update and maintain pinned actions
- [Reference](docs/reference/workflow-inputs.md) — Complete input tables and API reference
- [Explanation](docs/explanation/architecture.md) — Background knowledge and design rationale
  - [Security Model](docs/explanation/security-model.md) — Supply chain security approach

See [docs/index.md](docs/index.md) for the documentation landing page.

## Versioning

- Tags follow semantic versioning: `v1.0.0`, `v1.1.0`, etc.
- Floating `v1` tag is updated to point to the latest `v1.x.x` release.

## Security

All external GitHub Actions used in this repository are pinned to specific SHA-1 hashes to prevent supply chain attacks. This security measure ensures that workflows always execute the exact same code, even if action maintainers update version tags.

For more information about the security model and how to maintain these pinned actions, see:

- [Security Model](docs/explanation/security-model.md) - Detailed explanation of the security approach
- [Maintaining Actions](docs/how-to-guides/maintain-actions.md) - Guide for updating pinned actions
