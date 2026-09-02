# Evidence and Traceability

The adapter does not only generate target files. It retains enough evidence to explain what was consumed, what was projected, which exact bytes were produced and which downstream-native checks accepted those bytes.

OrbitFabric Integration Result is the primary execution evidence surface. Target-native compatibility artifacts and release/lifecycle evidence complement it rather than replacing it.

## Execution evidence

Every completed adapter operation writes:

```text
integration_result.json
```

The result retains, as applicable:

```text
adapter identity and version
operation identity
Core Integration Input Set provenance
Projection Profile provenance
operation-input provenance
generated artifact identity and SHA-256
mapping disposition and target identity
result status and integration diagnostics
```

The generic fields and semantics are governed by Core. The adapter fills them with OpenOBSW/OpenSVF-specific projection evidence.

## Project mapping traceability

For `project`, mapping records connect OrbitFabric source entities to downstream identities.

Conceptually:

```text
OrbitFabric source entity
    -> Projection Profile binding
    -> target compatibility resolution
    -> generated OpenOBSW / SRDB representation
    -> Integration Result mapping + resolution records
```

The generated artifacts currently include:

```text
flight_software/mission_contract.h
obsw_srdb_contribution/contribution_manifest.json
obsw_srdb_contribution/parameters.yaml
obsw_srdb_contribution/telecommands.yaml
obsw_srdb_contribution/hk_sets.yaml
obsw_srdb_contribution/events.yaml
```

The additive SRDB contribution manifest preserves target baseline identity, adapter identity and source provenance. It explicitly states that the contribution is not a complete SRDB.

## Verification projection provenance

For `verification_projection`, the Scenario is a required operation input in addition to the main Core Integration Input Set.

The adapter verifies that:

- the Scenario is validated through the exact OrbitFabric Core runtime;
- the Scenario Mission Model identity matches the consumed Integration Input Set;
- the target Profile remains compatible with the selected baseline;
- the Scenario file SHA-256 is retained;
- each projected, blocked or intentionally unprojected Scenario atom receives an explicit disposition.

The operation produces:

```text
verification_projection/verification_projection_plan.json
```

The plan records:

```text
Scenario id, name and SHA-256
Core input-set identity and SHA-256
Profile identity and SHA-256
adapter/integration identity
per-atom disposition
resolved target operations
blocking diagnostics
```

The OpenSVF materialization adds:

```text
verification_projection/opensvf/materialization_manifest.json
verification_projection/opensvf/opensvf/spacecraft.yaml
verification_projection/opensvf/campaigns/verification_projection_campaign.yaml
verification_projection/opensvf/procedures/verification_projection_procedure.py
```

The materialization manifest retains the plan digest and generated-file digests so the handoff remains auditable after generation.

## Artifact byte identity

Generated artifact SHA-256 values are retained in the Integration Result and materialization evidence where applicable.

Release evidence separately retains byte identity for:

```text
adapter wheel
Integration Package Manifest
Adapter Release Descriptor
Adapter Project Lock
```

Release evidence and execution evidence answer different questions. A matching release artifact does not by itself prove that a downstream accepted the generated integration, and downstream acceptance does not replace exact release identity.

## OpenOBSW / SRDB native evidence

The `target-compatibility-openobsw` CI job produces a dedicated evidence bundle under:

```text
/tmp/orbitfabric-openobsw-target-compatibility/evidence
```

The control pins OpenOBSW commit:

```text
44ceb71a016f0541ff7a0aa74191e13bafdb59c1
```

and proves native additive SRDB composition, materialization, target code generation, XTCE generation and C11 compilation of the generated mission contract.

This evidence is separate from Core conformance because it answers a different question:

> Can the declared OpenOBSW/SRDB baseline consume the target-specific output produced by this adapter?

## OpenSVF native evidence

The `target-compatibility-opensvf` CI job produces a dedicated evidence bundle under:

```text
/tmp/orbitfabric-opensvf-target-compatibility/evidence
```

The control pins OpenSVF commit:

```text
667d3eadcb0bbd7814ac324b99946c4ed2f11f23
```

with observed installed package metadata:

```text
1.0.0
```

The evidence bundle contains the Integration Result, Verification Projection Plan, materialization manifest, generated spacecraft, campaign and Procedure, plus a machine-readable target acceptance record.

The native checks are:

```text
svf validate spacecraft.yaml
CampaignRunner.from_yaml(generated_campaign)
generated Procedure subclass discovery and identity validation
```

The current validated run reports:

```text
[svf validate] OK - spacecraft.yaml (0 warning(s))
```

The job records this as downstream static/native acceptance. It does not claim that an OpenOBSW binary, FMU, DDS simulation or YAMCS runtime was exercised.

## Installed lifecycle evidence

Produced by:

```text
.github/scripts/installed-lifecycle.sh
```

The control proves that the exact built adapter can be installed into Adapter Manager, verified and executed after source installation inputs are removed.

It retains evidence for:

```text
inventory
install
verify
project execution
project Integration Result conformance
verification_projection execution
verification Integration Result conformance
OpenSVF materialization
remove
empty final inventory
```

## Release proof evidence

Produced by:

```text
.github/scripts/release-proof.sh
```

The provider-neutral release proof retains:

```text
wheel byte identity
Release Descriptor
Project Lock
pre-install MISSING state
install result
post-install MATCH state
second-install NOOP state
verify result
remove result
```

This proves exact desired state and artifact identity without asserting a public registry or provider authority that has not yet been chosen.

## Historical runtime evidence

The preceding OpenOBSW/OpenSVF PoC contains stronger runtime experiments, including representative live TM/TC and optional YAMCS continuity.

That evidence remains useful engineering history, but it is not silently promoted into the compatibility claims of this product repository. A future release that claims a live OpenSVF/OpenOBSW/YAMCS runtime path should repeat the relevant runtime control against the release's declared baselines.

## Evidence rule

Use the strongest meaningful evidence for each boundary:

```text
Core-owned contract
    -> Core conformance

adapter projection
    -> deterministic tests + Integration Result

OpenOBSW / SRDB handoff
    -> native composition/codegen/compile

OpenSVF handoff
    -> native validate/load/import

installed distribution
    -> Adapter Manager lifecycle

exact release
    -> Release Descriptor + Project Lock proof

runtime execution claim
    -> explicit runtime smoke or campaign evidence
```

Do not collapse these into one generic trust flag. A failure should remain attributable to the boundary that actually failed.
