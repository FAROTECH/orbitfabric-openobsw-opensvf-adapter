# Adapter Identity

The OpenOBSW/OpenSVF adapter uses several related identities. They are intentionally kept distinct because package identity, execution identity, logical product identity and release-source identity serve different contracts.

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

This identifies the adapter implementation to OrbitFabric Core. It is not the GitHub repository key or Source Coordinate.

## Integration identity

The Profile and Manifest use:

```text
integration.id = orbitfabric-openobsw-opensvf
```

This identifies the target-specific integration semantics implemented by this repository.

The execution and integration identifiers are intentionally equal for this adapter. That is a local product decision, not a universal OrbitFabric rule.

## Logical product identity

The stable product lineage uses:

```text
publisher = orbitfabric
name      = openobsw-opensvf
```

Logical key:

```text
orbitfabric/openobsw-opensvf
```

This identity is intended to survive ordinary changes in repository location or distribution backend.

## Version

The stable release candidate is:

```text
0.1.0
```

The version is aligned between `pyproject.toml`, the Integration Package Manifest and the runtime adapter identity used in Integration Results.

The earlier PoC baseline and `0.1.0.dev0` productization baseline remain historical evidence. Their version labels do not redefine this stable release.

## Source Coordinate

The first stable release source uses:

```text
authority = github.com/FAROTECH
publisher = orbitfabric
name      = openobsw-opensvf
```

Rendered for the current explicit-source Adapter Manager CLI:

```text
github.com/FAROTECH:orbitfabric/openobsw-opensvf
```

The source authority identifies the concrete resolution context for the first release.

It does not mean:

```text
FAROTECH = logical publisher
GitHub repository slug = logical adapter key
GitHub = universal OrbitFabric registry
```

A future source authority may change while the logical key remains:

```text
orbitfabric/openobsw-opensvf
```

## Release classification

The first stable release is classified as:

```text
OrbitFabric-maintained stable adapter
```

It is intentionally not yet described as registry-classified official. Formal official status belongs to future promoted publisher/source-authority governance rather than being self-declared by repository ownership or release bytes.

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

src/orbitfabric_openobsw_opensvf_adapter/adapter/model.py
    ADAPTER_ID
    ADAPTER_VERSION

src/orbitfabric_openobsw_opensvf_adapter/schemas/profile-*.schema.json
    integration.id constraint

examples/profile.yaml
    integration.id

release construction
    authority = github.com/FAROTECH
    publisher = orbitfabric
    name = openobsw-opensvf
    release_version = 0.1.0
```

Run:

```bash
python tools/check_adapter_consistency.py
```

The consistency check catches mechanical drift. Release tooling tests and CI additionally verify the stable Source Coordinate. Neither mechanism substitutes for compatibility, coverage or publication policy review.
