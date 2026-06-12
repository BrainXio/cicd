# brainxio/cicd

Reusable GitHub Actions workflows for CI/CD, quality gates, and repository automation.

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
- [Reference](docs/reference/workflow-inputs.md) — Complete input tables and API reference
- [Explanation](docs/explanation/architecture.md) — Background knowledge and design rationale

See [docs/index.md](docs/index.md) for the documentation landing page.

## Versioning

- Tags follow semantic versioning: `v1.0.0`, `v1.1.0`, etc.
- Floating `v1` tag is updated to point to the latest `v1.x.x` release.
