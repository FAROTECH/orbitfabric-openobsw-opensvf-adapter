# 02 - Scenario Verification Projection

## What this example proves

This example exercises the adapter's `verification_projection` operation with the reference `obc.ping` Scenario.

```text
OrbitFabric Scenario
        +
Core Integration Input Set
        +
Projection Profile
        |
        v
Verification Projection Plan
        |
        +-> generated OpenSVF Procedure
        +-> generated OpenSVF Campaign
        +-> generated spacecraft.yaml
```

The important result is the semantic separation recorded in the plan:

```text
Scenario-authored command action
  obc.ping
        |
        v
Profile target mapping
  PUS TC(17,1), APID 0x010
        |
        v
Profile-authored target verification obligations
  TM(1,1)
  TM(17,2)
  TM(1,7)
```

The three TM expectations are not reinterpreted as OrbitFabric Scenario expectations.

## Prerequisites

Install this repository in a Python 3.11+ environment:

```bash
python -m pip install -e ".[dev]"
```

OpenSVF itself is not required merely to generate the materialization.

## Inputs

The example shares:

```text
examples/reference/mission/
examples/reference/scenarios/ping-verification.yaml
examples/profile.yaml
```

The Scenario deliberately contains Core host-side expectations that are outside the 0.1.0 target projection subset. They remain visible in the plan as `not_projected`.

## Run

From the repository root:

```bash
bash examples/02-scenario-verification-projection/run.sh
```

## Generated artifacts

The run creates:

```text
core-input/
verification-output/
  integration_result.json
  verification_projection/
    verification_projection_plan.json
    opensvf/
      materialization_manifest.json
      procedures/verification_projection_procedure.py
      campaigns/verification_projection_campaign.yaml
      opensvf/spacecraft.yaml
```

## Expected result

The script verifies that:

- the plan status is `executable_subset`;
- the single source action `obc.ping` is projected;
- Core `command_status`, event and scenario-status expectations remain `not_projected`;
- the plan contains exactly one `pus_tc` operation and three `expect_pus_tm` operations;
- the TC resolves to APID `0x010`, service `17`, subtype `1`;
- the three TM operations originate from `profile_expected_response`;
- scenario time is recorded as provenance only;
- generated OpenSVF code contains no implicit `ctx.wait()` scheduling.

A successful run prints `Example 02: PASS`.

## Downstream consumption

The generated Procedure and Campaign are native OpenSVF assets. OpenSVF owns their execution semantics. This example intentionally stops before starting an OpenOBSW process or running the campaign.

Use [03 - Closed-Loop Ping](../03-closed-loop-ping/README.md) for the native runtime continuation.

## Evidence

The main inspectable evidence is:

```text
verification_projection_plan.json
materialization_manifest.json
integration_result.json
```

Together they preserve source Scenario identity, Core input digest, Profile digest, atom disposition and plan-operation to OpenSVF-step traceability.

## What this example does NOT prove

It does not claim that the complete OrbitFabric Scenario executes in OpenSVF.

Specifically, it does not project:

- Core `command_status` into PUS TM(1,1);
- event expectations from PUS service/subtype alone;
- scenario status into target runtime evidence;
- scenario `t` into `ctx.wait`, PUS Service 11 or onboard scheduling;
- command arguments;
- telemetry, mode or event observations beyond the documented subset.
