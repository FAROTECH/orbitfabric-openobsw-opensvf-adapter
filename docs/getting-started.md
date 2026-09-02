# Getting Started

This guide covers the development installation path for the OpenOBSW/OpenSVF adapter and separates the OrbitFabric-side setup from downstream setup.

The adapter is still under productization. Commands documented here are kept truthful to the current repository state. Target-specific artifact names and native validation commands are expanded as the implementation is extracted from the validated PoC.

## Development baseline

The CI currently validates Adapter Manager and integration-contract behavior against this exact OrbitFabric Core commit:

```text
4377d6656c62aa1dc19a7ed81d2de872b6b22ccd
```

The package version reported by that Core commit is `1.2.0`, but the Adapter Manager surfaces used here were promoted after the public `v1.2.0` release. Development therefore pins the exact Core commit rather than implying that every `orbitfabric==1.2.0` installation contains the same lifecycle surface.

## Local adapter setup

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e ".[dev]"
python -m pip install "orbitfabric @ git+https://github.com/FAROTECH/orbitfabric.git@4377d6656c62aa1dc19a7ed81d2de872b6b22ccd"
```

Run the safe local checks:

```bash
ruff check .
python tools/check_adapter_consistency.py
pytest -q
python -m build --wheel
mkdocs build --strict
```

## OrbitFabric-side setup

The adapter consumes a Core Integration Input Set and a version-controlled Projection Profile.

A normal development flow is:

```text
OrbitFabric Mission Model
        |
        v
orbitfabric lint
        |
        v
Core Integration Input Set
        +
Projection Profile
        |
        v
orbitfabric-openobsw-opensvf
```

Core owns the Mission Model and exported integration surfaces. Do not reconstruct Core semantics by reading raw Mission Model YAML inside the adapter.

The final release workflow will document both direct CLI execution and installation through OrbitFabric Adapter Manager. Adapter Manager lifecycle proof already remains a required CI control.

## Adapter configuration

Target-specific choices belong to the Projection Profile, not to Core.

The OpenOBSW/OpenSVF Profile is expected to contain only integration-owned choices such as target naming, numeric allocations, PUS mappings, housekeeping allocation and compatibility selection. Values already owned by Core semantics should be consumed from Core surfaces rather than duplicated in the Profile.

See [Projection Profile and Bindings](projection-profile-and-bindings.md).

## Downstream-side setup

The downstream projects are independent upstreams:

- OpenOBSW: https://github.com/lipofefeyt/openobsw
- OpenSVF: https://github.com/lipofefeyt/opensvf

The productized integration distinguishes three levels of downstream setup.

### Required

Required setup is limited to what the selected adapter operation actually consumes or produces. For the `project` path this includes the OpenOBSW/OpenSVF compatibility boundary needed to generate target contributions truthfully.

The adapter must not silently assume packet-layout facts, supported PUS services, SRDB composition behavior or native API versions when generated artifacts depend on them.

### Recommended

For development and compatibility validation, use upstream checkouts of OpenOBSW and OpenSVF at the versions declared by the adapter compatibility matrix. The repository CI will materialize those dependencies reproducibly rather than requiring permanent sibling checkouts in the OrbitFabric workspace.

### Optional

OpenSVF runtime campaigns, YAMCS integration, emulation and hardware validation are optional unless a specific operation or release claim explicitly depends on them. The adapter does not require users to run a ground segment merely to project mission contracts.

## Downstream artifact consumption

The historical validated integration established two durable handoff directions:

```text
adapter
  -> OpenOBSW-facing contract/contribution
  -> OpenSVF-compatible SRDB/integration contribution
```

OpenOBSW retains runtime implementation and build ownership. OpenSVF retains SRDB/XTCE, spacecraft configuration, campaign/procedure and bridge semantics. The exact file placement and native consumption commands will be documented here as those artifacts are moved into the product package and validated against current upstream versions.

## Project operation

The public console command is:

```text
orbitfabric-openobsw-opensvf
```

The product operation shape is:

```bash
orbitfabric-openobsw-opensvf run \
  --operation project \
  --input-set-manifest <integration_input_manifest.json> \
  --profile <projection-profile.yaml> \
  --output-dir <output-directory>
```

The current development branch is replacing the synthetic Template projection with the real OpenOBSW/OpenSVF projection extracted from the PoC. Do not treat interim synthetic artifacts as downstream contracts.

## Verification projection

The second operation shape binds one explicit Scenario resource:

```bash
orbitfabric-openobsw-opensvf run \
  --operation verification_projection \
  --input-set-manifest <integration_input_manifest.json> \
  --profile <projection-profile.yaml> \
  --operation-input scenario <scenario.yaml> \
  --output-dir <output-directory>
```

This operation is being reconciled with the latest PoC work before it is declared part of the first release scope. OpenSVF remains the owner of native campaign execution and verification semantics.

## Release proof

Build a wheel:

```bash
python -m build --wheel
```

Construct a local Release Descriptor and Project Lock for development proof:

```bash
python tools/build_release_bundle.py \
  --wheel dist/orbitfabric_openobsw_opensvf_adapter-0.1.0.dev0-py3-none-any.whl \
  --authority local.adapter.test \
  --publisher farotech \
  --name openobsw-opensvf
```

These local values are test coordinates, not the final publication Source Coordinate.

## End-to-end validation model

A release is not accepted because Core conformance alone passes. The validation chain is:

```text
Core contract conformance
        +
Adapter projection tests
        +
OpenOBSW/OpenSVF native compatibility controls
        +
installed Adapter Manager lifecycle
        +
release / Project Lock proof
```

The strongest meaningful native checks are added as the target code is extracted.

## Next reading

- [Architecture and Ownership](architecture-and-ownership.md)
- [Adapter Identity](adapter-identity.md)
- [Projection Profile and Bindings](projection-profile-and-bindings.md)
- [Testing and Conformance](testing-and-conformance.md)
- [Evidence and Traceability](evidence-and-traceability.md)
- [Integration Coverage](integration-coverage.md)
- [Adapter Readiness Checklist](adapter-readiness-checklist.md)
