# OrbitFabric OpenOBSW/OpenSVF Adapter

Integration adapter connecting [OrbitFabric](https://github.com/FAROTECH/orbitfabric) mission contracts with the native integration and validation surfaces provided by [OpenOBSW](https://github.com/lipofefeyt/openobsw) and [OpenSVF](https://github.com/lipofefeyt/opensvf).

This repository is intentionally written for users arriving from either side of the integration. OrbitFabric, OpenOBSW and OpenSVF remain independent systems with their own responsibilities. The adapter owns the projection boundary between them.

> Development status: productization in progress. The repository is private while the PoC implementation is being extracted, compatibility is refreshed against current upstreams, and the full lifecycle is revalidated.

## The participating systems

### OrbitFabric

OrbitFabric is a model-first Mission Data Fabric for small spacecraft. OrbitFabric Core owns mission semantics, generic integration contracts, conformance and Adapter Manager lifecycle behavior.

Official repository: [FAROTECH/orbitfabric](https://github.com/FAROTECH/orbitfabric)

### OpenOBSW

OpenOBSW is an open-source spacecraft on-board software stack implemented in portable C11. Its current upstream provides a PUS-C flight-software stack, host simulation and multiple hardware/emulation targets. OpenOBSW owns flight/runtime behavior, packet framing, command dispatch, housekeeping, event materialization and target execution.

Official repository: [lipofefeyt/openobsw](https://github.com/lipofefeyt/openobsw)

### OpenSVF

OpenSVF is a Python-based spacecraft Software Validation Facility. Its current upstream provides spacecraft configuration, simulation, campaign/procedure execution, PUS TM/TC handling, SRDB/XTCE tooling and optional YAMCS integration. OpenSVF owns its native simulation, verification and bridge semantics.

Official repository: [lipofefeyt/opensvf](https://github.com/lipofefeyt/opensvf)

## Why connect them?

The integration keeps mission intent and downstream execution separate:

```text
OrbitFabric Mission Model
        |
        v
OrbitFabric Core
Integration Input Set
        |
        + Projection Profile
        |
        v
OpenOBSW/OpenSVF Adapter
        |
        +--------------------------+
        |                          |
        v                          v
OpenOBSW-facing              OpenSVF-compatible
contract/contribution        integration artifacts
        |                          |
        v                          v
     OpenOBSW                   OpenSVF
                                   |
                                   v
                             YAMCS, optional
```

OrbitFabric owns intent and generic contract. The adapter owns target-specific projection. OpenOBSW and OpenSVF own their native execution and validation behavior. Evidence retains provenance across the boundary.

## What the adapter is responsible for

The productized adapter is intended to:

- consume a Core Integration Input Set produced by OrbitFabric;
- validate an OpenOBSW/OpenSVF-specific Projection Profile;
- resolve target-specific bindings and compatibility facts;
- generate the OpenOBSW-facing contract/contribution required by the selected integration scope;
- generate OpenSVF-compatible integration artifacts where applicable;
- produce a Core-conformant Integration Result with mappings, provenance and coverage;
- project supported OrbitFabric Scenario intent toward OpenSVF verification assets through an explicit operation input;
- fail clearly when a required downstream compatibility fact is missing or incompatible.

The adapter does not replace OpenOBSW, generate OpenOBSW runtime logic, replace OpenSVF campaign execution, reimplement YAMCS semantics, or make OrbitFabric Core aware of OpenOBSW/OpenSVF-specific concepts.

## If you come from OrbitFabric

The normal flow is:

```text
Mission Model
  -> Core validation
  -> Core Integration Input Set
  -> Projection Profile
  -> adapter project operation
  -> downstream artifacts + Integration Result
```

OrbitFabric-side installation and Adapter Manager usage are documented in [Getting Started](docs/getting-started.md). The exact supported Core surfaces and Integration Coverage Matrix are maintained in this repository and are validated before release.

## If you come from OpenOBSW/OpenSVF

You do not need to adopt OrbitFabric runtime semantics inside either downstream project. OrbitFabric provides structured mission intent and the adapter translates explicit projection choices into downstream-owned representations.

The downstream setup section in [Getting Started](docs/getting-started.md) documents what must be installed or configured on the OpenOBSW/OpenSVF side, which generated artifacts are consumed, and how to perform end-to-end validation. Required, recommended and optional downstream steps are kept separate.

## Installation

During productization, use a development checkout:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e ".[dev]"
python -m pip install "orbitfabric @ git+https://github.com/FAROTECH/orbitfabric.git@4377d6656c62aa1dc19a7ed81d2de872b6b22ccd"
```

Run the repository checks:

```bash
ruff check .
python tools/check_adapter_consistency.py
pytest -q
python -m build --wheel
mkdocs build --strict
```

A release installation path through OrbitFabric Adapter Manager will be documented and frozen only after the target compatibility and release identity review is complete.

## Operations

The adapter identity is:

```text
repository       orbitfabric-openobsw-opensvf-adapter
distribution     orbitfabric-openobsw-opensvf-adapter
python package   orbitfabric_openobsw_opensvf_adapter
console command  orbitfabric-openobsw-opensvf
adapter.id       orbitfabric-openobsw-opensvf
integration.id   orbitfabric-openobsw-opensvf
```

The product baseline is being developed around two execution shapes:

```text
project
    consumes the Core Integration Input Set and Projection Profile

verification_projection
    additionally requires one file-backed operation input: scenario
```

The final public capability declarations will reflect only behavior that is implemented and lifecycle-tested in this repository.

## Setup from both sides

The integration documentation follows four steps:

1. **OrbitFabric-side setup**: Core input production, adapter installation and Adapter Manager lifecycle.
2. **Adapter configuration**: Projection Profile, compatibility selections and operation inputs.
3. **OpenOBSW/OpenSVF-side setup**: downstream prerequisites, generated artifact consumption, build/runtime configuration and optional verification tooling.
4. **End-to-end validation**: Core conformance plus downstream-native acceptance controls.

See [Getting Started](docs/getting-started.md).

## Compatibility

Compatibility is treated as part of the adapter contract, not as an implicit assumption. The productized repository will publish the exact baselines validated for:

- OrbitFabric Core integration contracts;
- OpenOBSW;
- OpenSVF;
- the relevant SRDB composition/tooling boundary;
- YAMCS only where an OpenSVF validation path depends on it.

The historical PoC remains the evidence source for earlier validated paths. This repository refreshes those assumptions against the current upstream projects before publication.

## Repository structure

```text
src/orbitfabric_openobsw_opensvf_adapter/
    adapter implementation
    Integration Package Manifest
    Profile schema
    target resources

examples/
    reference Core inputs, Projection Profile and Scenario

tests/
    contract, projection, compatibility and lifecycle tests

coverage/
    Integration Coverage Matrix

docs/
    architecture, setup, compatibility, evidence and release guidance

tools/
    adapter consistency and release tooling

.github/
    CI, installed lifecycle proof and provider-neutral release proof
```

## Documentation

The documentation is authored in `docs/`, built with MkDocs and validated with `mkdocs build --strict` in CI.

Start with:

1. [Getting Started](docs/getting-started.md)
2. [Architecture and Ownership](docs/architecture-and-ownership.md)
3. [Adapter Identity](docs/adapter-identity.md)
4. [Projection Profile and Bindings](docs/projection-profile-and-bindings.md)
5. [Testing and Conformance](docs/testing-and-conformance.md)
6. [Evidence and Traceability](docs/evidence-and-traceability.md)
7. [Integration Coverage](docs/integration-coverage.md)
8. [Release Lifecycle](docs/release-lifecycle.md)

## Historical PoC

The preceding engineering investigation remains available as historical evidence in the OrbitFabric OpenOBSW PoC repositories. PoC Stage numbering, experiments and runtime scaffolding are intentionally not copied wholesale into this product repository. Only durable adapter behavior, target resources, compatibility controls and reusable regression evidence are extracted.

## Project relationships

OpenOBSW and OpenSVF are independent upstream projects. This adapter is maintained as part of the OrbitFabric ecosystem and integrates with their published/native interfaces without transferring ownership of downstream semantics to OrbitFabric.

## License

Apache-2.0.
