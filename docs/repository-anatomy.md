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

This area owns target-specific bindings and generated contributions. It must not duplicate Core semantics that are already available from the Integration Input Set.

## Downstream compatibility

```text
tests/compatibility/
coverage/integration-coverage.md
docs/getting-started.md
```

Compatibility controls prove the downstream assumptions that affect generated artifacts. OpenOBSW and OpenSVF remain the authority for their native formats, APIs, runtime and verification behavior.

The productization work extracts only durable compatibility knowledge from the historical PoC. Stage-specific runtime scaffolding is not treated as product architecture.

## Operations

The repository is being converged around two operation shapes:

```text
project
verification_projection
```

`project` consumes the Core Integration Input Set and Projection Profile. `verification_projection` additionally binds one explicit Scenario resource. A capability is advertised only when the corresponding implementation and Result semantics are lifecycle-tested.

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
```

Core conformance does not substitute for OpenOBSW/OpenSVF acceptance.

## Evidence

Each adapter execution produces an Integration Result. CI also retains lifecycle and release evidence.

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

## Developer experience

```text
README.md
docs/
examples/
CONTRIBUTING.md
tools/check_adapter_consistency.py
```

Documentation is intentionally balanced between OrbitFabric users and OpenOBSW/OpenSVF users. A complete integration guide explains both sides of setup and the handoff between them.

## Automation

```text
.github/workflows/ci.yml
.github/scripts/installed-lifecycle.sh
.github/scripts/release-proof.sh
tools/build_release_bundle.py
```

Automation covers lint, tests, Core conformance, wheel ownership, documentation, installed lifecycle, release construction, Project Lock checks and evidence retention.

## Historical PoC boundary

The historical PoC remains a separate engineering evidence repository. This product repository does not import its Stage numbering, experiments or temporary runtime topology. It extracts only reusable adapter implementation, target resources, compatibility requirements and regression evidence.

## Readiness

Before a stable release, the repository must make explicit:

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
```

See [Integration Coverage](integration-coverage.md) and [Adapter Readiness Checklist](adapter-readiness-checklist.md).
