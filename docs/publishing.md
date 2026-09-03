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
```

For `v0.1.0`, the authoritative publisher-owned binary/material set is:

```text
orbitfabric_openobsw_opensvf_adapter-0.1.0-py3-none-any.whl
adapter-release.json
SHA256SUMS
release notes
```

The Project Lock is consumer-project state and is not publisher release membership.

## Before publication

The exact source commit selected for release must pass:

```text
Python 3.11 / 3.12 checks
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
native closed-loop ping evidence
```

Do not publish from a pull-request synthetic merge ref or from an unreviewed working tree.

## Release construction

From the accepted source commit:

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

## Publication and final acceptance

GitHub Releases is the first concrete publication backend for this adapter. Publication is complete only after the exact tag, immutable release state and published asset digests are verified.

The final acceptance is then repeated from a new consumer workspace using the published assets rather than a locally built adapter bundle:

```text
install Core
    -> obtain published v0.1.0 assets
    -> Adapter Manager install
    -> verify
    -> execute product examples
    -> native closed-loop acceptance
```

That final run validates the real external-consumer distribution path.

## Publisher references

- [Release Lifecycle](release-lifecycle.md)
- [Adapter Readiness Checklist](adapter-readiness-checklist.md)
- [Evidence and Traceability](evidence-and-traceability.md)
- [Integration Coverage](integration-coverage.md)
- [Adapter Identity](adapter-identity.md)

The detailed normative release sequence remains in [Release Lifecycle](release-lifecycle.md). This page is the role-oriented entry point for maintainers and publishers.
