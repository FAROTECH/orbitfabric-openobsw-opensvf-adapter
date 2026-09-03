# Adapter Identity

The OpenOBSW/OpenSVF adapter uses several related identities. They are intentionally kept distinct because package identity, execution identity and release-source identity serve different contracts.

## Repository and package identity

```text
repository       orbitfabric-openobsw-opensvf-adapter
distribution     orbitfabric-openobsw-opensvf-adapter
python package   orbitfabric_openobsw_opensvf_adapter
console command  orbitfabric-openobsw-opensvf
```

The Python distribution and import namespace are packaging identities. The console command is the executable entry point used by the adapter execution contract.

## Execution identity

The Integration Package Manifest uses:

```text
adapter.id = orbitfabric-openobsw-opensvf
```

This identifies the adapter implementation to OrbitFabric Core. It is not a GitHub repository key or registry coordinate.

## Integration identity

The Profile and Manifest use:

```text
integration.id = orbitfabric-openobsw-opensvf
```

This identifies the target-specific integration semantics implemented by this repository.

The execution and integration identifiers are intentionally equal for this adapter. That is a local product decision, not a universal OrbitFabric rule.

## Version

The productization branch starts at:

```text
0.1.0.dev0
```

The development version is kept aligned between `pyproject.toml` and the Integration Package Manifest. The first stable `0.1.0` is reserved for the point at which target compatibility, Integration Coverage, installed lifecycle and release proof are all accepted.

The earlier PoC baseline and its still-open closure PR remain historical evidence. Their version labels do not automatically become the release state of this clean product repository.

## Source Coordinate

Release identity uses the Core-defined logical coordinate:

```text
authority
publisher
name
```

The CI currently uses local test values:

```text
local.adapter.test
farotech
openobsw-opensvf
```

These values prove provider-neutral release construction and Project Lock behavior. They are not the final publication Source Coordinate.

A publication provider such as GitHub Releases may transport the adapter release without becoming the adapter's logical identity.

## Identity consistency

The following locations must agree where their contracts require alignment:

```text
pyproject.toml
    project.name
    project.version
    project.scripts

src/orbitfabric_openobsw_opensvf_adapter/integration_package.json
    adapter.id
    adapter.version
    integration.id
    execution.argv_prefix

src/orbitfabric_openobsw_opensvf_adapter/schemas/profile-*.schema.json
    integration.id constraint

examples/profile.yaml
    integration.id

release construction
    authority
    publisher
    name
    release_version
```

Run:

```bash
python tools/check_adapter_consistency.py
```

The check catches mechanical drift. It does not decide compatibility, maturity, coverage or publication policy.
