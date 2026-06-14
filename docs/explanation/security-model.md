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
4. **Typosquatting**: Attackers create actions with names similar to popular ones
5. **Backdoor Injection**: Malicious code added to legitimate actions via compromised PRs

### Attack Scenarios

#### Scenario 1: Tag Poisoning Attack

An attacker compromises a popular action repository and updates the `@v4` tag to point to a malicious commit:

```yaml
# Before attack
- uses: popular/action@v4  # points to abc123 (legitimate)

# After attack
- uses: popular/action@v4  # points to def456 (malicious)
```

The malicious commit exfiltrates repository secrets to an external server.

**Mitigation**: SHA-1 pinning prevents this attack because the hash never changes.

#### Scenario 2: Compromised Maintainer Account

An attacker gains access to a maintainer's GitHub account and pushes malicious code to a branch. They then update version tags to point to the malicious branch.

**Mitigation**: SHA-1 pinning ensures workflows continue using the previously verified commit.

#### Scenario 3: Dependency Confusion

An attacker publishes a malicious action with a similar name to a popular one, hoping users will accidentally use it.

**Mitigation**: The action registry validates action names against an approved list.

### Mitigation Strategies

1. **Immutable Pinning**: SHA-1 hashes prevent tag-based attacks
2. **Centralized Registry**: All actions are tracked and approved
3. **Automated Validation**: Hooks prevent introduction of unpinned actions
4. **Regular Auditing**: Automated workflows check for updates and security issues
5. **Namespace Validation**: Pre-commit hooks enforce allowed action namespaces
6. **Secret Scanning**: Gitleaks integration prevents secret exposure in workflows

## Security vs. Maintenance Trade-offs

While SHA-1 pinning provides strong security guarantees, it requires active maintenance to stay current with action updates. This repository balances these concerns through:

1. **Automated Update Workflows**: Regular checks for new action versions
2. **Centralized Registry**: Single source of truth for all action versions
3. **Validation Hooks**: Prevention of accidental unpinned actions
4. **Documentation**: Clear procedures for maintaining pinned actions

This approach ensures that security is never compromised for convenience while making maintenance as automated as possible.

## Defense in Depth

SHA-1 pinning is the primary defense, but this repository employs multiple security layers:

### Layer 1: Immutable References
- All external actions pinned to SHA-1 hashes
- Prevents tag-based supply chain attacks

### Layer 2: Centralized Registry
- `docs/reference/action-hashes.md` tracks all approved actions
- Single source of truth for action versions
- Enables auditing and compliance verification

### Layer 3: Automated Validation
- Pre-commit hook validates SHA-1 pinning on every commit
- Pre-push hook performs full repository scan
- CI workflows validate action pinning

### Layer 4: Secret Scanning
- Gitleaks integration in Python CI workflow
- Prevents accidental secret exposure in code
- Blocks commits with detected secrets

### Layer 5: Namespace Restrictions
- Pre-commit hook enforces allowed action namespaces
- Prevents typosquatting and dependency confusion
- Configurable via `ALLOWED_NAMESPACES` in hooks

### Layer 6: Regular Auditing
- Automated update workflow checks for action updates
- Security audit workflow scans for vulnerabilities
- Manual review of all action updates before merging

## Incident Response

### If a Pinned Action is Found Vulnerable

1. **Immediate Action**
   - Identify all workflows using the vulnerable action
   - Assess severity and potential impact
   - Determine if immediate rollback is necessary

2. **Containment**
   - If critical, temporarily disable affected workflows
   - Review commit history of the vulnerable action
   - Check for any suspicious activity

3. **Remediation**
   - Find a safe replacement commit or alternative action
   - Update the action registry with the new hash
   - Update all affected workflows
   - Run full CI suite to verify fixes

4. **Post-Incident**
   - Document the incident and lessons learned
   - Review and update security procedures
   - Consider adding additional validation for similar actions

### Verification Procedures

Before updating to a new action version:

1. **Review Commit History**
   ```bash
   git log OLD_HASH..NEW_HASH --oneline
   ```

2. **Check for Suspicious Changes**
   - Look for unexpected file additions
   - Review changes to entry points
   - Check for new dependencies

3. **Verify Maintainer Identity**
   - Confirm commits are from trusted maintainers
   - Check for unusual commit patterns
   - Verify no compromised accounts

4. **Test in Isolation**
   - Run workflows with the new action in a test branch
   - Monitor for unusual behavior
   - Review logs for suspicious activity

## Consumer Security Guarantees

When consuming workflows from this repository, you receive the following security guarantees:

### Immutable Execution Environment
- All external actions execute from verified, immutable commits
- No supply chain attacks via mutable version tags
- Reproduducible CI/CD execution

### Auditable Supply Chain
- Complete action registry with SHA-1 hashes
- Traceable lineage for every external action
- Clear documentation of security decisions

### Continuous Validation
- Automated validation prevents security regressions
- Regular updates address known vulnerabilities
- Pre-commit hooks enforce security standards

### Defense in Depth
- Multiple security layers protect against various attack vectors
- No single point of failure in security posture
- Comprehensive threat coverage

### Transparency
- Open security model documentation
- Clear procedures for maintenance and updates
- Public action registry for verification