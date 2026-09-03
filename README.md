# OrbitFabric OpenOBSW/OpenSVF Adapter

Integration adapter connecting [OrbitFabric](https://github.com/FAROTECH/orbitfabric) mission contracts with the native integration and validation surfaces provided by [OpenOBSW](https://github.com/lipofefeyt/openobsw) and [OpenSVF](https://github.com/lipofefeyt/opensvf).

OrbitFabric, OpenOBSW and OpenSVF remain independent systems. OrbitFabric Core owns generic mission and integration contracts, this adapter owns target-specific projection, and the downstream projects own their native runtime and validation semantics.

> **Release status:** `0.1.0` is the validated OrbitFabric-maintained source baseline. Public immutable `v0.1.0` release assets are a separate publication step. Until that release is published and verified, locally built artifacts are release-candidate material rather than the normal external-consumer installation path.

## Choose your path

### I want to use the adapter

Use the released adapter through **OrbitFabric Adapter Manager**.

```text
OrbitFabric Core
    -> published adapter release
    -> Adapter Manager install
    -> verify
    -> execute
    -> product examples
```

You do **not** need to clone this repository to install the adapter, run `pip install -e`, build a wheel or construct a Release Descriptor.

Start with **[Getting Started](docs/getting-started.md)**.

### I want to try the adapter

The repository contains three progressive product examples:

1. **[Mission Contract Projection](docs/examples/mission-contract-projection.md)**  
   Mission Model -> Core Integration Input Set -> OpenOBSW-facing contract and additive SRDB contribution.

2. **[Scenario Verification Projection](docs/examples/scenario-verification-projection.md)**  
   OrbitFabric Scenario -> explicit Verification Projection Plan -> OpenSVF-native assets.

3. **[Closed-Loop Ping](docs/examples/closed-loop-ping.md)**  
   Same authored inputs -> target-owned SRDB composition -> OpenOBSW `obsw_sim` -> native OpenSVF campaign -> CampaignReport.

In consumer mode the example runners use an adapter instance already installed through Adapter Manager.

Start with **[Examples](docs/examples/index.md)**.

### I want to develop or contribute

Clone the repository and use the development environment:

```bash
git clone https://github.com/FAROTECH/orbitfabric-openobsw-opensvf-adapter.git
cd orbitfabric-openobsw-opensvf-adapter

python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e ".[dev]"
```

The direct adapter console command:

```text
orbitfabric-openobsw-opensvf
```

is primarily a contributor/development surface. Normal consumers should use `orbitfabric adapter ...` through Adapter Manager.

Start with **[Developer / Contributor Guide](docs/development.md)** and [CONTRIBUTING.md](CONTRIBUTING.md).

### I maintain or publish the adapter

Release construction is a separate maintainer/publisher responsibility:

```text
accepted main commit
    -> tag
    -> wheel
    -> adapter-release.json
    -> SHA256SUMS
    -> local proof
    -> immutable GitHub Release
    -> published-asset verification
    -> external greenfield acceptance
```

A normal consumer must never need to perform these steps.

Start with **[Maintainer / Publisher Guide](docs/publishing.md)** and [Release Lifecycle](docs/release-lifecycle.md).

## What the adapter does

The current product baseline:

- consumes a coherent OrbitFabric Core Integration Input Set;
- validates an OpenOBSW/OpenSVF-specific Projection Profile;
- resolves target-specific bindings and compatibility facts;
- projects supported telemetry, housekeeping packets, commands and events;
- generates an OpenOBSW-facing C contract header;
- generates an additive `obsw-srdb` contribution without modifying the OpenOBSW checkout;
- emits Core-conformant Integration Results with provenance and coverage;
- projects the supported subset of OrbitFabric Scenario intent into an explicit Verification Projection Plan;
- materializes the plan into native OpenSVF spacecraft, campaign and Procedure assets;
- fails explicitly when required compatibility or semantic information is unavailable.

The adapter does **not** replace OpenOBSW, generate OpenOBSW runtime logic, replace OpenSVF campaign execution, redefine YAMCS semantics or make OrbitFabric Core aware of OpenOBSW/OpenSVF-specific concepts.

## Integration boundary

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
OpenOBSW-facing              OpenSVF-native
contract + SRDB              verification assets
contribution                       |
        |                          v
        v                       OpenSVF
     OpenOBSW                       |
                                   v
                             native evidence
```

The ownership rule is simple:

```text
OrbitFabric owns intent and generic contract.
The adapter owns projection.
OpenOBSW and OpenSVF own downstream execution and validation.
Evidence retains provenance across the boundary.
```

## Consumer execution model

After installing a published release through Adapter Manager, the main operations are executed through Core.

### Project

```bash
orbitfabric adapter execute "$ORBITFABRIC_ADAPTER_INSTANCE_ID" \
  --operation project \
  --input-set-manifest <integration_input_manifest.json> \
  --profile <projection-profile.yaml> \
  --output-dir <output-directory>
```

Representative outputs:

```text
integration_result.json
flight_software/mission_contract.h
obsw_srdb_contribution/
```

### Verification projection

```bash
orbitfabric adapter execute "$ORBITFABRIC_ADAPTER_INSTANCE_ID" \
  --operation verification_projection \
  --input-set-manifest <integration_input_manifest.json> \
  --profile <projection-profile.yaml> \
  --operation-input scenario=<scenario.yaml> \
  --output-dir <output-directory>
```

Representative outputs:

```text
integration_result.json
verification_projection/verification_projection_plan.json
verification_projection/opensvf/
```

The current `verification_projection` release is intentionally conservative. Unsupported Scenario semantics remain explicit rather than being silently reinterpreted.

## Adapter identity

```text
repository       orbitfabric-openobsw-opensvf-adapter
distribution     orbitfabric-openobsw-opensvf-adapter
python package   orbitfabric_openobsw_opensvf_adapter
adapter.id       orbitfabric-openobsw-opensvf
integration.id   orbitfabric-openobsw-opensvf
logical key      orbitfabric/openobsw-opensvf
version          0.1.0
```

The release is classified as an **OrbitFabric-maintained stable adapter**. It is not yet described as registry-classified official because the generic OrbitFabric publisher/registry governance layer has not been promoted.

## Validated compatibility baselines

| System | Validated baseline |
| --- | --- |
| OrbitFabric Core | `4377d6656c62aa1dc19a7ed81d2de872b6b22ccd` |
| OpenOBSW | `44ceb71a016f0541ff7a0aa74191e13bafdb59c1` |
| `obsw-srdb` | package `0.1.0` at the validated OpenOBSW baseline |
| OpenSVF | `667d3eadcb0bbd7814ac324b99946c4ed2f11f23`, package metadata `1.0.0` |

Compatibility is evidence-backed. Changing a pinned downstream baseline is not a documentation-only change.

## Validation model

The source baseline is accepted through multiple independent evidence layers:

```text
Core contract conformance
        +
adapter-owned tests
        +
OpenOBSW / SRDB native compatibility
        +
OpenSVF native compatibility
        +
installed Adapter Manager lifecycle
        +
release / Project Lock proof
        +
publisher release-only proof
        +
consumer-facing product examples
        +
native closed-loop CampaignReport evidence
```

Core conformance does not substitute for downstream-native acceptance.

## Repository structure

```text
src/
    adapter implementation and packaged resources

examples/
    user-facing reference inputs and runnable product examples

tests/
    adapter, contract and compatibility regression controls

coverage/
    Integration Coverage Matrix

docs/
    user, developer and publisher documentation

tools/
    consistency and release tooling

.github/
    CI, compatibility, lifecycle, release and product-example controls
```

## Documentation

The documentation is deliberately organized by role:

### User

- [Getting Started](docs/getting-started.md)
- [Examples](docs/examples/index.md)
- [Projection Profile and Bindings](docs/projection-profile-and-bindings.md)
- [Runtime Dependencies](docs/runtime-dependencies.md)
- [Integration Coverage](docs/integration-coverage.md)

### Developer / Contributor

- [Developer / Contributor Guide](docs/development.md)
- [Repository Anatomy](docs/repository-anatomy.md)
- [Architecture and Ownership](docs/architecture-and-ownership.md)
- [Integration Contracts](docs/integration-contracts.md)
- [Testing and Conformance](docs/testing-and-conformance.md)

### Maintainer / Publisher

- [Maintainer / Publisher Guide](docs/publishing.md)
- [Release Lifecycle](docs/release-lifecycle.md)
- [Adapter Readiness Checklist](docs/adapter-readiness-checklist.md)
- [Evidence and Traceability](docs/evidence-and-traceability.md)

Documentation is built with MkDocs and validated with `mkdocs build --strict` in CI.

## Historical PoC

The preceding engineering investigation remains historical evidence. PoC Stage numbering, experiments and temporary runtime scaffolding are intentionally not product architecture.

Only durable adapter behavior, target resources, compatibility requirements and regression evidence are retained here.

## Project relationships

OpenOBSW and OpenSVF are independent upstream projects. This adapter integrates with their native interfaces without transferring ownership of downstream semantics to OrbitFabric.

## License

Apache-2.0.
