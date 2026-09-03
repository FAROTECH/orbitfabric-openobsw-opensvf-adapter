# OrbitFabric OpenOBSW/OpenSVF Adapter

Integration adapter connecting [OrbitFabric](https://github.com/FAROTECH/orbitfabric) mission contracts with the native integration and validation surfaces provided by [OpenOBSW](https://github.com/lipofefeyt/openobsw) and [OpenSVF](https://github.com/lipofefeyt/opensvf).

This repository is intentionally written for users arriving from either side of the integration. OrbitFabric, OpenOBSW and OpenSVF remain independent systems with their own responsibilities. The adapter owns the projection boundary between them.

> Release candidate status: this branch prepares the stable `0.1.0` OrbitFabric-maintained adapter release. The semantic scope is unchanged from the validated `0.1.0.dev0` product baseline. Stable logical identity and first release source authority are now frozen, but the release is not public until the exact candidate is merged, the repository is made public, GitHub release immutability is enabled and the published bytes and attestations are verified.

## The participating systems

### OrbitFabric

OrbitFabric is a model-first Mission Data Fabric for small spacecraft. OrbitFabric Core owns mission semantics, generic integration contracts, conformance and Adapter Manager lifecycle behavior.

Official repository: [FAROTECH/orbitfabric](https://github.com/FAROTECH/orbitfabric)

### OpenOBSW

OpenOBSW is an open-source spacecraft on-board software stack implemented in portable C11. Its upstream provides a PUS-C flight-software stack, host simulation and multiple hardware or emulation targets. OpenOBSW owns flight/runtime behavior, packet framing, command dispatch, housekeeping, event materialization and target execution.

Official repository: [lipofefeyt/openobsw](https://github.com/lipofefeyt/openobsw)

### OpenSVF

OpenSVF is a Python-based spacecraft Software Validation Facility. Its upstream provides spacecraft configuration, simulation, campaign/procedure execution, PUS TM/TC handling, SRDB/XTCE tooling and optional YAMCS integration. OpenSVF owns its native simulation, verification and bridge semantics.

Official repository: [lipofefeyt/opensvf](https://github.com/lipofefeyt/opensvf)

## Why connect them?

The integration keeps mission intent, target projection and downstream execution separate:

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
contract + SRDB              verification assets
contribution                       |
        |                          v
        v                       OpenSVF
     OpenOBSW                       |
                                   v
                             YAMCS, optional
```

OrbitFabric owns intent and generic contract. The adapter owns target-specific projection. OpenOBSW and OpenSVF own their native execution and validation behavior. Evidence retains provenance across the boundary.

## What the adapter does

The current product baseline:

- consumes a coherent Core Integration Input Set produced by OrbitFabric;
- validates an OpenOBSW/OpenSVF-specific Projection Profile;
- resolves target-specific bindings and compatibility facts;
- projects supported telemetry, housekeeping packets, commands and events;
- generates a contract-only OpenOBSW-facing C header;
- generates an additive `obsw-srdb` contribution without modifying an OpenOBSW checkout;
- produces a Core-conformant Integration Result with mappings, provenance and coverage;
- projects a supported subset of OrbitFabric Scenario intent into an explicit Verification Projection Plan;
- materializes that plan into native OpenSVF spacecraft, campaign and Procedure assets;
- fails explicitly when a required downstream compatibility fact is missing or incompatible.

The adapter does not replace OpenOBSW, generate OpenOBSW runtime logic, replace OpenSVF campaign execution, reimplement YAMCS semantics, or make OrbitFabric Core aware of OpenOBSW/OpenSVF-specific concepts.

## If you come from OrbitFabric

The normal project flow is:

```text
Mission Model
  -> Core validation
  -> Core Integration Input Set
  -> Projection Profile
  -> adapter project operation
  -> downstream artifacts + Integration Result
```

For verification projection:

```text
Mission Model + Scenario
  -> Core Integration Input Set
  -> Projection Profile
  -> adapter verification_projection operation
  -> Verification Projection Plan
  -> native OpenSVF campaign/procedure/spacecraft assets
```

See [Getting Started](docs/getting-started.md) for the development installation and execution path.

## If you come from OpenOBSW/OpenSVF

You do not need to adopt OrbitFabric runtime semantics inside either downstream project. OrbitFabric supplies validated mission intent. The adapter translates explicit integration choices into representations owned and consumed by the downstream ecosystem.

The adapter does not patch or mutate an OpenOBSW/OpenSVF source checkout. Generated artifacts are a handoff boundary that can be inspected, composed and validated before a downstream project chooses to include them in its own build or runtime workflow.

### OpenOBSW / SRDB handoff

A `project` run generates:

```text
flight_software/
  mission_contract.h

obsw_srdb_contribution/
  contribution_manifest.json
  parameters.yaml
  telecommands.yaml
  hk_sets.yaml
  events.yaml

integration_result.json
```

The SRDB bundle is explicitly additive:

```text
mode = additive
complete_srdb = false
```

The validated native flow composes this contribution with the OpenOBSW base SRDB using `obsw-srdb`, materializes the resulting SRDB, regenerates C and XTCE outputs through the target tooling, and compiles the generated `mission_contract.h` as C11 with warnings treated as errors.

The adapter does not prescribe a private source-tree location for `mission_contract.h`. OpenOBSW or the consuming flight integration remains responsible for deciding where the contract header enters its build and for implementing the runtime behavior behind the declared symbols.

### OpenSVF handoff

A `verification_projection` run additionally generates:

```text
verification_projection/
  verification_projection_plan.json
  opensvf/
    materialization_manifest.json
    opensvf/
      spacecraft.yaml
    campaigns/
      verification_projection_campaign.yaml
    procedures/
      verification_projection_procedure.py
```

The generated Procedure uses native OpenSVF `Procedure` / `ProcedureContext` primitives. The generated spacecraft configuration is validated with the upstream `svf validate` command, and the campaign is loaded through OpenSVF `CampaignRunner.from_yaml()` in CI.

Actual SIL campaign execution is a separate downstream runtime step because it requires the selected OpenOBSW binary and any physics/runtime dependencies required by the chosen OpenSVF mode.

## Installation

### Development checkout

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e ".[dev]"
```

The package declares the exact OrbitFabric Core baseline it requires, so installation resolves that dependency automatically. CI also installs the same Core commit explicitly as a conformance control.

Run the repository checks:

```bash
ruff check .
python tools/check_adapter_consistency.py
pytest -q
python -m build --wheel
mkdocs build --strict
```

### Adapter Manager

The repository proves the complete installed lifecycle through OrbitFabric Adapter Manager:

```text
release artifact
  -> install
  -> inventory
  -> verify
  -> project execution
  -> verification_projection execution
  -> result conformance
  -> second install / NOOP in release proof
  -> remove
  -> empty inventory
```

For stable `0.1.0`, the selected logical/source identity is:

```text
logical key        orbitfabric/openobsw-opensvf
source authority   github.com/FAROTECH
Source Coordinate  github.com/FAROTECH:orbitfabric/openobsw-opensvf
```

The GitHub authority identifies the first concrete release source. It does not make the GitHub organization the logical publisher and does not define GitHub as a universal OrbitFabric registry.

## Adapter identity

```text
repository       orbitfabric-openobsw-opensvf-adapter
distribution     orbitfabric-openobsw-opensvf-adapter
python package   orbitfabric_openobsw_opensvf_adapter
console command  orbitfabric-openobsw-opensvf
adapter.id       orbitfabric-openobsw-opensvf
integration.id   orbitfabric-openobsw-opensvf
logical key      orbitfabric/openobsw-opensvf
version          0.1.0
```

The release is classified as an **OrbitFabric-maintained stable adapter**. It is not yet described as registry-classified official because the generic official publisher/registry governance layer has not been promoted.

## Operations

### Project

```bash
orbitfabric-openobsw-opensvf run \
  --operation project \
  --input-set-manifest <integration_input_manifest.json> \
  --profile <projection-profile.yaml> \
  --output-dir <output-directory>
```

### Verification projection

```bash
orbitfabric-openobsw-opensvf run \
  --operation verification_projection \
  --input-set-manifest <integration_input_manifest.json> \
  --profile <projection-profile.yaml> \
  --operation-input scenario <scenario.yaml> \
  --output-dir <output-directory>
```

When invoked through Adapter Manager, operation inputs use the manager-facing `ROLE=PATH` form and Core normalizes them for the adapter CLI protocol.

## Release artifacts

Publisher-owned stable release material is constructed with:

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

alongside the selected wheel.

A canonical `adapter-project-lock.json` is not part of publisher release membership. Project Lock belongs to the consuming project and records that project's exact selected resolution. The default tool mode still derives a lock for lifecycle and conformance proof.

## Setup from both sides

The integration documentation follows four steps:

1. **OrbitFabric-side setup**: Core input production, adapter installation and Adapter Manager lifecycle.
2. **Adapter configuration**: Projection Profile, compatibility selections and operation inputs.
3. **OpenOBSW/OpenSVF-side setup**: downstream prerequisites, generated artifact consumption and native validation.
4. **End-to-end validation**: Core conformance plus downstream-native acceptance and, where required by a release claim, runtime evidence.

See [Getting Started](docs/getting-started.md).

## Current validated compatibility baselines

Compatibility is explicit and evidence-backed.

| System | Validated baseline | Current evidence |
| --- | --- | --- |
| OrbitFabric Core | commit `4377d6656c62aa1dc19a7ed81d2de872b6b22ccd` | Integration Input Set, conformance, Adapter Manager lifecycle and release proof |
| OpenOBSW | commit `44ceb71a016f0541ff7a0aa74191e13bafdb59c1` | additive SRDB composition, materialization, target codegen/XTCE and C11 contract compile |
| `obsw-srdb` | package `0.1.0` at the validated OpenOBSW baseline | target-native composition and generation control |
| OpenSVF | commit `667d3eadcb0bbd7814ac324b99946c4ed2f11f23`, package metadata `1.0.0` | `svf validate`, native campaign load and generated Procedure import |

The current OpenSVF upstream README still lists `v0.8.0` in its compatibility table while the same validated checkout declares package version `1.0.0` in `pyproject.toml`. This adapter records the exact validated commit and observed package metadata rather than inferring compatibility from a single version label.

YAMCS is not a mandatory dependency of projection. It becomes relevant only when a runtime or ground-validation workflow explicitly uses the OpenSVF/YAMCS path.

## Validation model

A stable release is not accepted because Core conformance alone passes:

```text
Core contract conformance
        +
Adapter projection tests
        +
OpenOBSW / SRDB native compatibility
        +
OpenSVF native compatibility
        +
installed Adapter Manager lifecycle
        +
release / Project Lock proof
        +
publisher release-only artifact proof
```

Historical PoC runtime evidence remains useful for live TM/TC/YAMCS continuity, but it is not silently promoted into a current product compatibility claim.

## Repository structure

```text
src/orbitfabric_openobsw_opensvf_adapter/
    adapter implementation
    Integration Package Manifest
    Profile schema
    target resources

examples/
    reference Projection Profile

tests/
    contract, projection and lifecycle fixtures/tests

coverage/
    Integration Coverage Matrix

docs/
    architecture, setup, compatibility, evidence and release guidance

tools/
    adapter consistency and release tooling

.github/
    CI, downstream-native controls, installed lifecycle and release proof
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

## Publication boundary

The `0.1.0` source baseline can be merged only after the exact release-candidate CI is green.

Public release then requires a separate publication step:

```text
make repository public
enable GitHub immutable releases
create v0.1.0 as a draft release
attach wheel + adapter-release.json + SHA256SUMS
publish the immutable release
verify tag, asset digests and release/provenance attestation
retain final evidence
```

Merging the release branch does not by itself claim that those publication steps have happened.

## Historical PoC

The preceding engineering investigation remains available as historical evidence in the OrbitFabric OpenOBSW PoC repositories. PoC Stage numbering, experiments and runtime scaffolding are intentionally not copied wholesale into this product repository. Only durable adapter behavior, target resources, compatibility controls and reusable regression evidence are extracted.

The historical open PoC pull request remains untouched. It is evidence and collaboration history, not a release gate for this product repository.

## Project relationships

OpenOBSW and OpenSVF are independent upstream projects. This adapter is maintained as part of the OrbitFabric ecosystem and integrates with their published/native interfaces without transferring ownership of downstream semantics to OrbitFabric.

## License

Apache-2.0.
