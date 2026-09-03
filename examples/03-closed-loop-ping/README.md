# 03 - Closed-Loop Ping

## What this example proves

This is the advanced runtime example. It continues the same authored inputs used by Examples 01 and 02 across the native downstream boundary:

```text
same Mission Model
same Core Integration Input Set
same Projection Profile
        |
        +------------------------------+
        |                              |
        v                              v
project                    verification_projection
        |                              |
        v                              v
mission_contract.h          Verification Projection Plan
SRDB contribution           OpenSVF Procedure/Campaign
        |                              |
        v                              |
target-owned SRDB composition         |
        |                              |
        v                              |
OpenOBSW obsw_sim build                |
        +---------------+--------------+
                        |
                        v
                native OpenSVF campaign
                        |
                        v
                  PUS TC(17,1)
                  APID 0x010
                        |
                        v
                  TM(1,1)
                  TM(17,2)
                  TM(1,7)
                        |
                        v
              native CampaignReport JSON
```

The adapter still owns only projection. `obsw-srdb` owns composition, OpenOBSW owns the runtime implementation, and OpenSVF owns campaign execution and native evidence.

## Prerequisites

This example is intentionally Linux/WSL2-only because it executes the validated native downstream host-simulator path.

Required:

- Python 3.11+ with OrbitFabric Core installed;
- the OpenOBSW/OpenSVF adapter installed through OrbitFabric Adapter Manager, with its exact instance id exported as `ORBITFABRIC_ADAPTER_INSTANCE_ID`;
- CMake;
- Ninja;
- a checkout of OpenOBSW at `44ceb71a016f0541ff7a0aa74191e13bafdb59c1`;
- a checkout of OpenSVF at `667d3eadcb0bbd7814ac324b99946c4ed2f11f23`;
- the target-owned `obsw-srdb` package installed from that OpenOBSW checkout;
- OpenSVF installed from that OpenSVF checkout.

Representative consumer setup:

```bash
export ORBITFABRIC_ADAPTER_INSTANCE_ID=<installed-instance-id>
export OPENOBSW_ROOT=/path/to/openobsw
export OPENSVF_ROOT=/path/to/opensvf

orbitfabric adapter verify "$ORBITFABRIC_ADAPTER_INSTANCE_ID"
python -m pip install -e "$OPENOBSW_ROOT/srdb"
python -m pip install -e "$OPENSVF_ROOT"
```

The runner executes adapter operations through:

```text
orbitfabric adapter execute <instance-id> ...
```

so the adapter remains inside its Core-managed environment rather than being installed into the host Python environment.

For adapter contributors only, the runner retains a fallback mode using the directly installed `orbitfabric-openobsw-opensvf` console command when `ORBITFABRIC_ADAPTER_INSTANCE_ID` is not set.

The script verifies both exact downstream Git commits before running.

## Inputs

The example consumes exactly one generated Core Integration Input Set and the shared authored Profile for both downstream branches:

```text
examples/reference/mission/
examples/reference/scenarios/ping-verification.yaml
examples/profile.yaml
```

The script fails if the `project` and `verification_projection` Integration Results do not record the same Core input-set SHA-256 and Profile SHA-256.

## Run

From the repository root:

```bash
bash examples/03-closed-loop-ping/run.sh
```

The build, composed SRDB, generated OpenSVF assets and native evidence are written under `examples/.work/03-closed-loop-ping/` unless `OF_EXAMPLE_WORK_ROOT` is set.

## Generated artifacts

The run contains four distinct classes of derived material:

```text
core-input/                  OrbitFabric Core handoff
project-output/              adapter OpenOBSW-facing projection
verification-output/         adapter verification projection
assembled-srdb/              target-owned composed SRDB
openobsw-build/              native OpenOBSW build tree
native-evidence/             OpenSVF CampaignReport JSON
```

None of these generated directories is a new semantic source of truth.

## Downstream consumption

The SRDB contribution is loaded, composed and materialized with `obsw-srdb` APIs from the pinned OpenOBSW checkout. The OpenOBSW host simulator is then configured with:

```text
SRDB_DATA_DIR=<assembled-srdb>
ORBITFABRIC_CONTRACT_DIR=<project-output/flight_software>
OBSW_ENABLE_ORBITFABRIC_CONTRACT=ON
```

The generated OpenSVF spacecraft already points to `../bin/obsw_sim`. The script copies the newly built simulator into that materialization bundle and then uses native OpenSVF CLI commands:

```bash
svf validate <generated-spacecraft.yaml>
svf campaign <generated-campaign.yaml> --json <campaign-report.json>
```

## Expected result

The runtime must observe this Profile-authored target verification sequence:

```text
TM(1,1)
TM(17,2)
TM(1,7)
```

The final report must contain exactly four passing generated procedure steps corresponding to:

```text
op-0001
op-0002
op-0003
op-0004
```

A successful run prints `Example 03: PASS`.

## Evidence

The example verifies the ordered operation IDs across:

```text
Verification Projection Plan
-> materialization_manifest operation_trace
-> native OpenSVF CampaignReport JSON
```

It also verifies that the generated procedure declares no invented OrbitFabric requirement and that the OpenOBSW/OpenSVF source checkout states are unchanged by the run.

## What this example does NOT prove

A PASS does not widen the adapter's Scenario semantics.

It does not prove:

- Core `command_status == ACCEPTED` is equivalent to TM(1,1);
- the Scenario event expectation is projected;
- Scenario time drives OpenSVF waits or onboard scheduling;
- telemetry/event expectation support beyond the current subset;
- YAMCS integration;
- hardware execution;
- production flight qualification.

The TM responses verified at runtime are target obligations authored by the Projection Profile and preserved through the Verification Projection Plan.
