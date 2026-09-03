# Release Lifecycle

This repository separates publisher release construction, consumer project selection and publication transport.

## Stable source identity

The `0.1.0` source baseline declares:

```text
version:          0.1.0
logical key:      orbitfabric/openobsw-opensvf
source authority: github.com/FAROTECH
classification:   OrbitFabric-maintained stable adapter
```

Its semantic scope is the reviewed first-release scope recorded by the Integration Coverage Matrix. Source acceptance, repository visibility and publication of immutable release assets remain separate states.

The presence of `version = 0.1.0` in source does not by itself establish that a public release has been published.

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
release/provenance attestation evidence
```

The release-only checksum file covers the exact wheel and Release Descriptor bytes.

The Integration Package Manifest digest is bound inside the Release Descriptor and the manifest bytes are packaged inside the wheel.

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
```

Core conformance and downstream-native acceptance remain separate evidence layers.

## GitHub publication boundary

GitHub Releases is the first concrete publication backend for this adapter.

For public `v0.1.0` publication:

```text
1. use the accepted stable source commit
2. make the repository public and verify public repository state
3. enable GitHub immutable releases
4. create v0.1.0 as a draft release from the exact stable commit
5. attach wheel, adapter-release.json and SHA256SUMS
6. verify local asset digests before publication
7. publish the draft as an immutable release
8. confirm the release is marked immutable
9. verify tag -> intended stable commit
10. verify published asset digests
11. retain release/provenance attestation evidence
```

All normative assets must be attached before publication because an immutable release must not be mutated afterwards.

GitHub release URLs are provider metadata. They do not replace the OrbitFabric Release Descriptor.

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

The final release/tag or publication workflow must explicitly operate from the accepted stable commit or tag.

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

After public publication, Architecture Lab evidence additionally retains the immutable GitHub release state, exact tag/commit association, published digests and release/provenance attestation result.
