# Mission Contract Projection

Example 01 is the shortest runnable path through the product adapter.

```text
reference Mission Model
    -> Core Integration Input Set
    -> Projection Profile
    -> adapter project operation
    -> OpenOBSW-facing contract + additive SRDB contribution
```

Run from a development checkout:

```bash
bash examples/01-mission-contract-projection/run.sh
```

The script uses the OrbitFabric CLI to generate the Core Integration Input Set and the public `orbitfabric-openobsw-opensvf` console command to execute `project`.

It validates the representative telemetry, housekeeping, command and event mappings carried by `examples/profile.yaml`, including:

```text
eps.obc.bus_voltage_mv -> OF_TM_OBC_BUS_VOLTAGE_MV -> parameter 0x6001
obc_hk                 -> OF_HK_SET_OBC             -> HK SID 0x05
obc.ping                -> OF_CMD_PING               -> PUS TC(17,1)
eps.voltage_out_of_bounds -> OF_EVENT_VOLTAGE_OUT_OF_BOUNDS -> event 0x5001
```

The SRDB output is an additive contribution. Complete target SRDB composition remains owned by `obsw-srdb` and is intentionally not part of this example's claim.

See the source-tree README at `examples/01-mission-contract-projection/README.md` for prerequisites, generated paths and explicit non-claims.
