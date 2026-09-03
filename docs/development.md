# Developer / Contributor Guide

This section is for people changing, extending or reviewing the adapter implementation itself.

If you only want to install and use a released adapter, start with [Getting Started](getting-started.md). The normal user path is through OrbitFabric Adapter Manager and does not require an editable install of this repository.

## Development checkout

```bash
git clone https://github.com/FAROTECH/orbitfabric-openobsw-opensvf-adapter.git
cd orbitfabric-openobsw-opensvf-adapter

python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e ".[dev]"
```

The editable installation exposes the contributor-facing console command:

```text
orbitfabric-openobsw-opensvf
```

Use this direct command for adapter development, debugging and source-tree regression work. Consumer-facing examples use Adapter Manager when `ORBITFABRIC_ADAPTER_INSTANCE_ID` is set.

## Local checks

Run before opening a pull request:

```bash
ruff check .
python tools/check_adapter_consistency.py
pytest -q
python -m build --wheel
mkdocs build --strict
```

The permanent CI adds stronger controls for:

```text
Python 3.11 / 3.12
OpenOBSW / SRDB native compatibility
OpenSVF native compatibility
installed Adapter Manager lifecycle
release / Project Lock proof
product examples through Adapter Manager
native closed-loop evidence
```

## Development ownership boundary

Preserve this split when changing behavior:

```text
OrbitFabric Core
    generic mission and integration contracts

this adapter
    OpenOBSW/OpenSVF-specific projection and compatibility

OpenOBSW / OpenSVF
    downstream-native formats, runtime and validation semantics
```

A generic OrbitFabric semantic change normally belongs in Core. A downstream-specific mapping or compatibility assumption belongs here and requires target-native evidence.

## Main developer references

Use these documents when working on the implementation:

- [Repository Anatomy](repository-anatomy.md)
- [Architecture and Ownership](architecture-and-ownership.md)
- [Adapter Identity](adapter-identity.md)
- [Integration Contracts](integration-contracts.md)
- [Projection Profile and Bindings](projection-profile-and-bindings.md)
- [Testing and Conformance](testing-and-conformance.md)
- [Runtime Dependencies](runtime-dependencies.md)
- [Integration Coverage](integration-coverage.md)
- [Migration from the PoC](migrating-from-poc.md)

The repository-level [CONTRIBUTING.md](../CONTRIBUTING.md) contains the contribution rules and local pre-PR checklist.

## Release work is a separate role

Building or publishing authoritative release assets is maintainer/publisher work, not ordinary consumer setup and not required for normal contributor development.

For that lifecycle, continue with [Maintainer / Publisher Guide](publishing.md).
