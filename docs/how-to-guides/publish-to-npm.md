# Publish an npm package

This guide shows how to publish an npm package using the CI workflow.

## Prerequisites

Before publishing:

1. Bump the version in `package.json`
1. Update `CHANGELOG.md` with release notes
1. Ensure all tests pass locally
1. Verify the package builds: `npm run build`

## Configure secrets

Add the following secret to your repository:

| Secret      | Description                               |
| ----------- | ----------------------------------------- |
| `NPM_TOKEN` | npm access token with publish permissions |

Generate a token at https://www.npmjs.com/settings/account/tokens

Token must have **Write** or **Automation** permission.

## Publish to npm

```yaml
name: Release

on:
  release:
    types: [published]

jobs:
  publish:
    uses: brainxio/brainxio-cicd/.github/workflows/publish-npm.yml@main
    with:
      node-version: '20'
      package-manager: 'npm'
      registry: 'npm'
    secrets:
      NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

## Publish to GitHub Packages

```yaml
name: Release to GitHub Packages

on:
  release:
    types: [published]

jobs:
  publish:
    uses: brainxio/brainxio-cicd/.github/workflows/publish-npm.yml@main
    with:
      node-version: '20'
      package-manager: 'npm'
      registry: 'github'
    secrets:
      NPM_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Configure package.json for GitHub Packages

Add this to your `package.json`:

```json
{
  "name": "@your-org/your-package",
  "publishConfig": {
    "registry": "https://npm.pkg.github.com"
  }
}
```

## Workflow inputs

| Input             | Default    | Description                              |
| ----------------- | ---------- | ---------------------------------------- |
| `node-version`    | `'20'`     | Node.js version to use                   |
| `package-manager` | `'npm'`    | Package manager: `npm`, `yarn`, `pnpm`   |
| `registry`        | `'npm'`    | Target registry: `npm`, `github`         |
| `access`          | `'public'` | Package access: `public` or `restricted` |

## Registry comparison

| Registry        | URL                              | Use case                  |
| --------------- | -------------------------------- | ------------------------- |
| npm             | https://www.npmjs.com            | Public packages           |
| GitHub Packages | https://github.com/orgs/packages | Private/internal packages |

## Troubleshooting

**403 Forbidden:** Verify your token has publish permissions for the package scope.

**Package name conflict:** Ensure the package name is unique or scoped to your organization.

**OTP required:** Use an automation token instead of a publish token (automation tokens don't require OTP).
