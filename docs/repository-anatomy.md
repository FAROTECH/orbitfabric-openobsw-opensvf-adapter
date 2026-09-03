# Repository Anatomy

This repository is a concrete OrbitFabric adapter product for the OpenOBSW/OpenSVF integration boundary. Its structure separates generic OrbitFabric contract consumption from downstream-specific projection, compatibility and evidence.

## Identity

```text
pyproject.toml
src/orbitfabric_openobsw_opensvf_adapter/integration_package.json
docs/adapter-identity.md
tools/build_release_bundle.py
tools/check_adapter_consistency.py
```

Identity covers distribution, execution, integration, version and release-source concerns without forcing them into one string.

## Packaging

```text
pyproject.toml
src/orbitfabric_openobsw_opensvf_adapter/integration_package.json
.github/workflows/ci.yml
```

The wheel owns its Integration Package Manifest and adapter-owned Profile schema/resources. Core owns the manifest contract, while this repository owns its declared compatibility and behavior.

## Core integration contract

```text
src/orbitfabric_openobsw_opensvf_adapter/integration_package.json
src/orbitfabric_openobsw_opensvf_adapter/cli.py
src/orbitfabric_openobsw_opensvf_adapter/input_set.py
src/orbitfabric_openobsw_opensvf_adapter/result.py
```

These components consume Core Integration Input Set surfaces, expose supported operations and emit Core-conformant Integration Results.

## OpenOBSW/OpenSVF projection

```text
src/orbitfabric_openobsw_opensvf_adapter/schemas/
src/orbitfabric_openobsw_opensvf_adapter/profile.py
src/orbitfabric_openobsw_opensvf_adapter/projection.py
src/orbitfabric_openobsw_opensvf_adapter/resources/
examples/profile.yaml
```

This area owns target-specific bindings and generated contributions. It must not duplicate Core semantics already available from the Integration Input Set.

## Downstream compatibility

```text
tests/compatibility/
coverage/integration-coverage.md
docs/getting-started.md
```

Compatibility controls prove the downstream assumptions that affect generated artifacts. OpenOBSW and OpenSVF remain the authority for their native formats, APIs, runtime and verification behavior.

The product repository retains only durable compatibility knowledge from the historical PoC. Stage-specific runtime scaffolding is not product architecture.

## Operations

The stable Integration Package exposes:

```text
project
verification_projection
```

`project` consumes the Core Integration Input Set and Projection Profile. `verification_projection` additionally binds one explicit Scenario resource.

A capability is advertised only when the corresponding implementation and Result semantics are lifecycle-tested.

## Conformance and tests

```text
tests/
.github/scripts/installed-lifecycle.sh
.github/scripts/release-proof.sh
.github/workflows/ci.yml
```

The test strategy separates:

```text
Core contract conformance
adapter-owned positive and negative behavior
downstream-native compatibility
installed Adapter Manager behavior
exact release and Project Lock behavior
publisher-only release construction
```

Core conformance does not substitute for OpenOBSW/OpenSVF acceptance.

## Evidence

Each adapter execution produces an Integration Result. CI also retains target compatibility, lifecycle and release evidence.

The evidence model preserves:

```text
consumed Core input identity
Projection Profile identity
operation inputs
mapping/projection provenance
generated artifact byte identity
downstream compatibility facts
release identity
installed lifecycle proof
```

Native OpenSVF campaign or YAMCS evidence remains owned by those systems and is referenced rather than redefined when used by adapter validation.

## Documentation

```text
README.md
docs/
examples/
CONTRIBUTING.md
```

Documentation is balanced between OrbitFabric users and OpenOBSW/OpenSVF users. It explains both sides of setup, the handoff boundary, compatibility claims, declared scope and release evidence.

## Automation

```text
.github/workflows/ci.yml
.github/workflows/pages.yml
.github/scripts/installed-lifecycle.sh
.github/scripts/release-proof.sh
tools/build_release_bundle.py
```

Automation covers lint, tests, Core conformance, wheel ownership, documentation, downstream-native compatibility, installed lifecycle, release construction, Project Lock checks, publisher-only release construction and evidence retention.

## Historical PoC boundary

The historical PoC remains a separate engineering evidence repository. This product repository does not import its Stage numbering, experiments or temporary runtime topology. It extracts only reusable adapter implementation, target resources, compatibility requirements and regression evidence.

## Stable release readiness

The `0.1.0` candidate makes explicit:

```text
Target Applicable Surface
Declared Adapter Scope
dispositions for applicable OrbitFabric semantics
OpenOBSW/OpenSVF compatibility baselines
downstream setup requirements
Core conformance evidence
downstream-native evidence
installed lifecycle evidence
release / Project Lock evidence
publisher release material
stable logical/source identity
```

See [Integration Coverage](integration-coverage.md), [Release Lifecycle](release-lifecycle.md) and [Adapter Readiness Checklist](adapter-readiness-checklist.md).
