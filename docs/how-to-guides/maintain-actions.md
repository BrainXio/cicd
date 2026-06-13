# Maintain GitHub Actions

This guide explains how to maintain and update the external GitHub Actions used in this repository's workflows.

## Overview

All external GitHub Actions in this repository are pinned to specific SHA-1 hashes for security. This ensures that workflows always use the exact same code, preventing supply chain attacks that could occur if version tags were updated maliciously.

However, this security approach requires regular maintenance to keep actions up-to-date with bug fixes, security patches, and new features.

## Action Registry

All external actions are tracked in a centralized registry that maps version tags to their corresponding SHA-1 hashes. This registry is the single source of truth for approved actions and their verified versions.

### Current External Actions

The following external actions are currently pinned in this repository:

1. `actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02` (was v4)
2. `trufflesecurity/trufflehog@d411fff7b8879a62509f3fa98c07f247ac089a51` (was v3.95.5)
3. `gitleaks/gitleaks-action@e0c47f4f8be36e29cdc102c57e68cb5cbf0e8d1e` (was v3)
4. `actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10` (was v6)
5. `dtolnay/rust-toolchain@29eef336d9b2848a0b548edc03f92a220660cdb8` (was stable)
6. `lycheeverse/lychee-action@8646ba30535128ac92d33dfc9133794bfdd9b411` (was v2)
7. `crate-ci/typos@d80b8e26878e372a041833cd67163dbdb6a4336e` (was v1)
8. `softprops/action-gh-release@3bb12739c298aeb8a4eeaf626c5b8d85266b0e65` (was v2)
9. `actions/setup-go@4a3601121dd01d1626a1e23e37211e3254c1c06c` (was v6)
10. `wagoid/commitlint-github-action@f133a0d95090ef2609192b4a21f54e20af819ea9` (was v6)
11. `actions/setup-node@a0853c24544627f65ddf259abe73b1d18a591444` (was v5)
12. `rustsec/audit-check@69366f33c96575abad1ee0dba8212993eecbe998` (was v2)
13. `astral-sh/setup-uv@94527f2e458b27549849d47d273a16bec83a01e9` (was v7)

## Automated Update Workflow

This repository includes an automated workflow that periodically checks for updates to pinned actions and creates pull requests with updated hashes when new versions are available.

### How It Works

1. The workflow runs on a schedule (typically weekly)
2. It checks each pinned action for newer commits/releases
3. For actions with updates, it creates a pull request with:
   - Updated SHA-1 hash in workflow files
   - Updated registry entry
   - Changelog of changes between versions

### Triggering Manual Updates

You can manually trigger the update workflow:

```bash
gh workflow run "update-actions" --repo brainxio/cicd
```

## Manual Update Process

If you need to manually update an action, follow these steps:

### 1. Find the New SHA-1 Hash

Navigate to the action's GitHub repository and find the commit hash for the desired version:

```bash
# Example for actions/checkout@v4
git ls-remote https://github.com/actions/checkout refs/tags/v4
```

Or browse to the repository and click on the tag to see the commit hash.

### 2. Update Workflow Files

Replace the old SHA-1 hash with the new one in all workflow files:

```yaml
# Before
- uses: actions/checkout@old-hash-here

# After  
- uses: actions/checkout@new-hash-here
```

### 3. Update the Registry

Update the action registry to reflect the new hash and version mapping.

### 4. Validate Changes

Run the pre-commit hooks to ensure all actions are properly pinned:

```bash
.pre-commit-hooks/validate-action-pinning.sh .github/workflows/*.yml
```

### 5. Create Pull Request

Create a pull request with your changes, including:
- Updated workflow files
- Updated registry
- Summary of changes in the action between versions

## Troubleshooting

### Validation Failures

If the pre-commit hook fails with "GitHub Actions pinning validation failed":

1. Check that all external actions use SHA-1 hashes, not version tags
2. Verify that the hash format is exactly 40 characters
3. Ensure no trailing whitespace or extra characters

### Update Workflow Failures

If the automated update workflow fails:

1. Check the workflow logs for specific error messages
2. Verify that the action repository is accessible
3. Confirm that the version tag exists and is valid

### Missing Actions in Registry

If a new action is added but not in the registry:

1. Add the action to the registry with its current hash
2. Ensure the hash points to a trusted version
3. Document why this action was added

## Best Practices

### When Adding New Actions

1. Always pin to a specific SHA-1 hash
2. Add the action to the registry
3. Verify the action comes from a trusted source
4. Review the action's code for security issues
5. Document why the action is needed

### When Updating Actions

1. Review changes between versions for security implications
2. Test workflows with the updated action
3. Update the registry with the new hash
4. Include a summary of changes in the pull request

### Regular Maintenance

1. Run the update workflow regularly (weekly or bi-weekly)
2. Review the action registry for outdated versions
3. Remove unused actions from the registry
4. Audit action usage in workflows

## Security Considerations

### Verifying Action Integrity

Before pinning an action:

1. Review the action's source code
2. Check the maintainer's reputation
3. Verify the action has proper security practices
4. Confirm the action is actively maintained

### Monitoring for Compromises

1. Watch for unexpected changes in action behavior
2. Monitor workflow execution logs for anomalies
3. Set up alerts for failed workflow executions
4. Regularly audit action repositories for security issues

## Related Resources

- [Security Model](../explanation/security-model.md) - Detailed explanation of the security approach
- [Workflow Inputs Reference](../reference/workflow-inputs.md) - Documentation for all workflow parameters
- [Action Registry] - Centralized tracking of all external actions