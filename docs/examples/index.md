# Examples

The repository includes three runnable product examples built on the public adapter CLI and the same authored reference inputs.

```text
OrbitFabric owns intent and contract.
Adapter owns projection.
Downstream owns execution.
Evidence retains provenance.
```

The examples are deliberately separate from `tests/fixtures/`. Tests protect regression behavior; examples provide a user-facing path with explicit prerequisites, generated outputs, evidence and non-claims.

## Shared inputs

All three examples use:

```text
examples/reference/mission/
examples/profile.yaml
```

Examples 02 and 03 also use:

```text
examples/reference/scenarios/ping-verification.yaml
```

Core Integration Input Sets and all downstream artifacts are regenerated when the examples run. They are not maintained as authored truth.

## Progression

| Example | Boundary crossed | Main evidence |
| --- | --- | --- |
| [Mission Contract Projection](mission-contract-projection.md) | OrbitFabric Core -> adapter | Integration Result, `mission_contract.h`, additive SRDB contribution |
| [Scenario Verification Projection](scenario-verification-projection.md) | Scenario intent -> explicit target verification projection | Verification Projection Plan and OpenSVF materialization manifest |
| [Closed-Loop Ping](closed-loop-ping.md) | Adapter outputs -> native OpenOBSW/OpenSVF runtime | Native OpenSVF CampaignReport JSON |

Start with Example 01. Example 02 explains the verification semantic boundary. Example 03 adds Linux/WSL2 downstream prerequisites and proves the complete ping runtime slice.

## Scope

The verification projection in `0.1.0` is intentionally conservative. A no-argument command can be projected when an explicit Profile PUS mapping exists. Unsupported Scenario semantics remain visible as `not_projected`; projection that would require a semantic guess is blocked.

The Profile's expected PUS responses are target-specific verification obligations. They are not new OrbitFabric Scenario semantics.

Historical YAMCS housekeeping and event evidence is not promoted into these examples because current `verification_projection` does not support telemetry/event expectations as equivalent target observations.
