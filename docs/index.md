# OrbitFabric OpenOBSW/OpenSVF Adapter

This documentation describes the OrbitFabric adapter that projects selected mission contracts and verification intent into OpenOBSW/SRDB and OpenSVF-native integration artifacts.

OrbitFabric, OpenOBSW and OpenSVF remain independent systems. OrbitFabric Core owns generic mission and integration contracts, this adapter owns target-specific projection, and the downstream projects own their native execution and validation semantics.

The `0.1.0` source baseline is validated against exact Core, OpenOBSW and OpenSVF baselines. Public distribution through an immutable GitHub Release is a separate publication step.

## Choose your path

### I want to use the adapter

Start here if you want to install a released adapter, use it with an OrbitFabric Mission Model or evaluate it through the supplied examples.

```text
published release
    -> OrbitFabric Adapter Manager install
    -> verify
    -> execute
    -> product examples
```

Go to [Getting Started](getting-started.md).

### I want to develop or contribute to the adapter

Start here if you are changing implementation, mappings, schemas, tests, compatibility controls or documentation.

```text
source checkout
    -> editable development install
    -> direct adapter CLI when useful
    -> tests / compatibility / architecture
```

Go to [Developer / Contributor Guide](development.md).

### I maintain or publish the adapter

Start here if you are selecting an accepted source commit, constructing release assets, publishing an immutable release or retaining release evidence.

```text
accepted source
    -> release assets
    -> provenance / hashes
    -> immutable GitHub Release
    -> external greenfield acceptance
```

Go to [Maintainer / Publisher Guide](publishing.md).

## Product examples

The examples are user-facing product paths, not a continuation of the historical PoC stage structure:

1. [Mission Contract Projection](examples/mission-contract-projection.md)
2. [Scenario Verification Projection](examples/scenario-verification-projection.md)
3. [Closed-Loop Ping](examples/closed-loop-ping.md)

They use Adapter Manager in consumer mode when an installed instance ID is provided.

## Integration boundary

```text
OrbitFabric owns intent and generic contract.
The adapter owns projection.
OpenOBSW and OpenSVF own downstream execution and validation.
Evidence retains provenance across the boundary.
```

## Detailed references

Developer and maintainer work may need the deeper reference material:

- [Repository Anatomy](repository-anatomy.md)
- [Adapter Identity](adapter-identity.md)
- [Architecture and Ownership](architecture-and-ownership.md)
- [Integration Contracts](integration-contracts.md)
- [Projection Profile and Bindings](projection-profile-and-bindings.md)
- [Testing and Conformance](testing-and-conformance.md)
- [Evidence and Traceability](evidence-and-traceability.md)
- [Runtime Dependencies](runtime-dependencies.md)
- [Integration Coverage](integration-coverage.md)
- [Release Lifecycle](release-lifecycle.md)
- [Adapter Readiness Checklist](adapter-readiness-checklist.md)
