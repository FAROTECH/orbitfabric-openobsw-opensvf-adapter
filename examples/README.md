# Product examples

These examples exercise the public OrbitFabric OpenOBSW/OpenSVF Adapter as a product, not as a continuation of the historical PoC stage structure.

The examples preserve one ownership rule throughout:

```text
OrbitFabric owns intent and contract.
Adapter owns projection.
Downstream owns execution.
Evidence retains provenance.
```

## Examples

| Example | Purpose | Runtime boundary |
| --- | --- | --- |
| [01 - Mission Contract Projection](01-mission-contract-projection/README.md) | Project one reference Mission Model into the OpenOBSW-facing contract header, additive SRDB contribution and Integration Result. | Adapter generation only |
| [02 - Scenario Verification Projection](02-scenario-verification-projection/README.md) | Project the supported subset of one OrbitFabric Scenario into a Verification Projection Plan and OpenSVF-native assets. | Adapter generation only |
| [03 - Closed-Loop Ping](03-closed-loop-ping/README.md) | Rebuild the OpenOBSW host simulator from the same projected inputs and execute the generated OpenSVF campaign against it. | Native Linux/WSL2 downstream runtime |

## Shared authored inputs

The examples deliberately share these authored inputs:

```text
examples/reference/mission/
examples/reference/scenarios/ping-verification.yaml
examples/profile.yaml
```

The Mission Model and Scenario are OrbitFabric-authored intent. `examples/profile.yaml` is adapter/target-specific configuration. Generated Core Integration Input Sets, adapter outputs, composed SRDBs, binaries and campaign reports are build/evidence products and are not maintained as source of truth.

By default each script writes disposable output below:

```text
examples/.work/<example>/
```

Set `OF_EXAMPLE_WORK_ROOT` to place generated material elsewhere.

## Prerequisites common to Examples 01 and 02

From a development checkout:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e ".[dev]"
```

This installs the adapter console command and its exact OrbitFabric Core dependency.

Example 03 has additional downstream prerequisites documented in its own README.

## Why the examples are separate from tests

`tests/fixtures/lifecycle/` and the installed lifecycle CI control remain regression evidence. They are intentionally not the user-facing examples.

The examples use their own reference mission identity, documentation and execution scripts while exercising the same public contracts that the lifecycle tests protect.

## Scope boundary

The current `verification_projection` release projects commands without arguments when an explicit Profile PUS mapping exists. Known unsupported Scenario semantics remain visible as `not_projected`; ambiguous or unsafe projection fails closed.

In particular, the examples do not claim that Core `command_status`, event expectations, telemetry expectations, mode expectations or scenario time are equivalent to OpenSVF/PUS runtime observations. The ping Profile's expected PUS responses are target verification obligations authored by the Profile.

Housekeeping/event telemetry through YAMCS is valuable historical integration evidence, but it is intentionally not presented as Scenario verification support in these first product examples.
