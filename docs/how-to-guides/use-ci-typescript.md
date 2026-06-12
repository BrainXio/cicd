# Use the TypeScript CI workflow

This guide shows how to integrate the TypeScript CI workflow into your project.

## Prerequisites

Your project must have:

- `package.json` with scripts and dependencies
- `tsconfig.json` with TypeScript configuration
- Test framework configured (Jest, Vitest, etc.)

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
  typescript-ci:
    uses: brainxio/brainxio-cicd/.github/workflows/ci-typescript.yml@main
    with:
      node-version: '20'
      package-manager: 'npm'
      lint-script: 'lint'
      test-script: 'test'
      build-script: 'build'
```

## Workflow inputs

| Input             | Default   | Description                                    |
| ----------------- | --------- | ---------------------------------------------- |
| `node-version`    | `'20'`    | Node.js version to use                         |
| `package-manager` | `'npm'`   | Package manager (`npm`, `yarn`, `pnpm`, `bun`) |
| `lint-script`     | `'lint'`  | npm script for linting                         |
| `test-script`     | `'test'`  | npm script for running tests                   |
| `build-script`    | `'build'` | npm script for building                        |

## Common customizations

### Use pnpm instead of npm

```yaml
jobs:
  typescript-ci:
    uses: brainxio/brainxio-cicd/.github/workflows/ci-typescript.yml@main
    with:
      node-version: '20'
      package-manager: 'pnpm'
      lint-script: 'lint'
      test-script: 'test'
```

### Skip build step (library projects)

```yaml
jobs:
  typescript-ci:
    uses: brainxio/brainxio-cicd/.github/workflows/ci-typescript.yml@main
    with:
      node-version: '20'
      build-script: ''
```

### Run against multiple Node versions

```yaml
jobs:
  test:
    strategy:
      matrix:
        node-version: ['18', '20', '22']
    uses: brainxio/brainxio-cicd/.github/workflows/ci-typescript.yml@main
    with:
      node-version: ${{ matrix.node-version }}
      package-manager: 'npm'
      lint-script: 'lint'
      test-script: 'test'
```

### Enable coverage reporting

```yaml
jobs:
  typescript-ci:
    uses: brainxio/brainxio-cicd/.github/workflows/ci-typescript.yml@main
    with:
      node-version: '20'
      test-script: 'test:coverage'
```

## Troubleshooting

**Lock file mismatch:** Ensure your lock file (`package-lock.json`, `pnpm-lock.yaml`, etc.) is committed.

**Script not found:** Verify script names in `package.json` match the workflow inputs.

**TypeScript errors:** Run `npx tsc --noEmit` locally to check types before pushing.
