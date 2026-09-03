# Adapter Readiness Checklist

Use this checklist before calling the OpenOBSW/OpenSVF adapter ready for reuse, stable release or public publication.

It complements OrbitFabric Core conformance. It does not replace it.

## 1. Identity

Current stable release-candidate identity:

```text
repository       orbitfabric-openobsw-opensvf-adapter
distribution     orbitfabric-openobsw-opensvf-adapter
python package   orbitfabric_openobsw_opensvf_adapter
console command  orbitfabric-openobsw-opensvf
adapter.id       orbitfabric-openobsw-opensvf
integration.id   orbitfabric-openobsw-opensvf
version          0.1.0
logical key      orbitfabric/openobsw-opensvf
source authority github.com/FAROTECH
```

The logical publisher is `orbitfabric`. The first concrete source authority is `github.com/FAROTECH`.

GitHub hosting is therefore the first release-source context, not the adapter logical identity. The adapter is classified as OrbitFabric-maintained stable. It is not yet described as registry-classified official because generic official publisher and registry governance are not promoted.

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

The exact Core baseline validated by this release candidate is:

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

The release candidate must continue to prove:

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

The release candidate must continue to prove:

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

The stable release proof must use:

```text
authority  github.com/FAROTECH
publisher  orbitfabric
name       openobsw-opensvf
version    0.1.0
```

The publisher-only release construction must additionally prove that publication material contains:

```text
wheel
adapter-release.json
SHA256SUMS
```

and does not include a canonical `adapter-project-lock.json`.

The Project Lock is consumer-project exact desired state. It is not publisher-owned immutable release membership.

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

## 10. Documentation by role and ecosystem entry point

A visitor may arrive from OrbitFabric or from the downstream ecosystem, but the repository must also distinguish the visitor's role.

Before publication, verify that the landing page and docs provide three clear paths:

```text
USER
    install released adapter
    inspect / verify through Adapter Manager
    execute adapter operations
    try product examples
    understand downstream consumption

DEVELOPER / CONTRIBUTOR
    clone source
    editable development install
    direct adapter CLI for contributor work
    architecture / contracts / tests / compatibility

MAINTAINER / PUBLISHER
    accepted source selection
    release construction
    hashes and provenance
    immutable publication
    post-publication greenfield acceptance
```

The documentation must also explain:

```text
what OrbitFabric is
what OpenOBSW is
what OpenSVF is
why the integration exists
what each system owns
how to configure the adapter
what is required on the OpenOBSW/SRDB side
what is required on the OpenSVF side
which steps are required, recommended or optional
how to validate the handoff natively
what the adapter does not own
```

A normal user must not be instructed to build the adapter wheel or Release Descriptor locally. No downstream project should be presented as a subordinate implementation detail of another system.

## 11. Integration Coverage

The maintained matrix is:

```text
coverage/integration-coverage.md
```

Current first-release review summary:

```text
Total rows:                         21
Analyzed rows:                      21
NOT_ANALYZED:                        0
Analysis Coverage:                 100%

Known target-applicable rows:       19
NOT_APPLICABLE:                      2

Declared first-release scope:        9
FULL:                                6
PARTIAL:                             2
TARGET_UNSUPPORTED:                  1
NOT_IMPLEMENTED in declared scope:   0

Known applicable but OUT_OF_SCOPE:  10
```

The first-release scope therefore contains no known implementation hole.

The two `PARTIAL` areas are deliberately bounded project-time mappings:

```text
telemetry parameter projection
housekeeping packet projection
```

They are partial because the target mapping is narrower than the complete Core domain, not because the implemented path is unproven.

The `TARGET_UNSUPPORTED` row preserves an explicit semantic distinction:

```text
Core host-side command_status expectation
    != automatically PUS acceptance/completion telemetry
```

Target-applicable capabilities outside the first-release scope remain visible in the matrix, including command argument encoding, event/mode/telemetry expectations, telemetry injection, subsystem topology, FDIR behavior, policies and non-housekeeping packet semantics.

Do not widen `0.1.0` merely to reduce the number of `OUT_OF_SCOPE` rows. Add future semantic families only after their target-owned meaning is explicit and downstream-native evidence exists.

## 12. Product cleanup

The active product tree has been reviewed for historical construction language that should not define product architecture.

The cleanup removed or replaced active references such as:

```text
Dummy-oriented product wording
Template creation instructions in product-facing guidance
PoC Stage numbering in active code/resources
obsolete coverage statements
```

Historical PoC references remain acceptable where they are clearly identified as history or migration evidence.

The active OpenSVF verification resource is product-facing:

```text
verification_spacecraft.yaml
```

The release changelog and release notes must also describe this concrete adapter rather than the Developer Template from which the repository was bootstrapped.

## Readiness conclusion

The `0.1.0` release candidate has completed the architecture and product decisions required for stable publication readiness.

It has:

```text
stable logical identity and first source authority
public product repository
Core conformance
Python 3.11 / 3.12 checks
OpenOBSW / SRDB target-native compatibility
OpenSVF target-native compatibility
installed Adapter Manager lifecycle
provider-neutral release / Project Lock proof
publisher-only release construction
consumer product examples through Adapter Manager
native closed-loop campaign evidence
100% analysis coverage for the maintained 21-area inventory
zero known implementation holes inside declared first-release scope
role-separated User / Developer / Publisher documentation
active-product PoC/Template-language cleanup
```

The remaining boundary is controlled publication, not product design.

The operational sequence is maintained in [v0.1.0 Publication Readiness Audit](publication-readiness-audit.md). In summary:

```text
merge the exact green release-preparation candidate
record the accepted main commit
confirm accepted-main CI
confirm GitHub Immutable Releases configuration
create v0.1.0 against the exact accepted commit
build the definitive wheel, adapter-release.json and SHA256SUMS
verify the definitive bytes locally
create and verify the draft GitHub Release
publish immutably
verify tag, published asset digests and GitHub-generated release attestation
repeat external greenfield acceptance from the published assets
retain final Architecture Lab publication evidence
```

For `v0.1.0`, release provenance is the exact accepted commit, exact tag, immutable GitHub Release, verified published SHA-256 identities and the GitHub-generated release attestation. The release does not introduce an adapter-authored signing scheme or an OrbitFabric-specific signature format.

Until that publication sequence is complete, `0.1.0` is a validated stable release candidate rather than an already published release.
