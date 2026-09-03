# Projection Profile and Bindings

The Projection Profile is where users express OpenOBSW/OpenSVF-specific projection choices without editing the OrbitFabric Mission Model.

OrbitFabric owns the generic Profile envelope. This adapter owns the schema and semantics of the target-specific settings and binding configuration.

## Files

```text
src/orbitfabric_openobsw_opensvf_adapter/schemas/profile-0.1.schema.json
examples/profile.yaml
src/orbitfabric_openobsw_opensvf_adapter/profile.py
src/orbitfabric_openobsw_opensvf_adapter/projection.py
```

The reference Profile is executable test material, not only documentation.

## Settings

The stable reference Profile declares target compatibility and projection policy explicitly:

```yaml
settings:
  compatibility:
    target_baseline: openobsw-0.7.0-obsw-srdb-0.1.0-reference
  flight_contract:
    c_prefix: OF_
  pus:
    tm_apid: 0x103
    tc_apid: 0x010
  obsw_srdb:
    event_severity_map:
      info: INFO
      warning: MEDIUM
      error: HIGH
      critical: HIGH
```

These are adapter-owned projection choices. OrbitFabric Core does not assign target meaning to the C prefix, PUS APIDs or OpenOBSW event severity names.

Settings must not redefine Mission Model semantics already supplied by Core.

## Bindings

A binding connects OrbitFabric source entities to target projection intent.

The reference Profile exercises four source domains:

```text
telemetry
packets
commands
events
```

### Telemetry

```yaml
- id: tm.obc_bus_voltage
  intent: project
  sources:
    - domain: telemetry
      id: eps.obc.bus_voltage_mv
  config:
    flight_contract:
      c_symbol: OF_TM_OBC_BUS_VOLTAGE_MV
    obsw_srdb:
      parameter_id: 0x6001
```

The adapter resolves the telemetry entity from the Core Integration Input Set, applies explicit target allocation and generates the corresponding contract/SRDB representation.

### Housekeeping packet

```yaml
- id: packet.obc_hk
  intent: project
  sources:
    - domain: packets
      id: obc_hk
  config:
    flight_contract:
      c_symbol: OF_HK_SET_OBC
    obsw_srdb:
      hk_set:
        sid: 0x05
        fields:
          - domain: telemetry
            id: eps.obc.bus_voltage_mv
```

Packet membership is taken from Core semantics and checked against the target-specific Profile choices rather than recreated as a second source of truth.

### Command

```yaml
- id: cmd.ping
  intent: project
  sources:
    - domain: commands
      id: obc.ping
  config:
    flight_contract:
      c_symbol: OF_CMD_PING
      command_id: 0x1701
    pus:
      service: 17
      subtype: 1
    expected_responses:
      - service: 1
        subtype: 1
      - service: 17
        subtype: 2
      - service: 1
        subtype: 7
```

The PUS tuple and expected responses are target projection facts. They are also used by the supported verification projection path.

### Event

```yaml
- id: event.voltage_out_of_bounds
  intent: project
  sources:
    - domain: events
      id: eps.voltage_out_of_bounds
  config:
    flight_contract:
      c_symbol: OF_EVENT_VOLTAGE_OUT_OF_BOUNDS
    obsw_srdb:
      event_id: 0x5001
```

Core event severity is translated through the explicit Profile severity map.

## `project` and `do_not_project`

The schema supports explicit projection intent. An intentional `do_not_project` decision requires a reason, keeping a deliberate omission distinguishable from an implementation gap or unresolved source.

Unsupported mappings fail closed rather than being silently approximated.

## Supported Core input surfaces

The Integration Package Manifest declares the Core surfaces consumed by the adapter. Bindings resolve against those Core-produced surfaces. A source is not accepted merely because its identifier appears in the Profile.

The adapter therefore checks both source identity and the target-specific constraints required by the selected binding.

## Operation inputs

Operation inputs are separate from the main Core Integration Input Set.

`verification_projection` declares one required file-backed role:

```text
scenario
```

The CLI receives it as:

```bash
--operation-input scenario PATH
```

The Scenario is validated through OrbitFabric runtime semantics and its identity and SHA-256 provenance are retained in the Integration Result and Verification Projection Plan.

## What is intentionally not claimed in 0.1.0

The first release does not claim generic projection for every OrbitFabric semantic family. Examples intentionally outside scope include:

```text
command argument encoding
Scenario event expectations
Scenario mode expectations
Scenario telemetry expectations
Scenario telemetry injection
subsystem topology
FDIR runtime behavior
mission policies
```

See [Integration Coverage](integration-coverage.md) for the full disposition matrix.

## Validation expectations

The repository tests at least:

```text
valid Profile accepted
invalid target configuration rejected
source binding resolves
missing source fails closed
unsupported source domain fails closed
intentional do_not_project remains explicit
projected mapping appears in Integration Result
operation-input requirements match the Manifest
OpenOBSW/SRDB accepts generated project output
OpenSVF accepts generated verification materialization
```
