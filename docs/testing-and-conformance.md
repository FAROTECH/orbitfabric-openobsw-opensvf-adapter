# Testing and Conformance

The adapter test stack separates different questions instead of treating one green test as proof of the whole integration.

```text
unit and negative tests
    does target-specific projection work and fail closed?

Core conformance
    are the generic OrbitFabric contracts valid?

package tests
    does the wheel own the required Manifest, schema and executable entry point?

OpenOBSW / SRDB compatibility
    does the target-native SRDB ecosystem accept the project output?

OpenSVF compatibility
    does OpenSVF accept and load the verification materialization?

installed lifecycle
    can Adapter Manager install, verify, execute and remove the wheel in isolation?

release proof
    do exact Release Descriptor and Project Lock bytes identify the tested release?
```

These layers are intentionally independent. A downstream-native failure is not repaired by weakening Core conformance, and a Core contract failure is not hidden behind a successful target build.

## Main checks

The Python 3.11 and 3.12 CI matrix runs:

```text
ruff check .
python tools/check_adapter_consistency.py
pytest -q
python -m build --wheel
wheel packaged-asset verification
mkdocs build --strict
```

The adapter consistency check cross-checks:

- `pyproject.toml` version;
- Integration Package Manifest adapter version;
- console-script binding;
- Profile schema path and SHA-256;
- Profile schema integration identity;
- example Profile integration identity and declared compatibility.

## Positive projection tests

Successful controls cover the real operations:

```text
project
verification_projection
Integration Result validation
release bundle construction
```

The project operation exercises real OpenOBSW/SRDB mappings rather than a synthetic Dummy target.

## Negative controls

Unsupported or inconsistent inputs must fail closed.

Current and inherited generic controls include cases such as:

```text
tampered Core Integration Input Set fingerprint
missing required Scenario operation input
invalid release construction input
invalid or inconsistent package layout
unsupported target projection constraints
```

Target-specific failures are raised as integration diagnostics rather than being guessed or silently coerced.

Examples include unsupported telemetry type mappings, occupied target allocations, PUS compatibility mismatches, ambiguous or incompatible target telecommands and unsupported Scenario command argument encoding.

## Core conformance

Core owns the generic contracts. The adapter uses Core-owned validators for generic Integration Package Manifest, Integration Result, Adapter Release Descriptor and Adapter Project Lock behavior instead of copying or privately redefining those schemas.

The current exact Core development baseline is:

```text
4377d6656c62aa1dc19a7ed81d2de872b6b22ccd
```

If Core rejects a generic contract, fix the adapter or update its declared compatibility. Do not locally redefine the Core schema.

## Real Core producer

The stronger lifecycle controls generate the Integration Input Set through the real Core producer:

```bash
orbitfabric export integration-input-set <mission-dir> --output-dir <dir>
```

This proves the actual Core-to-adapter boundary rather than relying only on hand-authored fixtures.

## OpenOBSW / SRDB target-native compatibility

The `target-compatibility-openobsw` job pins OpenOBSW commit:

```text
44ceb71a016f0541ff7a0aa74191e13bafdb59c1
```

and installs the corresponding `obsw-srdb` package.

The control:

1. produces a real Core Integration Input Set;
2. executes the adapter `project` operation;
3. loads the generated additive SRDB contribution through native `obsw-srdb` APIs;
4. composes it with the OpenOBSW base SRDB;
5. materializes and reloads the composed database;
6. verifies projected parameter, event and HK-set identities;
7. verifies reuse of an existing compatible telecommand instead of duplicating it;
8. runs target-native C header generation;
9. runs target-native XTCE generation;
10. compiles `mission_contract.h` as C11 with `-Wall -Wextra -Werror`.

This is stronger than checking YAML syntax or comparing golden files.

## OpenSVF target-native compatibility

The `target-compatibility-opensvf` job pins OpenSVF commit:

```text
667d3eadcb0bbd7814ac324b99946c4ed2f11f23
```

whose installed package metadata is `1.0.0`.

The control:

1. produces a real Core Integration Input Set;
2. executes the adapter `verification_projection` operation with a real Scenario;
3. verifies the materialized spacecraft, campaign, Procedure and manifest exist;
4. runs the upstream `svf validate` command on the generated spacecraft configuration;
5. loads the generated campaign through native `CampaignRunner.from_yaml()`;
6. verifies OpenSVF discovers the generated `Procedure` subclass;
7. verifies the Procedure identity and title retain Scenario provenance.

The current pre-flight control passes with zero OpenSVF validation warnings.

This job intentionally does not call `CampaignRunner.run()`. Full campaign execution requires the selected OpenOBSW binary and any runtime/physics dependencies of the chosen OpenSVF configuration, so that is a separate runtime evidence claim.

## Installed lifecycle

The permanent CI proves the wheel works after installation into an Adapter Manager managed environment:

```text
build exact wheel
    -> install
    -> inventory
    -> verify
    -> remove source installation inputs
    -> execute project
    -> validate Integration Result
    -> execute verification_projection
    -> validate OpenSVF materialization
    -> remove
    -> inventory empty
```

This is deliberately stronger than an editable install or a shared development environment.

## Release proof

The provider-neutral release proof verifies:

```text
build exact wheel
    -> build Release Descriptor
    -> build Project Lock
    -> initial MISSING
    -> install exact release
    -> MATCH
    -> repeated install NOOP / MATCH
    -> verify
    -> remove
```

This proves exact desired state, not only a matching package version string.

## Debugging by layer

### Manifest or Result conformance failure

Check:

```text
declared versions
operation id
operation-input roles
Profile compatibility
supported Core surfaces
result provenance and mappings
```

### Projection failure

Check the Profile, Core source resolution, selected target baseline and integration diagnostics. Inspect the failed `integration_result.json` before adding any fallback.

### OpenOBSW / SRDB native failure

Check additive contribution semantics, target allocation compatibility, PUS tuple compatibility, SRDB code generation and C contract output. Do not weaken generic Core evidence to hide a target rejection.

### OpenSVF native failure

Check the Verification Projection Plan, generated spacecraft configuration, campaign relative paths, generated Procedure API usage and exact OpenSVF compatibility baseline.

### Package or install failure

Check the built wheel, declared runtime dependencies, unique packaged `integration_package.json` and console-script entry point.

Do not rely on the host Core environment to hide missing adapter dependencies.

### Installed verification failure

Use the Adapter Manager JSON report to identify the failing dimension:

```text
release_descriptor_integrity
manifest_integrity
manifest_conformance
execution_binding
backend_materialization
```

### Project Lock mismatch

Inspect the exact mismatch dimension. Release version, Release Descriptor digest, artifact identity, artifact digest and backend identity are intentionally distinct.

## Isolation rules

Tests must not rely on:

```text
ambient PYTHONPATH
accidental imports from the repository checkout
host-global executable discovery
undeclared runtime dependencies
provider availability during normal adapter execution
```

Isolation failures are useful findings because they expose hidden coupling before release.
