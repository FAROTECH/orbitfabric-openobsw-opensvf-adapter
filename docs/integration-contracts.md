# Integration Contracts

OrbitFabric Core is the normative reference for generic adapter contracts. This repository declares which Core surfaces the OpenOBSW/OpenSVF adapter consumes and implements the target-specific behavior behind those contracts.

## Core-owned surfaces

The adapter uses these generic lifecycle and execution surfaces:

```text
Core Integration Input Set
Projection Profile generic envelope
Integration Package Manifest
orbitfabric.adapter_cli.v1
Integration Result
Adapter Release Descriptor
Adapter Project Lock
Adapter Manager lifecycle
```

A Core-owned field, version or semantic rule is not redefined locally for downstream convenience.

## Integration Package Manifest

The packaged manifest is:

```text
src/orbitfabric_openobsw_opensvf_adapter/integration_package.json
```

It declares:

```text
adapter identity and version
integration identity
capabilities
supported Core input-set version
supported Core surfaces
Profile compatibility
execution protocol and argv prefix
operations and operation-input requirements
Integration Result compatibility
```

The Python managed-environment backend discovers exactly one `integration_package.json` owned by the installed distribution. That discovery rule is backend-specific. Manifest contents remain Core-owned.

## Supported Core input surfaces

The `0.1.0` manifest declares the Core Integration Input Set version:

```text
0.1-candidate
```

and consumes these declared surfaces:

```text
entity_index
    orbitfabric.entity_index
    format 0.1

lint_report
    orbitfabric-lint
    format v1

mission_snapshot
    orbitfabric.mission_snapshot
    format 0.1-candidate

relationship_manifest
    orbitfabric.relationship_manifest
    format 0.1-candidate
```

The input-set manifest remains the coherence boundary. The adapter does not reconstruct Mission Model semantics from filenames or parse Mission Model YAML as a private fallback API.

A Scenario used by `verification_projection` is not inserted into the main Integration Input Set. It is an explicit operation input with role:

```text
scenario
```

## Execution protocol

The Integration Package Manifest declares:

```text
orbitfabric.adapter_cli.v1
```

with installed console entry point:

```text
orbitfabric-openobsw-opensvf
```

The implementation in `src/orbitfabric_openobsw_opensvf_adapter/cli.py` supports the Core-defined execution shape:

```text
run
--operation
--input-set-manifest
--profile
--operation-input ROLE PATH
--output-dir
```

Target-specific behavior is implemented behind this protocol. The adapter does not introduce a second execution protocol.

## Operations

The stable manifest exposes:

```text
project
    operation inputs: none

verification_projection
    required operation input: scenario
```

`project` consumes the Integration Input Set and Projection Profile to generate OpenOBSW-facing contract/SRDB material plus a Core-conformant Integration Result.

`verification_projection` additionally consumes one Scenario, validates it through OrbitFabric runtime semantics and materializes the supported subset into OpenSVF-native assets.

Operation-input declaration, CLI binding and Integration Result provenance must remain consistent.

## Integration Result

Every completed operation writes:

```text
integration_result.json
```

The result is validated through Core conformance and retains, as applicable:

```text
operation status
consumed Core input provenance
Projection Profile provenance
Scenario operation-input provenance
generated artifact identity and digest
source-to-target mappings
target compatibility resolution
diagnostics
```

See [Evidence and Traceability](evidence-and-traceability.md).

## Adapter and integration identity

This product uses:

```text
adapter.id     = orbitfabric-openobsw-opensvf
integration.id = orbitfabric-openobsw-opensvf
adapter.version = 0.1.0
```

The equality of adapter and integration ids is a product choice. Release-source identity remains a separate layer:

```text
logical key       orbitfabric/openobsw-opensvf
source authority  github.com/FAROTECH
```

See [Adapter Identity](adapter-identity.md).

## Projection Profile ownership

OrbitFabric governs the generic Profile envelope. This adapter owns the OpenOBSW/OpenSVF-specific schema and mapping rules in:

```text
src/orbitfabric_openobsw_opensvf_adapter/schemas/profile-0.1.schema.json
```

Those target-specific settings include the choices required to project supported telemetry, commands, events, housekeeping and verification expectations without duplicating Core semantic authority.

See [Projection Profile and Bindings](projection-profile-and-bindings.md).
