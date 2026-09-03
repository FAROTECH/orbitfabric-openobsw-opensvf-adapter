# 01 - Mission Contract Projection

## What this example proves

This is the smallest complete product path through the adapter's `project` operation:

```text
OrbitFabric reference Mission Model
        +
Projection Profile
        |
        v
Core Integration Input Set
        |
        v
orbitfabric-openobsw-opensvf project
        |
        +-> flight_software/mission_contract.h
        +-> obsw_srdb_contribution/
        +-> integration_result.json
```

The example proves the reference mappings for:

- telemetry `eps.obc.bus_voltage_mv`;
- housekeeping packet `obc_hk`;
- command `obc.ping`;
- event `eps.voltage_out_of_bounds`.

## Prerequisites

Install this repository in a Python 3.11+ environment:

```bash
python -m pip install -e ".[dev]"
```

No OpenOBSW or OpenSVF checkout is required for this example.

## Inputs

The example consumes the shared authored inputs:

```text
examples/reference/mission/
examples/profile.yaml
```

The Core Integration Input Set is generated at run time. It is not a checked-in source artifact for this example.

## Run

From the repository root:

```bash
bash examples/01-mission-contract-projection/run.sh
```

Set `OF_EXAMPLE_WORK_ROOT` if you want generated output outside `examples/.work/`.

## Generated artifacts

The run creates:

```text
core-input/
project-output/
  integration_result.json
  flight_software/mission_contract.h
  obsw_srdb_contribution/
```

The script verifies that the flight contract exposes:

```text
OF_TM_OBC_BUS_VOLTAGE_MV
OF_HK_SET_OBC
OF_CMD_PING
OF_EVENT_VOLTAGE_OUT_OF_BOUNDS
```

and that the SRDB handoff is an additive contribution rather than a complete replacement SRDB.

## Downstream consumption

OpenOBSW/`obsw-srdb` owns composition of the generated contribution with a complete target SRDB. This example stops before that downstream step.

See [03 - Closed-Loop Ping](../03-closed-loop-ping/README.md) for the native composition/build/runtime path.

## Expected result

The script exits zero and prints `Example 01: PASS` after validating the generated Integration Result, contract symbols and contribution manifest.

## Evidence

`integration_result.json` is the adapter-owned traceability result for this run. The generated files themselves are disposable products of the authored Mission Model, Profile and adapter version.

## What this example does NOT prove

It does not prove:

- OpenOBSW runtime behavior;
- native SRDB composition or code generation;
- OpenSVF execution;
- YAMCS integration;
- hardware execution.

Those claims require downstream-native evidence rather than successful projection alone.
