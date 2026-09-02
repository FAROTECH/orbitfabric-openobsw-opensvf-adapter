# Adapter Readiness Checklist

Use this checklist before calling the OpenOBSW/OpenSVF adapter ready for reuse, stable release or public publication.

It complements OrbitFabric Core conformance. It does not replace it.

## 1. Identity

Current product identity:

```text
repository       orbitfabric-openobsw-opensvf-adapter
distribution     orbitfabric-openobsw-opensvf-adapter
python package   orbitfabric_openobsw_opensvf_adapter
console command  orbitfabric-openobsw-opensvf
adapter.id       orbitfabric-openobsw-opensvf
integration.id   orbitfabric-openobsw-opensvf
version          0.1.0.dev0
```

Before stable publication, still decide explicitly:

```text
final Adapter Source Coordinate
final publisher identity
stable release version transition
```

Do not infer those values from the historical PoC or from the fact that GitHub is used for development hosting.

## 2. Packaging

Confirm that:

- the adapter builds an installable wheel;
- the wheel owns exactly one namespaced `integration_package.json`;
- the Profile schema and target resources are packaged;
- the console entry point resolves from the installed distribution;
- runtime dependencies are explicit;
- installation does not depend on ambient `PYTHONPATH` or a source checkout.

The current CI proves these properties through package checks and the isolated installed lifecycle.

## 3. Core integration contract

Confirm that the package deliberately declares and implements:

```text
supported Core Integration Input Set version
required and companion Core surfaces
Integration Package Manifest
orbitfabric.adapter_cli.v1
project operation
verification_projection operation
Scenario operation-input role
Core-conformant Integration Result
```

Core remains normative for generic contract semantics.

The current exact development baseline is:

```text
4377d6656c62aa1dc19a7ed81d2de872b6b22ccd
```

## 4. Projection Profile

Confirm that target-specific projection remains explicit and reviewable:

```text
Profile schema
example Profile
source bindings
PUS settings
target allocations
flight-contract symbols
SRDB-specific settings
event severity mapping
expected target responses
intentional do_not_project bindings
```

The current Profile vocabulary admits only:

```text
telemetry
commands
events
packets
```

Do not imply support for modes, faults, policies, subsystems or relationship families unless a later Profile/implementation change deliberately adds them.

## 5. Implementation

Confirm that implementation responsibilities remain separated:

```text
Core input-set loading and integrity checks
Profile loading and validation
target baseline loading
compatibility validation
projection resolution
artifact generation
verification projection
OpenSVF materialization
Integration Result construction
I/O and hashing
```

Generic Core contract interpretation and OpenOBSW/OpenSVF-specific mapping logic must remain conceptually distinct.

## 6. OpenOBSW / SRDB compatibility

Current target-native CI pins:

```text
OpenOBSW commit 44ceb71a016f0541ff7a0aa74191e13bafdb59c1
obsw-srdb 0.1.0 at that checkout
```

Before release, confirm the evidence still proves:

```text
additive contribution load
composition with native base SRDB
materialization and reload
expected target reuse/collision behavior
native C header generation
native XTCE generation
C11 compilation of mission_contract.h
```

Any refresh to a newer OpenOBSW baseline must be treated as a compatibility change with new evidence, not as a documentation-only version bump.

## 7. OpenSVF compatibility

Current target-native CI pins:

```text
OpenSVF commit 667d3eadcb0bbd7814ac324b99946c4ed2f11f23
observed package metadata 1.0.0
```

Before release, confirm the evidence still proves:

```text
verification materialization generated
svf validate accepts generated spacecraft
zero validation errors
generated campaign loads through CampaignRunner.from_yaml()
generated Procedure subclass imports and retains expected identity
```

Do not claim full SIL execution from this static/native acceptance gate. A release that claims an executed campaign must add explicit runtime evidence naming the OpenOBSW binary and selected OpenSVF mode.

## 8. Installed lifecycle and release proof

Confirm permanent CI proves:

```text
wheel build
Adapter Manager install
inventory
verify
project execution
verification_projection execution
Integration Result conformance
OpenSVF materialization
remove
empty inventory
```

and separately:

```text
Release Descriptor construction
Project Lock construction
MISSING -> install -> MATCH
second install -> NOOP / MATCH
verify
remove
```

Keep release construction separate from provider-specific publication.

## 9. Evidence and traceability

Confirm that a user can answer:

```text
what Core input set was consumed?
what Profile was used?
what Scenario was used?
what target baseline was selected?
what OpenOBSW/SRDB artifacts were generated?
what OpenSVF assets were generated?
which source concepts map to which target elements?
what was intentionally not projected or blocked?
which exact downstream baseline accepted the output?
what exact release bytes were installed?
```

Use the Core-owned Integration Result as the primary execution evidence surface. Keep target-native, installed lifecycle and release evidence as separate layers.

## 10. Documentation from both sides

A visitor may arrive from OrbitFabric or from the downstream ecosystem.

Before publication, verify that README and docs explain:

```text
what OrbitFabric is
what OpenOBSW is
what OpenSVF is
why the integration exists
what each system owns
how to install/configure the OrbitFabric side
how to configure the adapter
what is required on the OpenOBSW/SRDB side
what is required on the OpenSVF side
which steps are required, recommended or optional
how to validate the handoff natively
what the adapter does not own
```

No side should be presented as a subordinate implementation detail of another project.

## 11. Integration Coverage

The current maintained matrix is:

```text
coverage/integration-coverage.md
```

Before stable release, review every disposition against the current code and downstream baselines.

Current summary:

```text
Total rows:                         21
Analyzed rows:                      19
NOT_ANALYZED:                        2
Declared in-scope rows:             13
FULL:                                6
PARTIAL:                             2
NOT_IMPLEMENTED:                     4
TARGET_UNSUPPORTED:                  1
Known applicable but OUT_OF_SCOPE:   5
NOT_APPLICABLE:                      1
```

The two current analysis gaps are:

```text
Core relationship-family applicability
Scenario telemetry-injection target applicability
```

The four current implementation gaps inside declared scope are:

```text
Scenario command argument encoding
Scenario event expectation mapping
Scenario mode expectation mapping
Scenario telemetry expectation mapping
```

A focused `0.1.0` may legitimately retain some gaps if they are explicitly accepted as release scope. They must not disappear from documentation through optimistic wording.

## 12. Product cleanup

Before stable/public release, search the product tree for historical construction language that should not define the product architecture, including:

```text
Dummy
Template creation instructions
internal pressure-test labels
PoC Stage numbering in active product code/resources
obsolete compatibility/version statements
```

Historical PoC references are acceptable where they are clearly labeled as history or migration evidence. Active runtime messages and target resource identities should be product-facing.

## Readiness conclusion

The current adapter is already much stronger than a code extraction: it has Core conformance, two independent downstream-native gates, installed lifecycle, release proof, balanced documentation and an explicit coverage matrix.

It is not yet called stable or public because maturity is a release decision, not a count of green checks.

The remaining work before `0.1.0` is to review the declared coverage gaps, remove residual PoC-construction language from active product assets, make the final source/publisher decision and run one final publication-readiness review against the exact release baseline.
