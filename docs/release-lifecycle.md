# Release Lifecycle

This repository separates release construction from publication.

The adapter repository is responsible for constructing exact release identity. A publication provider transports already identified bytes and does not redefine the adapter release.

## Current release status

The package is currently:

```text
0.1.0.dev0
```

This is a development product baseline. The first stable `0.1.0` is intentionally withheld until coverage, compatibility, documentation and publication-readiness review are complete.

The final public publisher identity and Source Coordinate are not yet frozen.

## What the repository builds

The provider-neutral release path is:

```text
clean checkout
    -> build wheel
    -> compute wheel SHA-256
    -> compute Integration Package Manifest SHA-256
    -> build Adapter Release Descriptor
    -> compute Release Descriptor SHA-256
    -> build Adapter Project Lock
    -> Core conformance
    -> Adapter Manager lock check = MISSING
    -> install exact release
    -> MATCH
    -> repeat install
    -> NOOP / MATCH
    -> evidence bundle
```

The repository provides:

```text
tools/build_release_bundle.py
```

which generates:

```text
adapter-release.json
adapter-project-lock.json
SHA256SUMS
```

These files use Core-owned candidate contracts. The tool is a developer convenience, not an alternative specification.

## Build the wheel

From a clean checkout:

```bash
python -m build --wheel
```

The wheel owns the namespaced package:

```text
orbitfabric_openobsw_opensvf_adapter
```

including its unique `integration_package.json`, Profile schema and target resources.

## Build exact release identity

During private productization, the CI release proof uses local development publication identity only to exercise the source-neutral contract path.

A representative command is:

```bash
python tools/build_release_bundle.py \
  --wheel dist/orbitfabric_openobsw_opensvf_adapter-0.1.0.dev0-py3-none-any.whl \
  --authority <development-or-final-authority> \
  --publisher <publisher> \
  --name openobsw-opensvf
```

The final authority/publisher values must be selected deliberately before public release. They are not inferred from GitHub hosting or from the historical PoC repository.

The tool reads `project.version` from `pyproject.toml` unless `--release-version` is supplied explicitly.

The current installation backend is:

```text
python-wheel-managed-env
```

This is the backend exercised by Adapter Manager for this Python adapter. It is not a universal requirement for every OrbitFabric adapter implementation language.

## Validate before publication

Release construction is accepted only after the same adapter baseline also passes:

```text
Core contract conformance
adapter unit and negative tests
OpenOBSW / SRDB native compatibility
OpenSVF native compatibility
installed Adapter Manager lifecycle
provider-neutral release proof
Integration Coverage review
```

A release artifact is not considered mature merely because the wheel can be built.

## Project Lock semantics

The generated Project Lock records exact desired state:

```text
Source Coordinate
release version
Release Descriptor SHA-256
artifact id
artifact SHA-256
installation backend id
```

The permanent release proof establishes:

```text
initial state MISSING
    -> install exact release from lock
    -> MATCH
    -> second identical request NOOP / MATCH
    -> verify
    -> remove
```

A nominal version match is not sufficient when byte identity differs.

## Publication is separate

The adapter does not require a provider-specific publication mechanism to define release identity.

A later publication flow may use GitHub Releases or another provider to resolve and transport the same exact release into Core's source-neutral `ResolvedAdapterRelease` seam.

Provider URLs must not be smuggled into Project Lock identity simply because one transport was selected for publication.

## Public release boundary

Before changing `0.1.0.dev0` to `0.1.0`, review at least:

```text
Integration Coverage Matrix
OpenOBSW exact compatibility evidence
OpenSVF exact compatibility evidence
runtime dependency declaration
README and downstream setup completeness
installed lifecycle evidence
release / Project Lock evidence
remaining PoC-history language in product code/resources
final Source Coordinate and publisher identity
```

The repository should become public only after this review is complete and the published documentation accurately describes the released compatibility envelope.

## Evidence

The `release-proof` CI job uploads an evidence artifact containing the exact Release Descriptor, Project Lock, SHA-256 summary and Adapter Manager reports used by the control.

That evidence identifies the release bytes that were tested. It does not create a new OrbitFabric contract and it does not by itself establish downstream runtime execution.
