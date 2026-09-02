# Release Lifecycle

This repository separates release construction from publication.

The adapter repository is responsible for constructing exact release identity. A publication provider only transports those already identified bytes.

## What you build

For a Python adapter, the release path demonstrated by this Template is:

```text
clean checkout
    -> build wheel
    -> compute wheel SHA-256
    -> compute Integration Package Manifest SHA-256
    -> build Adapter Release Descriptor
    -> compute Release Descriptor SHA-256
    -> build Adapter Project Lock
    -> Core conformance
    -> Adapter Manager install from lock
    -> MATCH
    -> evidence bundle
```

The Template provides:

```text
tools/build_release_bundle.py
```

It generates:

```text
adapter-release.json
adapter-project-lock.json
SHA256SUMS
```

These files use Core-owned candidate contracts. The tool is a developer convenience, not a replacement specification.

## Build the wheel

From a clean checkout:

```bash
python -m build --wheel
```

The wheel must contain exactly one namespaced `integration_package.json` that belongs to the installed Python distribution.

## Build exact release identity

For the Dummy Adapter:

```bash
python tools/build_release_bundle.py \
  --wheel dist/orbitfabric_dummy_adapter-0.1.0.dev0-py3-none-any.whl \
  --authority template.local \
  --publisher orbitfabric \
  --name dummy-adapter
```

For a real adapter, replace all three identity fields deliberately.

The tool reads `project.version` from `pyproject.toml` unless `--release-version` is supplied explicitly.

The default Python installation backend is:

```text
python-wheel-managed-env
```

This is a backend-specific Template convention. It is not a universal adapter contract.

## Validate before publishing

With the exact OrbitFabric Core baseline installed, validate the generated files through Core-owned readers and conformance surfaces.

The CI release proof does exactly this before installation.

## Satisfy the Project Lock

The generated Project Lock contains exact identity:

```text
Source Coordinate
release version
Release Descriptor SHA-256
artifact id
artifact SHA-256
installation backend id
```

The Template CI proves:

```text
initial state MISSING
    -> install exact release from lock
    -> MATCH
    -> second identical request NOOP
```

A nominal version match is not sufficient when byte identity differs.

## Publication is separate

The Template does not require GitHub Releases, PyPI or a future OrbitFabric registry.

A provider-specific publication step may later resolve and transport the same exact release into the Core source-neutral `ResolvedAdapterRelease` seam.

Do not put provider URLs into Project Lock identity only because one provider happens to be used for publication.

## Evidence

The `release-proof` CI job retains an evidence artifact containing the exact Release Descriptor, Project Lock, SHA-256 summary and Adapter Manager reports used by the control.

The evidence demonstrates the release that was tested. It does not create a new OrbitFabric contract.
