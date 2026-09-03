# OrbitFabric OpenOBSW/OpenSVF Adapter

This documentation describes the concrete OrbitFabric adapter that projects selected mission contracts and verification intent into OpenOBSW/SRDB and OpenSVF-native integration artifacts.

OrbitFabric, OpenOBSW and OpenSVF remain independent systems. OrbitFabric Core owns generic mission and integration contracts, this adapter owns target-specific projection, and the downstream projects own their native execution and validation semantics.

The stable `0.1.0` release candidate is validated against exact Core, OpenOBSW and OpenSVF baselines and is exercised through downstream-native compatibility checks, Adapter Manager installed lifecycle and exact release proof.

## Recommended path

```text
Getting Started
    -> Architecture and Ownership
    -> Adapter Identity
    -> Integration Contracts
    -> Projection Profile and Bindings
    -> Testing and Conformance
    -> Evidence and Traceability
    -> Runtime Dependencies
    -> Integration Coverage
    -> Release Lifecycle
    -> Adapter Readiness Checklist
```

If you want to understand how the clean product was extracted from the preceding engineering PoC, read [Migration from the PoC](migrating-from-poc.md).

## Integration boundary

```text
OrbitFabric owns intent and generic contract.
The adapter owns projection.
OpenOBSW and OpenSVF own downstream execution and validation.
Evidence retains provenance across the boundary.
```

Start with [Getting Started](getting-started.md) for the complete OrbitFabric-to-downstream handoff.
