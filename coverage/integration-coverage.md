# OpenOBSW/OpenSVF Adapter Integration Coverage

Status: initial maintainer coverage declaration for the `0.1.0.dev0` product baseline.

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
  explicit subset of Scenario -> OpenSVF verification projection
```

A complete OpenOBSW/OpenSVF feature mapping is not the denominator. The denominator is the OrbitFabric semantic surface that is applicable to the role represented by this adapter.

## Coverage model

```text
OrbitFabric Semantic Surface
        ↓
Target Applicable Surface
        ↓
Adapter Declared Scope
```

The current matrix deliberately separates project-time mission-contract projection from Scenario verification projection. A capability may be well supported by `project` and still have a narrower `verification_projection` representation.

## Matrix

| OrbitFabric capability area | Target applicable | Target representation or constraint | Adapter declared scope | Disposition | Evidence or rationale | Roadmap |
| --- | --- | --- | --- | --- | --- | --- |
| Mission identity and provenance | yes | Integration Result, contribution manifest, Verification Projection Plan provenance | in scope | FULL | Core mission id/model version and input digests are preserved and cross-checked; installed lifecycle exercises the chain | complete for current contract |
| Telemetry parameter projection | yes | OpenOBSW C contract symbol + `obsw-srdb` parameter | in scope | PARTIAL | Explicit Profile bindings are projected and target-native SRDB composition/codegen passes; unsupported Core telemetry types fail explicitly instead of being guessed | assess additional Core/target type mappings |
| Command contract projection | yes | OpenOBSW C contract symbol + PUS TC / `obsw-srdb` telecommand | in scope | FULL | PUS compatibility, APID policy, target reuse/collision and argument-contract compatibility are checked; target-native composition passes | complete for current Profile vocabulary |
| Event projection | yes | OpenOBSW C contract symbol + PUS Service 5 / `obsw-srdb` event | in scope | FULL | Core severity is mapped through explicit Profile policy and validated against target severity/subtype baseline | complete for current Profile vocabulary |
| Housekeeping packet projection | yes | PUS TM(3,25) + `obsw-srdb` HK set | in scope | PARTIAL | Core packet membership is consumed, projected telemetry fields are verified and downstream SRDB generation passes; scope is housekeeping rather than arbitrary packet families | assess additional packet roles separately |
| General non-housekeeping packet semantics | yes | target-specific PUS packet/runtime mechanisms | out of scope | OUT_OF_SCOPE | First product baseline intentionally claims HK projection only | reassess after first release |
| Spacecraft and subsystem topology | yes | OpenSVF spacecraft/equipment model and OpenOBSW application architecture | out of scope | OUT_OF_SCOPE | Adapter currently uses a verification spacecraft template and does not project the OrbitFabric subsystem graph | separate design investigation before widening scope |
| Modes and runtime mode initialization | yes | OpenOBSW mode/runtime behavior and OpenSVF observable state | out of scope | OUT_OF_SCOPE | `verification_projection` preserves mode intent as `not_projected`; adapter does not own target FSM initialization | reassess as a later explicit capability |
| Fault / FDIR runtime behavior | yes | OpenOBSW fault/runtime implementation and observable event behavior | out of scope | OUT_OF_SCOPE | Event contract projection is supported, but generating target FDIR behavior would exceed the current adapter ownership boundary | require explicit downstream FDIR contract before considering |
| Mission policies | yes | potentially target runtime/operations-specific policy mechanisms | out of scope | OUT_OF_SCOPE | No generic policy projection is claimed by this adapter | reassess only with a concrete target-owned representation |
| Core relationship families | unknown | depends on individual relationship family and target-native representation | undecided | NOT_ANALYZED | Integration Input Set is validated, but the current package declares no consumed relationship families | perform family-by-family applicability analysis |
| Scenario validation and provenance | yes | Core `ScenarioLoader` validation + Verification Projection Plan provenance | in scope | FULL | Scenario is validated by the exact Core runtime and mission identity is checked against the consumed Integration Input Set | complete for current operation contract |
| Scenario command action without arguments | yes | OpenSVF Procedure `ctx.tc()` with Profile-resolved PUS mapping | in scope | FULL | Generated Procedure is imported through native OpenSVF `CampaignRunner`; installed lifecycle exercises materialization | complete for current subset |
| Scenario command arguments | yes | target-specific encoding into PUS TC data | in scope | NOT_IMPLEMENTED | Operation blocks rather than inventing an argument encoder | define explicit target argument encoding contract |
| Profile-configured expected PUS responses | yes | OpenSVF Procedure `ctx.expect_tm()` | in scope | FULL | Expected responses are resolved from target Profile mapping and materialized into native Procedure operations | complete for current subset |
| Scenario event expectation | yes | target event identification / OpenSVF observation | in scope | NOT_IMPLEMENTED | Current PUS subtype alone is insufficient to identify the originating Core event without an explicit observation mapping | design event observation mapping |
| Scenario mode expectation | yes | target mode observation | in scope | NOT_IMPLEMENTED | Current operation records the expectation as `not_projected` | define explicit mode observation mapping |
| Scenario telemetry expectation | yes | OpenSVF parameter or TM observation | in scope | NOT_IMPLEMENTED | Current operation records parameter-level telemetry expectation as `not_projected` | evaluate native parameter assertion mapping |
| Scenario telemetry injection | unknown | possible OpenSVF/runtime injection primitive depends on target semantics | undecided | NOT_ANALYZED | No target injection mapping has yet been assessed systematically | investigate OpenSVF/runtime injection surfaces |
| Core host-side `command_status` expectation | yes | PUS acceptance/completion telemetry is related but not semantically identical | in scope | TARGET_UNSUPPORTED | Adapter explicitly refuses to equate Core host-side command status with PUS acceptance telemetry | retain semantic distinction unless a future contract defines equivalence |
| Aggregate host expectations (`data_flow`, `payload_lifecycle`, `scenario_status`) | no | these are OrbitFabric host-side aggregate evidence semantics, not target runtime primitives | out of scope | NOT_APPLICABLE | Verification plan preserves their disposition instead of manufacturing downstream evidence | none unless Core defines a portable observation contract |

## Current evidence

### Core and adapter contract evidence

The main CI matrix proves on Python 3.11 and 3.12:

```text
exact Core development baseline installation
Ruff
adapter consistency
unit / projection tests
wheel build
packaged asset ownership
MkDocs strict build
```

### OpenOBSW / SRDB native evidence

The `target-compatibility-openobsw` job pins OpenOBSW commit:

```text
44ceb71a016f0541ff7a0aa74191e13bafdb59c1
```

and proves:

```text
adapter project generation
obsw-srdb contribution load
additive composition with the native OpenOBSW SRDB
materialization round trip
existing telecommand reuse
native C header generation
native XTCE generation
C11 compilation of mission_contract.h with warnings as errors
```

### OpenSVF native evidence

The `target-compatibility-opensvf` job pins OpenSVF commit:

```text
667d3eadcb0bbd7814ac324b99946c4ed2f11f23
```

with installed package metadata `1.0.0` and proves:

```text
verification_projection generation
OpenSVF spacecraft pre-flight validation with svf validate
native CampaignRunner campaign load
generated Procedure subclass import
```

This is downstream acceptance evidence, not a claim that a full SIL campaign was executed in that job.

### Lifecycle and release evidence

The installed lifecycle and provider-neutral release proof establish:

```text
wheel installation through Adapter Manager
inventory and verify
project execution
verification_projection execution
Integration Result conformance
OpenSVF materialization
Project Lock MISSING -> install -> MATCH
second install -> NOOP / MATCH
remove -> empty inventory
```

## Summary

```text
Total rows:                         21
Analyzed rows:                      19
NOT_ANALYZED:                        2

Known target-applicable rows:       19
Target applicability unknown:        1
NOT_APPLICABLE:                      1

Declared in-scope rows:             13
FULL:                                6
PARTIAL:                             2
NOT_IMPLEMENTED:                     4
TARGET_UNSUPPORTED:                  1

Known applicable but OUT_OF_SCOPE:   5
```

Interpretation:

```text
Analysis Coverage
    strong enough to expose the remaining investigation gaps explicitly;
    relationship families and telemetry injection still need analysis.

Scope Completeness
    the first-release scope has a real implemented core, but Scenario
    projection still has four explicit implementation gaps.

Applicable Surface Coverage
    deliberately narrower than the full applicable OrbitFabric surface;
    subsystem topology, modes, FDIR, policies and non-HK packet families
    are not silently claimed.
```

No single maturity percentage is reported because it would hide the difference between deliberate scope, implementation gaps and a true target-semantic mismatch.

## Policy note

This is an OrbitFabric-maintained adapter candidate. The matrix is therefore treated as a maturity input before version and publication decisions are made, even though Integration Coverage is not a generic Core conformance requirement.
