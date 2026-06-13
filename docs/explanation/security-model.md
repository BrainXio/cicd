# Security Model

This document explains the security principles and mechanisms that protect the integrity of CI/CD workflows in this repository.

## GitHub Actions Supply Chain Security

### The Risk of Version Tags

When using external GitHub Actions via version tags (e.g., `@v1`, `@v2`), you're exposing your CI/CD pipeline to supply chain attacks:

```yaml
# ❌ Vulnerable to supply chain attacks
- uses: actions/checkout@v4
- uses: actions/setup-node@v4
```

Version tags are **mutable references** that can be updated by repository maintainers at any time. An attacker who compromises a repository or gains maintainer access can:

1. Update the `v4` tag to point to malicious code
2. Execute arbitrary commands in your CI environment
3. Access secrets, tokens, and repository contents
4. Exfiltrate sensitive data to external servers

### The Solution: SHA-1 Hash Pinning

All external GitHub Actions in this repository are pinned to immutable SHA-1 hashes:

```yaml
# ✅ Secure - pinned to specific commit
- uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10
- uses: actions/setup-node@a0853c24544627f65ddf259abe73b1d18a591444
```

Each SHA-1 hash represents a **specific commit** in the action's repository. Even if maintainers update the tag, your workflow continues using the verified code at that exact commit.

### Security Benefits

1. **Immutable References**: SHA-1 hashes cannot be changed retroactively
2. **Auditable History**: Every pinned action can be traced to a specific commit
3. **Attack Surface Reduction**: Compromised tags cannot affect existing workflows
4. **Reproducible Builds**: Workflows execute the same code every time

## Action Registry

All external actions used in this repository are tracked in a centralized registry that maps version tags to their corresponding SHA-1 hashes. This registry serves as the single source of truth for approved actions and their verified versions.

## Validation and Enforcement

### Pre-Commit Hook

A pre-commit hook automatically validates that all GitHub Actions in workflow files are pinned to SHA-1 hashes, not version tags. This prevents accidental introduction of mutable references.

### Automated Updates

An automated workflow periodically checks for updates to pinned actions and creates pull requests with updated hashes when new versions are available. This balances security with the need for updates.

## Best Practices

### For Repository Maintainers

1. **Always pin to SHA-1 hashes**: Never use version tags for external actions
2. **Regularly update actions**: Use the automated update workflow to stay current
3. **Review action changes**: Before updating, review the commits between the old and new hashes
4. **Audit the registry**: Regularly verify that all actions in workflows are registered

### For Action Consumers

1. **Verify pinning**: When consuming workflows, confirm that all external actions are pinned
2. **Report issues**: If you find unpinned actions, report them as security vulnerabilities
3. **Use floating tags for this repository**: When consuming workflows from this repository, use floating tags like `@v1` which resolve to specific commits at runtime

## Threat Model

### Primary Threats

1. **Repository Compromise**: Attackers gain control of action repositories
2. **Maintainer Account Compromise**: Attackers gain access to maintainer accounts
3. **Dependency Confusion**: Attackers publish malicious actions with similar names

### Mitigation Strategies

1. **Immutable Pinning**: SHA-1 hashes prevent tag-based attacks
2. **Centralized Registry**: All actions are tracked and approved
3. **Automated Validation**: Hooks prevent introduction of unpinned actions
4. **Regular Auditing**: Automated workflows check for updates and security issues

## Security vs. Maintenance Trade-offs

While SHA-1 pinning provides strong security guarantees, it requires active maintenance to stay current with action updates. This repository balances these concerns through:

1. **Automated Update Workflows**: Regular checks for new action versions
2. **Centralized Registry**: Single source of truth for all action versions
3. **Validation Hooks**: Prevention of accidental unpinned actions
4. **Documentation**: Clear procedures for maintaining pinned actions

This approach ensures that security is never compromised for convenience while making maintenance as automated as possible.