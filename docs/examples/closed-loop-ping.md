# Closed-Loop Ping

Example 03 is the native runtime continuation of the first two examples.

It regenerates both adapter branches from the same Core Integration Input Set and Projection Profile, composes the OpenOBSW SRDB through target-owned `obsw-srdb`, builds `obsw_sim`, installs that binary into the generated OpenSVF materialization bundle and executes the generated campaign with native OpenSVF CLI.

```text
project output                    verification_projection output
      |                                      |
      v                                      v
mission_contract.h                Verification Projection Plan
SRDB contribution                 generated Procedure/Campaign
      |                                      |
      v                                      |
target-owned SRDB composition                |
      |                                      |
      v                                      |
OpenOBSW obsw_sim ---------------------------+
                         |
                         v
                  svf campaign --json
                         |
                         v
                  native CampaignReport
```

## Adapter execution

For the recommended consumer path, install the adapter through OrbitFabric Adapter Manager and select the resulting instance:

```bash
export ORBITFABRIC_ADAPTER_INSTANCE_ID=<instance-id>
```

The runner verifies that instance and executes both `project` and `verification_projection` through `orbitfabric adapter execute`. The adapter console command does not need to be installed in the host Python environment.

A direct console-command path remains available only as a contributor fallback when no Adapter Manager instance is selected.

## Validated downstream baselines

| System | Commit |
| --- | --- |
| OpenOBSW | `44ceb71a016f0541ff7a0aa74191e13bafdb59c1` |
| OpenSVF | `667d3eadcb0bbd7814ac324b99946c4ed2f11f23` |

Linux or WSL2 is required for this runtime example.

Set:

```bash
export OPENOBSW_ROOT=/path/to/openobsw
export OPENSVF_ROOT=/path/to/opensvf
```

Install the pinned downstream Python packages into the active environment, then run:

```bash
bash examples/03-closed-loop-ping/run.sh
```

The script verifies that both checkouts are at the exact validated commits and that the imported `obsw-srdb` and OpenSVF packages come from those checkouts.

## Runtime obligation

The generated OpenSVF procedure sends:

```text
PUS TC(17,1), APID 0x010
```

and verifies the Profile-authored target sequence:

```text
TM(1,1)
TM(17,2)
TM(1,7)
```

The native CampaignReport must contain four passing steps corresponding to plan operation IDs `op-0001` through `op-0004`.

The script also proves that both adapter branches consumed the same Core input-set digest and Profile digest, and that the OpenOBSW/OpenSVF source checkout states are unchanged by execution.

This does not widen OrbitFabric Scenario semantics and does not claim YAMCS, hardware or production-flight validation.

See `examples/03-closed-loop-ping/README.md` for complete prerequisites and non-claims.
