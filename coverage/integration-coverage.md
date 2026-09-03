# OpenOBSW/OpenSVF Adapter Integration Coverage

Status: maintainer coverage declaration for the stable `0.1.0` release candidate.

This matrix describes the OrbitFabric semantic surface that has been assessed against the OpenOBSW/OpenSVF integration role, the subset deliberately claimed by this adapter, and the current implementation disposition.

It is not an OrbitFabric Core conformance contract.

## Adapter intent

```text
Target:
  OpenOBSW flight-contract / obsw-srdb integration
  plus OpenSVF verification materialization

Adapter purpose:
  project selected OrbitFabric mission contracts and verification intent
  into target-native handoff artifacts without taking ownership of
  OpenOBSW or OpenSVF runtime semantics

Declared first-release scope:
  telemetry parameter projection
  command contract projection
  event projection
  housekeeping packet projection
  traceability/provenance
  Scenario validation/provenance
  no-argument Scenario command -> OpenSVF TC projection
  Profile-configured expected PUS responses -> OpenSVF TM expectation
  explicit refusal of non-equivalent host command_status semantics
```

A complete OpenOBSW/OpenSVF feature mapping is not the denominator. The denominator is the OrbitFabric semantic surface that is applicable to the role represented by this adapter.

## Coverage model

```text
OrbitFabric Semantic Surface
        |
        v
Target Applicable Surface
        |
        v
Adapter Declared Scope
```

The matrix uses the following dispositions:

```text
FULL
PARTIAL
NOT_IMPLEMENTED
TARGET_UNSUPPORTED
NOT_APPLICABLE
NOT_ANALYZED
OUT_OF_SCOPE
```

## Matrix

| OrbitFabric semantic area | Target applicability | First-release scope | Disposition | Evidence / rationale |
| --- | --- | --- | --- | --- |
| Telemetry parameter projection | Applicable | In scope | PARTIAL | The adapter projects selected telemetry into the OpenOBSW/SRDB contribution and generated contract. Mapping is intentionally target-profile driven rather than a blanket projection of every Core telemetry semantic. |
| Command contract projection | Applicable | In scope | FULL | Selected commands are projected into the generated OpenOBSW-facing contract and additive SRDB contribution. |
| Command argument encoding | Applicable | Out of scope | OUT_OF_SCOPE | The current release does not claim a general target-owned argument encoding model. |
| Event projection | Applicable | In scope | FULL | Selected events are projected with explicit target severity mapping and target-native SRDB validation. |
| Housekeeping packet projection | Applicable | In scope | PARTIAL | The adapter projects selected housekeeping definitions into additive SRDB content. Non-housekeeping packet semantics remain separate. |
| Non-housekeeping packet semantics | Applicable | Out of scope | OUT_OF_SCOPE | Not required for the first declared role. |
| Traceability and provenance | Applicable | In scope | FULL | Integration Result mappings and source/target evidence retain projection provenance. |
| Scenario parsing and validation | Applicable | In scope | FULL | `verification_projection` consumes the required Scenario role through OrbitFabric Scenario loading and rejects unsupported semantic forms explicitly. |
| Scenario no-argument command projection | Applicable | In scope | FULL | Supported no-argument command actions materialize into OpenSVF procedure TC calls. |
| Scenario expected PUS response projection | Applicable | In scope | FULL | Profile-configured expected target responses materialize into OpenSVF TM expectations. |
| Scenario host `command_status` expectation | Applicable | In scope | TARGET_UNSUPPORTED | Host-side OrbitFabric `command_status` semantics are not automatically equivalent to PUS acceptance/completion telemetry and are rejected rather than approximated. |
| Scenario event expectation | Applicable | Out of scope | OUT_OF_SCOPE | Current release does not claim general event-expectation projection into OpenSVF. |
| Scenario mode expectation | Applicable | Out of scope | OUT_OF_SCOPE | Current release does not claim a generic OrbitFabric-mode to OpenSVF verification mapping. |
| Scenario telemetry expectation | Applicable | Out of scope | OUT_OF_SCOPE | Current release does not claim generic telemetry expectation projection. |
| Scenario telemetry injection | Applicable | Out of scope | OUT_OF_SCOPE | Current release does not claim telemetry injection semantics. |
| Subsystem topology | Applicable | Out of scope | OUT_OF_SCOPE | Useful downstream structure exists, but the current adapter role does not project generic subsystem topology. |
| Mode/state model | Applicable | Out of scope | OUT_OF_SCOPE | No stable target-owned mapping is claimed by `0.1.0`. |
| FDIR/fault behavior | Applicable | Out of scope | OUT_OF_SCOPE | Fault semantics remain target/runtime-owned and are not projected by the current release. |
| Policies/constraints | Applicable | Out of scope | OUT_OF_SCOPE | No generic policy projection is claimed. |
| Relationship families | Not applicable to current role | Out of scope | NOT_APPLICABLE | The current Core Integration Package explicitly declares no relationship-family consumption. |
| Runtime execution semantics | Not adapter-projectable | Out of scope | NOT_APPLICABLE | OpenOBSW and OpenSVF own their native runtime behavior. The adapter produces handoff and verification material rather than replacing runtime execution. |

## Summary

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

The stable `0.1.0` release candidate therefore has no known implementation hole inside its declared first-release scope.

The `PARTIAL` rows are bounded by explicit target mapping decisions rather than unfinished implementation. The `TARGET_UNSUPPORTED` row preserves a semantic mismatch instead of hiding it behind an approximate translation.

Capabilities outside the first-release scope remain visible so later releases can widen scope deliberately and attach target-native evidence rather than retroactively redefining what `0.1.0` meant.
