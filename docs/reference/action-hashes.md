# GitHub Actions Registry

This document tracks all external GitHub Actions used in workflows with their SHA-1 commit hashes for security pinning. Internal BrainXio actions are not included in this registry.

## Table of Contents

- [GitHub Actions Registry](#github-actions-registry)
  - [Table of Contents](#table-of-contents)
  - [Registry Overview](#registry-overview)
  - [External Actions](#external-actions)
    - [actions/upload-artifact@v4](#actionsupload-artifactv4)
    - [trufflesecurity/trufflehog@v3.95.5](#trufflesecuritytrufflehogv3955)
    - [gitleaks/gitleaks-action@v3](#gitleaksgitleaks-actionv3)
    - [actions/checkout@v6](#actionscheckoutv6)
    - [dtolnay/rust-toolchain@stable](#dtolnayrust-toolchainstable)
    - [lycheeverse/lychee-action@v2](#lycheeverselychee-actionv2)
    - [crate-ci/typos@v1](#crate-cityposv1)
    - [softprops/action-gh-release@v2](#softpropsaction-gh-releasev2)
    - [actions/setup-go@v6](#actionssetup-gov6)
    - [wagoid/commitlint-github-action@v6](#wagoidcommitlint-github-actionv6)
    - [actions/setup-node@v5](#actionssetup-nodev5)
    - [rustsec/audit-check@v2](#rustsecaudit-checkv2)
    - [astral-sh/setup-uv@v7](#astral-shsetup-uvv7)
  - [Security Audit Notes](#security-audit-notes)
  - [Rollback Procedures](#rollback-procedures)
  - [Maintenance Guidelines](#maintenance-guidelines)

## Registry Overview

All external GitHub Actions used in this repository are pinned to specific SHA-1 commit hashes to prevent unexpected changes and ensure supply chain security. This registry serves as the authoritative source for action metadata, security audits, and rollback procedures.

## External Actions

### actions/upload-artifact@v4

- **Action**: actions/upload-artifact
- **Version Tag**: v4
- **SHA-1 Hash**: ea165f8d65b6e75b540449e92b4886f43607fa02
- **Update Date**: 2026-06-13
- **Security Audit**: Verified official GitHub Action with no known vulnerabilities. Regularly maintained by GitHub.
- **Previous Hashes**: None (first pinning)

### trufflesecurity/trufflehog@v3.95.5

- **Action**: trufflesecurity/trufflehog
- **Version Tag**: v3.95.5
- **SHA-1 Hash**: d411fff7b8879a62509f3fa98c07f247ac089a51
- **Update Date**: 2026-06-13
- **Security Audit**: Well-maintained security scanning tool. No critical vulnerabilities reported.
- **Previous Hashes**: None (first pinning)

### gitleaks/gitleaks-action@v3

- **Action**: gitleaks/gitleaks-action
- **Version Tag**: v3
- **SHA-1 Hash**: e0c47f4f8be36e29cdc102c57e68cb5cbf0e8d1e
- **Update Date**: 2026-06-13
- **Security Audit**: Official Gitleaks action for secret scanning. Actively maintained with good security practices.
- **Previous Hashes**: None (first pinning)

### actions/checkout@v6

- **Action**: actions/checkout
- **Version Tag**: v6
- **SHA-1 Hash**: df4cb1c069e1874edd31b4311f1884172cec0e10
- **Update Date**: 2026-06-13
- **Security Audit**: Official GitHub Action with extensive usage and security review. Critical infrastructure component.
- **Previous Hashes**: None (first pinning)

### dtolnay/rust-toolchain@stable

- **Action**: dtolnay/rust-toolchain
- **Version Tag**: stable
- **SHA-1 Hash**: 29eef336d9b2848a0b548edc03f92a220660cdb8
- **Update Date**: 2026-06-13
- **Security Audit**: Trusted community-maintained action for Rust toolchain setup. Widely used in the Rust ecosystem.
- **Previous Hashes**: None (first pinning)

### lycheeverse/lychee-action@v2

- **Action**: lycheeverse/lychee-action
- **Version Tag**: v2
- **SHA-1 Hash**: 8646ba30535128ac92d33dfc9133794bfdd9b411
- **Update Date**: 2026-06-13
- **Security Audit**: Link checking action with good security practices. Regular maintenance and updates.
- **Previous Hashes**: None (first pinning)

### crate-ci/typos@v1

- **Action**: crate-ci/typos
- **Version Tag**: v1
- **SHA-1 Hash**: d80b8e26878e372a041833cd67163dbdb6a4336e
- **Update Date**: 2026-06-13
- **Security Audit**: Simple typo checking tool with minimal attack surface. Well-maintained by Rust community.
- **Previous Hashes**: None (first pinning)

### softprops/action-gh-release@v2

- **Action**: softprops/action-gh-release
- **Version Tag**: v2
- **SHA-1 Hash**: 3bb12739c298aeb8a4eeaf626c5b8d85266b0e65
- **Update Date**: 2026-06-13
- **Security Audit**: Popular release automation action with good security practices. Requires appropriate GitHub token permissions.
- **Previous Hashes**: None (first pinning)

### actions/setup-go@v6

- **Action**: actions/setup-go
- **Version Tag**: v6
- **SHA-1 Hash**: 4a3601121dd01d1626a1e23e37211e3254c1c06c
- **Update Date**: 2026-06-13
- **Security Audit**: Official GitHub Action for Go setup. Regular security reviews and updates.
- **Previous Hashes**: None (first pinning)

### wagoid/commitlint-github-action@v6

- **Action**: wagoid/commitlint-github-action
- **Version Tag**: v6
- **SHA-1 Hash**: f133a0d95090ef2609192b4a21f54e20af819ea9
- **Update Date**: 2026-06-13
- **Security Audit**: Commit message linting action with minimal security surface. Actively maintained.
- **Previous Hashes**: None (first pinning)

### actions/setup-node@v5

- **Action**: actions/setup-node
- **Version Tag**: v5
- **SHA-1 Hash**: a0853c24544627f65ddf259abe73b1d18a591444
- **Update Date**: 2026-06-13
- **Security Audit**: Official GitHub Action for Node.js setup. Regular security updates and reviews.
- **Previous Hashes**: None (first pinning)

### rustsec/audit-check@v2

- **Action**: rustsec/audit-check
- **Version Tag**: v2
- **SHA-1 Hash**: 69366f33c96575abad1ee0dba8212993eecbe998
- **Update Date**: 2026-06-13
- **Security Audit**: Official RustSec action for security auditing. Critical for supply chain security.
- **Previous Hashes**: None (first pinning)

### astral-sh/setup-uv@v7

- **Action**: astral-sh/setup-uv
- **Version Tag**: v7
- **SHA-1 Hash**: 94527f2e458b27549849d47d273a16bec83a01e9
- **Update Date**: 2026-06-13
- **Security Audit**: Setup action for uv Python package manager. Well-maintained with good security practices.
- **Previous Hashes**: None (first pinning)

## Security Audit Notes

All external actions in this registry have been evaluated for security considerations:

1. **Official GitHub Actions** (actions/checkout, actions/upload-artifact, actions/setup-go, actions/setup-node) are maintained by GitHub with regular security reviews.

2. **Community-maintained actions** are selected based on:
   - Active maintenance and regular updates
   - Popularity and community adoption
   - Transparent development practices
   - Minimal required permissions
   - No known security vulnerabilities

3. **Security scanning actions** (trufflesecurity/trufflehog, gitleaks/gitleaks-action, rustsec/audit-check) are critical for supply chain security.

4. **Development tool setup actions** (dtolnay/rust-toolchain, astral-sh/setup-uv) are from trusted maintainers in their respective ecosystems.

5. **Quality assurance actions** (lycheeverse/lychee-action, crate-ci/typos, wagoid/commitlint-github-action, softprops/action-gh-release) have minimal attack surface and are well-maintained.

## Rollback Procedures

To rollback any action to a previous version:

1. Identify the action and its previous hash from this registry
2. Update the workflow file to use the previous SHA-1 hash
3. Commit the change with a message following conventional commits format
4. Test the workflow to ensure functionality is restored

Example rollback commit message:
```
fix(ci): rollback actions/checkout to previous hash

Rolling back due to compatibility issue with v6 hash.

fixes #123
```

## Maintenance Guidelines

1. **Regular Updates**: Review and update action hashes quarterly or when security vulnerabilities are discovered.

2. **Update Process**:
   - Identify the latest stable release tag
   - Resolve the tag to its current SHA-1 hash
   - Update the workflow files to use the new hash
   - Update this registry with the new hash, date, and audit notes
   - Test all affected workflows

3. **Security Monitoring**:
   - Subscribe to security advisory notifications for all external actions
   - Monitor GitHub Security Lab advisories
   - Run regular dependency audits

4. **Documentation**:
   - Keep this registry up to date with all metadata
   - Record security audit findings
   - Maintain rollback hash history

