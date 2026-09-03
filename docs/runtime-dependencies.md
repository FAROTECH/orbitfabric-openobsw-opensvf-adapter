# Runtime Dependencies

Runtime dependencies belong to the adapter package only when implemented adapter operations require them.

The OpenOBSW/OpenSVF adapter deliberately distinguishes three dependency classes:

```text
adapter runtime dependencies
    required inside the installed adapter environment

downstream validation dependencies
    required only when exercising native OpenOBSW/OpenSVF acceptance

downstream execution dependencies
    required only for a selected runtime/SIL workflow
```

## Adapter runtime dependencies

The stable package declares:

```text
PyYAML
jsonschema
rfc8785
OrbitFabric Core at exact commit
4377d6656c62aa1dc19a7ed81d2de872b6b22ccd
```

The exact OrbitFabric dependency is intentional.

The `project` operation consumes public Core-owned machine-readable integration surfaces and does not reconstruct Mission Model semantics from a source checkout.

The `verification_projection` operation additionally validates the supplied Scenario through the public OrbitFabric Scenario loader/runtime so that the adapter does not implement a second private Scenario parser. It also verifies that the Scenario Mission Model identity matches the consumed Core Integration Input Set.

Because that operation intentionally uses the OrbitFabric runtime, the adapter declares the Core dependency explicitly. It does not rely on an ambient host installation merely because Adapter Manager launched the managed environment.

## OpenOBSW is not an adapter runtime dependency

Normal adapter execution does not import or build OpenOBSW.

The `project` operation emits a contract-only C header and an additive `obsw-srdb` contribution. OpenOBSW remains an independent downstream consumer.

The OpenOBSW checkout and `obsw-srdb` package are installed only by the target-native compatibility CI job that proves downstream acceptance.

## OpenSVF is not an adapter runtime dependency

Normal `verification_projection` execution materializes OpenSVF-compatible YAML and Python assets without importing OpenSVF.

OpenSVF is installed only by the target-native compatibility control that runs:

```text
svf validate
generated campaign load through CampaignRunner.from_yaml()
generated Procedure import
```

This keeps projection independent from a downstream installation while still proving that the declared downstream baseline accepts the generated handoff.

## Runtime/SIL dependencies

Executing a generated OpenSVF campaign may additionally require:

```text
a selected OpenOBSW binary
OpenSVF simulation/runtime dependencies
optional FMU / physics resources
optional DDS configuration
optional YAMCS integration
```

Those are downstream execution dependencies, not unconditional dependencies of the adapter package.

A future runtime evidence workflow should declare the exact downstream mode it exercises instead of adding every possible OpenSVF/OpenOBSW runtime dependency to the adapter distribution.

## Dependency rule

Use the narrowest truthful dependency boundary:

```text
needed to execute adapter code
    -> declare in adapter package

needed to prove downstream acceptance
    -> install in target compatibility control

needed only for a particular target runtime
    -> document and validate in that runtime workflow
```

Do not hide required adapter dependencies in the host Core environment, and do not force downstream runtime stacks into the adapter environment when generation does not require them.
