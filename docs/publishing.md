# Maintainer / Publisher Guide

This section is for maintainers preparing, proving and publishing an adapter release.

It is intentionally separate from normal user installation. A consumer should install already-published release assets through OrbitFabric Adapter Manager and should never need to build the adapter wheel or Release Descriptor locally.

## Publisher responsibility

The publisher turns an accepted source commit into one immutable, verifiable release:

```text
accepted main commit
    -> release tag
    -> wheel
    -> Adapter Release Descriptor
    -> SHA256SUMS
    -> local verification
    -> draft GitHub Release
    -> immutable publication
    -> published-asset verification
    -> final external greenfield acceptance
    -> Architecture Lab evidence retention
```

For `v0.1.0`, the authoritative publisher-owned binary/material set is:

```text
orbitfabric_openobsw_opensvf_adapter-0.1.0-py3-none-any.whl
adapter-release.json
SHA256SUMS
release notes
```

The Project Lock is consumer-project state and is not publisher release membership.

## v0.1.0 completed publication

The first stable release completed the full publication sequence on **2026-09-03**.

Final status:

```text
P1-P13: PASS
immutable GitHub Release: PASS
GitHub release attestation: PASS
public Adapter Manager install: PASS
external greenfield acceptance: PASS
native OpenOBSW/OpenSVF closed loop: PASS
```

The completed evidence is retained in the [v0.1.0 Publication Readiness Audit](publication-readiness-audit.md) and in Architecture Lab evidence:

```text
evidence/adapter-management/
046-openobsw-opensvf-v0.1.0-publication-and-greenfield-acceptance.md
```

The audit is now a closed release record rather than an active publication gate.

## Before publication

For future releases, the exact source commit selected for release must pass the release-relevant product controls, including:

```text
Python compatibility checks
Ruff
adapter consistency
unit and negative tests
wheel/package validation
MkDocs strict build
OpenOBSW native compatibility
OpenSVF native compatibility
installed Adapter Manager lifecycle
release / Project Lock proof
publisher release-only proof
product examples through Adapter Manager
native closed-loop evidence where claimed
```

Do not publish from a pull-request synthetic merge ref or from an unreviewed working tree.

The detailed first-release sequence and reusable publication boundaries remain documented in [Release Lifecycle](release-lifecycle.md).

## v0.1.0 provenance boundary

The first release proves provenance through exact source and byte identity:

```text
accepted main commit
    + exact v0.1.0 tag
    + immutable GitHub Release
    + published SHA-256 values
    + Release Descriptor binding
    + GitHub-generated immutable-release attestation
```

`v0.1.0` does not introduce an adapter-authored signing scheme or an OrbitFabric-specific signature format.

GitHub's provider-generated release attestation is part of publication evidence. Any future adapter-authored signing or additional trust mechanism remains a separate capability with its own implementation and verification evidence.

## Release construction

From an accepted source commit:

```bash
python -m build --wheel

python tools/build_release_bundle.py \
  --wheel dist/orbitfabric_openobsw_opensvf_adapter-0.1.0-py3-none-any.whl \
  --authority github.com/FAROTECH \
  --publisher orbitfabric \
  --name openobsw-opensvf \
  --release-only
```

This produces the publisher-owned Release Descriptor and checksum summary.

For a future release version, use the corresponding accepted source and artifact version rather than reusing `v0.1.0` publication bytes.

## Publication and final acceptance

GitHub Releases is the first concrete publication backend for this adapter. Publication is complete only after the exact tag, immutable release state, published asset digests and provider-generated release attestation are verified.

Final acceptance must then be repeated from a new consumer workspace using the published assets rather than a locally built adapter bundle:

```text
install Core
    -> obtain published release assets
    -> Adapter Manager install
    -> verify
    -> execute product examples
    -> native downstream acceptance where claimed
```

For `v0.1.0`, that path has been completed successfully.

## Current consumer acquisition boundary

The current Adapter Manager installation path still expects the user to obtain the Release Descriptor and artifact before installation.

Today:

```text
GitHub Release
    -> manual asset acquisition
    -> Adapter Manager install
```

A future Adapter Catalog + Release Resolution layer may automate discovery, exact resolution and acquisition. That future layer must consume the existing immutable `v0.1.0` release rather than requiring it to be republished.

## Publisher references

- [v0.1.0 Publication Readiness Audit](publication-readiness-audit.md)
- [Release Lifecycle](release-lifecycle.md)
- [Adapter Readiness Checklist](adapter-readiness-checklist.md)
- [Evidence and Traceability](evidence-and-traceability.md)
- [Integration Coverage](integration-coverage.md)
- [Adapter Identity](adapter-identity.md)

The detailed release sequence remains in [Release Lifecycle](release-lifecycle.md). This page is the role-oriented entry point for maintainers and publishers.
