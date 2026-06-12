# Composite Actions Reference

Complete reference of all composite actions in this repository.

## setup-python-workspace

**Path:** `.github/actions/setup-python-workspace/action.yml`

**Description:** Encapsulate common Python workspace setup with conditional uv sync.

### Inputs

| Input            | Type   | Required | Default | Description                                       |
| ---------------- | ------ | -------- | ------- | ------------------------------------------------- |
| `python-version` | string | Yes      | -       | Python version                                    |
| `extra-deps`     | string | No       | `""`    | Extra uv sync dependency groups (comma-separated) |

### Usage Example

```yaml
- uses: brainxio/actions/setup-python-workspace@v1
  with:
    python-version: "3.10"
    extra-deps: "dev,test"
```

## setup-node-workspace

**Path:** `.github/actions/setup-node-workspace/action.yml`

**Description:** Encapsulate common Node workspace setup with package manager validation.

### Inputs

| Input             | Type   | Required | Default | Description                         |
| ----------------- | ------ | -------- | ------- | ----------------------------------- |
| `node-version`    | string | Yes      | -       | Node.js version                     |
| `package-manager` | string | No       | `"npm"` | Package manager: npm, pnpm, or yarn |
| `registry-url`    | string | No       | `""`    | npm registry URL                    |
| `scope`           | string | No       | `""`    | npm scope                           |

### Usage Example

```yaml
- uses: brainxio/actions/setup-node-workspace@v1
  with:
    node-version: "22"
    package-manager: "pnpm"
    registry-url: "https://npm.pkg.github.com"
    scope: "@brainxio"
```
