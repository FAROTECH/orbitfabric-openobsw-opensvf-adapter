# Architecture and Ownership

The adapter sits between OrbitFabric Core and two downstream systems with deliberately separate ownership.

```text
OrbitFabric Core
    mission semantics
    generic integration contracts
    schemas and conformance
    Adapter Manager lifecycle

OpenOBSW/OpenSVF Adapter
    target-specific Projection Profile
    projection and materialization
    target compatibility checks
    declared Integration Coverage
    target-facing evidence

OpenOBSW
    flight software runtime
    PUS behavior
    SRDB-native integration semantics
    target build and execution

OpenSVF
    spacecraft validation
    campaign and Procedure semantics
    SIL/runtime behavior
    optional YAMCS integration
```

## Core owns generic meaning

The adapter consumes Core-owned contracts rather than creating a parallel specification.

Generic surfaces include:

```text
Core Integration Input Set
Integration Package Manifest
orbitfabric.adapter_cli.v1
Integration Result
Adapter Release Descriptor
Adapter Project Lock
Adapter Manager lifecycle
```

If Core rejects one of those generic objects, the adapter must be corrected or its compatibility declaration changed. A target-specific convenience is not a reason to redefine Core semantics locally.

## The adapter owns projection

The adapter translates validated OrbitFabric intent into downstream representations. Its responsibilities include:

```text
target-specific Profile schema
target settings and bindings
PUS and target allocation choices
OpenOBSW/SRDB contribution generation
OpenSVF verification materialization
target-specific diagnostics
downstream compatibility evidence
Integration Coverage declaration
```

The adapter does not acquire authority to reinterpret OrbitFabric semantic facts.

## OpenOBSW ownership

The adapter generates a contract-only C header and an additive `obsw-srdb` contribution. OpenOBSW and the consuming flight integration remain responsible for:

```text
runtime implementation behind generated symbols
flight application architecture
packet transport and dispatch
command execution
housekeeping runtime behavior
event emission
build integration and target execution
```

The adapter does not patch an OpenOBSW checkout or generate flight runtime logic.

## OpenSVF ownership

The adapter materializes supported Scenario intent into OpenSVF-compatible spacecraft, campaign and Procedure assets. OpenSVF remains responsible for:

```text
spacecraft validation
campaign loading and execution
Procedure runtime semantics
SIL behavior
physics/runtime dependencies
optional YAMCS bridge behavior
```

Static/native acceptance is not presented as executed SIL evidence unless a runtime control actually runs the selected target.

## Python packaging

The current Python wheel backend requires exactly one distribution-owned `integration_package.json` inside the installed adapter package:

```text
src/orbitfabric_openobsw_opensvf_adapter/
    integration_package.json
```

This discovery rule is backend-specific. Manifest contents remain governed by Core.

A future non-Python backend may materialize its execution package differently without changing the generic adapter lifecycle model.

## Runtime dependency ownership

Dependencies required to execute adapter code belong to the adapter distribution.

Downstream dependencies required only to prove OpenOBSW or OpenSVF acceptance stay in the corresponding compatibility controls. Dependencies required only for a selected SIL/runtime path remain downstream workflow dependencies.

See [Runtime Dependencies](runtime-dependencies.md).

## Release source versus execution

Release transport is separate from installed execution:

```text
release source
    -> exact resolved release
    -> Adapter Manager installation
    -> installed execution endpoint
    -> orbitfabric.adapter_cli.v1
```

For `0.1.0`, the first concrete source authority is:

```text
github.com/FAROTECH
```

while the logical adapter key is:

```text
orbitfabric/openobsw-opensvf
```

GitHub therefore supplies the first release-source context. It does not become the adapter execution protocol or a universal OrbitFabric registry.

## Historical Template and PoC boundary

The repository was created from the public Adapter Developer Template and productized from validated PoC evidence. Neither construction history is normative product architecture.

The active repository is the concrete adapter product. The Template remains reusable developer guidance, and the PoC remains historical engineering evidence.
