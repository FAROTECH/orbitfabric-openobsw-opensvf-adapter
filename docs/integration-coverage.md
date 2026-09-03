# Integration Coverage

Integration Coverage describes which OrbitFabric semantics are applicable to the OpenOBSW/OpenSVF integration role, which subset this adapter deliberately claims, and the disposition of each analyzed area.

It is not a count of downstream product features and it is not a generic OrbitFabric Core conformance contract.

The maintained declaration is:

```text
coverage/integration-coverage.md
```

## Coverage model

```text
OrbitFabric Semantic Surface
        -> Target Applicable Surface
        -> Adapter Declared Scope
```

### OrbitFabric Semantic Surface

The set of semantics available through the current OrbitFabric contracts and integration surfaces. Core remains authoritative for this meaning.

### Target Applicable Surface

The subset of OrbitFabric semantics that makes sense for the OpenOBSW/OpenSVF role represented by this adapter.

Applicability is architectural. A concept can be valid OrbitFabric semantics while still being outside this downstream role.

### Adapter Declared Scope

The subset this adapter promises to implement in the current release.

This separates two questions:

```text
Scope Completeness
    how completely does the adapter implement what it explicitly promises?

Applicable Surface Coverage
    how broadly does the release cover the OrbitFabric semantics applicable to the target role?
```

## Dispositions

The matrix uses:

```text
FULL
PARTIAL
NOT_IMPLEMENTED
TARGET_UNSUPPORTED
OUT_OF_SCOPE
NOT_APPLICABLE
NOT_ANALYZED
```

`TARGET_UNSUPPORTED` is used only when compatibility analysis demonstrates that the target lacks an adequate representation for the required semantic meaning. It is not a substitute for unfinished implementation.

`OUT_OF_SCOPE` means a meaningful mapping could exist, but `0.1.0` deliberately does not claim it.

## Stable 0.1.0 summary

```text
Total rows:                         21
Analyzed rows:                      21
NOT_ANALYZED:                        0
Analysis Coverage:                 100%

Known target-applicable rows:       19
NOT_APPLICABLE:                      2

Declared first-release scope:        9
FULL:                                6
PARTIAL:                             2
TARGET_UNSUPPORTED:                  1
NOT_IMPLEMENTED in declared scope:   0

Known applicable but OUT_OF_SCOPE:  10
```

The release therefore contains no known implementation hole inside its declared first-release scope.

The two `PARTIAL` areas are telemetry parameter projection and housekeeping packet projection. They are partial because the target mappings intentionally cover narrower domains than the complete Core concepts, not because the implemented path lacks evidence.

The `TARGET_UNSUPPORTED` area preserves a deliberate semantic distinction between OrbitFabric host-side `command_status` expectation and PUS acceptance/completion telemetry. The adapter refuses to manufacture an equivalence that has not been defined.

## First-release breadth

`0.1.0` is intentionally focused. It proves a coherent integration chain for:

```text
OrbitFabric mission contract
    -> OpenOBSW / obsw-srdb project artifacts

OrbitFabric Scenario
    -> validated no-argument PUS command projection
    -> Profile-declared expected PUS responses
    -> OpenSVF-native campaign / Procedure materialization
```

Applicable areas such as command argument encoding, event/mode/telemetry expectations, telemetry injection, subsystem topology, FDIR behavior and mission policies remain visible as `OUT_OF_SCOPE` rather than being hidden or approximated.

## Evidence rule

Every non-trivial disposition must remain explainable through one or more of:

```text
Core contract semantics
adapter implementation/tests
target-native compatibility evidence
explicit ownership boundary
explicit target limitation
```

Future releases should widen the matrix one semantic family at a time, first defining the target-owned meaning, then adding implementation and downstream-native evidence.

The full row-by-row rationale is maintained in [the coverage matrix](../coverage/integration-coverage.md).
