# Release Lifecycle

This repository separates publisher release construction, consumer project selection and publication transport.

The operational publication gate for the first release is [v0.1.0 Publication Readiness Audit](publication-readiness-audit.md).

## Stable source identity

The `0.1.0` source baseline declares:

```text
version:          0.1.0
logical key:      orbitfabric/openobsw-opensvf
source authority: github.com/FAROTECH
classification:   OrbitFabric-maintained stable adapter
```

Its semantic scope is the reviewed first-release scope recorded by the Integration Coverage Matrix. Source acceptance and publication of immutable release assets remain separate states.

The repository is already public. The presence of `version = 0.1.0` in source does not by itself establish that a public `v0.1.0` release has been published.

## Three distinct objects

```text
Adapter Release Descriptor
    publisher-owned exact release definition

Adapter Project Lock
    consumer-project exact selected resolution

GitHub Release
    first concrete storage, immutability and transport backend
```

These roles must remain separate.

## Build the stable wheel

From the accepted stable source baseline:

```bash
python -m build --wheel
```

Expected artifact name:

```text
orbitfabric_openobsw_opensvf_adapter-0.1.0-py3-none-any.whl
```

The wheel owns the namespaced package:

```text
orbitfabric_openobsw_opensvf_adapter
```

including its unique `integration_package.json`, Profile schema and target resources.

## Publisher-owned release construction

For publication, use:

```bash
python tools/build_release_bundle.py \
  --wheel dist/orbitfabric_openobsw_opensvf_adapter-0.1.0-py3-none-any.whl \
  --authority github.com/FAROTECH \
  --publisher orbitfabric \
  --name openobsw-opensvf \
  --release-only
```

This produces:

```text
adapter-release.json
SHA256SUMS
```

The stable publisher release membership is therefore:

```text
v0.1.0 tag
orbitfabric_openobsw_opensvf_adapter-0.1.0-py3-none-any.whl
adapter-release.json
SHA256SUMS
release notes
```

The release-only checksum file covers the exact wheel and Release Descriptor bytes.

The Integration Package Manifest digest is bound inside the Release Descriptor and the manifest bytes are packaged inside the wheel.

GitHub-generated source archives are provider conveniences and are not OrbitFabric adapter release membership.

## Project Lock lifecycle proof

The default tool mode additionally derives:

```text
adapter-project-lock.json
```

This is required for exact lifecycle proof:

```text
Source Coordinate
release version
Release Descriptor SHA-256
artifact id
artifact SHA-256
installation backend id
```

The permanent CI proves:

```text
initial state MISSING
    -> install exact release from lock
    -> MATCH
    -> second identical request NOOP / MATCH
    -> verify
    -> remove
    -> empty inventory
```

The lock used by CI is engineering evidence for a consumer selection. It is not canonical publisher release membership.

## Stable Source Coordinate

The first stable release uses:

```text
authority = github.com/FAROTECH
publisher = orbitfabric
name      = openobsw-opensvf
```

Rendered for the current Adapter Manager explicit-source CLI:

```text
github.com/FAROTECH:orbitfabric/openobsw-opensvf
```

The authority identifies the first concrete source context. It does not make `FAROTECH` the logical publisher and does not define GitHub as the universal OrbitFabric registry.

A future source authority may change without changing the logical product key:

```text
orbitfabric/openobsw-opensvf
```

## Stable validation gates

The exact `0.1.0` source baseline must pass:

```text
Python 3.11 / 3.12
Ruff
adapter consistency
unit and negative tests
wheel/package validation
MkDocs strict build
OpenOBSW / SRDB native compatibility
OpenSVF native compatibility
installed Adapter Manager lifecycle
Release Descriptor / Project Lock proof
release-only publisher artifact proof
product examples through Adapter Manager
native closed-loop acceptance evidence
```

Core conformance and downstream-native acceptance remain separate evidence layers.

## v0.1.0 provenance boundary

The first release proves release provenance through exact source and byte identity plus the provider-generated immutable-release record:

```text
accepted main commit
    + exact v0.1.0 tag
    + immutable GitHub Release
    + exact published SHA-256 values
    + Release Descriptor binding to the wheel and packaged manifest
    + GitHub-generated release attestation
```

`v0.1.0` does not introduce an adapter-authored signing scheme or an OrbitFabric-specific signature format.

GitHub Immutable Releases automatically generate a cryptographically verifiable release attestation containing the release tag, commit SHA and release assets. That attestation is provider-owned publication evidence and is verified after publication alongside exact asset digests.

Any future adapter-authored signing or additional trust mechanism remains a separate capability with its own implementation and evidence.

## GitHub publication boundary

GitHub Releases is the first concrete publication backend for this adapter.

For public `v0.1.0` publication:

```text
1. merge the exact green publication-preparation candidate
2. record the accepted main source commit
3. confirm the release-relevant CI on that accepted commit
4. confirm GitHub Immutable Releases configuration
5. create v0.1.0 against the exact accepted source commit
6. build the definitive wheel, adapter-release.json and SHA256SUMS from that source
7. verify the definitive asset digests and Release Descriptor locally
8. create v0.1.0 as a draft GitHub Release
9. attach only the definitive wheel, adapter-release.json and SHA256SUMS
10. verify the draft tag, release notes and uploaded/downloaded asset digests
11. publish the verified draft under the immutable-release policy
12. confirm final immutable release state
13. verify tag -> intended stable commit
14. download the public assets and re-verify their digests
15. verify the GitHub-generated release attestation
16. repeat the external greenfield consumer acceptance from published assets
17. retain final Architecture Lab publication evidence
```

All normative assets must be attached and verified before immutable publication because the release must not rely on post-publication mutation.

GitHub release URLs and the generated release attestation are provider publication metadata/evidence. They do not replace the OrbitFabric Release Descriptor.

## Release classification

`0.1.0` is an:

```text
OrbitFabric-maintained stable adapter
```

It is intentionally not yet called a registry-classified official OrbitFabric adapter.

The technical release has strong conformance, compatibility, immutability and provenance requirements. Formal official classification remains tied to future promoted publisher/source-authority governance rather than being self-declared by release bytes.

## Source provenance

Released source provenance must identify the exact stable source commit.

Do not use a synthetic pull-request merge ref as normative release provenance.

The final tag and definitive release build must operate from the accepted stable commit.

The exact tag-to-commit association, published asset digests and GitHub-generated release attestation are retained as publication evidence.

## External greenfield acceptance

Publication is not considered fully accepted until a new consumer workspace proves the published distribution path.

The final acceptance must not rebuild or source-install the adapter.

```text
install OrbitFabric Core
    -> obtain public v0.1.0 release assets
    -> Adapter Manager install
    -> inspect / verify
    -> execute product examples
    -> native closed-loop acceptance
```

The adapter repository may be cloned only to obtain product example source inputs if necessary. It must not provide the adapter installation bytes in this final exercise.

## Evidence

The `release-proof` CI job retains two related evidence sets.

### Lifecycle evidence

```text
Adapter Release Descriptor
Project Lock used by the proof
SHA-256 summary
Adapter Manager before/install/check/verify/remove reports
```

### Publisher-release evidence

```text
stable wheel
adapter-release.json
release-only SHA256SUMS
```

After public publication, Architecture Lab evidence additionally retains:

```text
accepted source commit
exact v0.1.0 tag association
immutable GitHub Release identity/state
published asset SHA-256 values
GitHub-generated release attestation verification
post-publication Adapter Manager verification
external greenfield product-example evidence
```
