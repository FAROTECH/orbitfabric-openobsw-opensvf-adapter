# Scenario Verification Projection

Example 02 demonstrates the semantic boundary owned by `verification_projection`.

```text
OrbitFabric Scenario
    + Core Integration Input Set
    + Projection Profile
        -> Adapter Manager installed instance
        -> Verification Projection Plan
        -> OpenSVF Procedure / Campaign / spacecraft materialization
```

For consumer execution, select an adapter installed through OrbitFabric Adapter Manager:

```bash
export ORBITFABRIC_ADAPTER_INSTANCE_ID=<instance-id>
bash examples/02-scenario-verification-projection/run.sh
```

The runner verifies the selected instance and executes `verification_projection` through `orbitfabric adapter execute`. The Scenario is supplied in the manager-facing `scenario=<path>` form and Core normalizes that operation input for the adapter CLI protocol.

When no `ORBITFABRIC_ADAPTER_INSTANCE_ID` is set, a development checkout may use the `orbitfabric-openobsw-opensvf` console command as a contributor fallback.

The reference Scenario contains one `obc.ping` command plus Core host-side expectations. The command is projectable because the Profile contains an explicit no-argument PUS mapping. The generated plan resolves:

```text
obc.ping
  -> profile mapping: PUS TC(17,1), APID 0x010
  -> profile expected responses: TM(1,1), TM(17,2), TM(1,7)
```

The plan keeps the source and target authorities distinct:

- the Scenario owns the `obc.ping` action and its Core expectations;
- the Profile owns the PUS mapping and target verification obligations;
- the adapter owns deterministic projection and diagnostics;
- OpenSVF owns the generated native primitives once materialized.

Core `command_status`, event expectation and aggregate scenario status remain `not_projected`. Scenario time is provenance-only and the generated Procedure contains no implicit `ctx.wait()`.

A successful example therefore means `executable_subset`, not semantic equivalence of the complete OrbitFabric Scenario with the OpenSVF procedure.

See `examples/02-scenario-verification-projection/README.md` for the full artifact and non-claim inventory.
