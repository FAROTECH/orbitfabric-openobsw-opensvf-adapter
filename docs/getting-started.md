# Getting Started

This guide covers installation and the complete handoff from OrbitFabric through the adapter into OpenOBSW/SRDB and OpenSVF-native assets.

The `0.1.0` operations, compatibility baselines and release identity documented here are implemented and exercised by CI. Repository visibility and published release assets are separate distribution states and do not change the adapter semantics described below.

## Validated baselines

| System | Baseline used by CI |
| --- | --- |
| OrbitFabric Core | `4377d6656c62aa1dc19a7ed81d2de872b6b22ccd` |
| OpenOBSW | `44ceb71a016f0541ff7a0aa74191e13bafdb59c1` |
| `obsw-srdb` | `0.1.0` at the validated OpenOBSW checkout |
| OpenSVF | `667d3eadcb0bbd7814ac324b99946c4ed2f11f23`, installed package metadata `1.0.0` |

The OrbitFabric Core checkout above reports package version `1.2.0`, but it contains integration lifecycle seams promoted after the public v1.2.0 release. The adapter therefore pins the exact Core commit instead of implying that every `orbitfabric==1.2.0` installation has the same surface.

OpenSVF has a similar documentation/version observation in the other direction: its validated checkout declares package version `1.0.0` while its README compatibility table still states `v0.8.0`. The adapter records exact commit evidence rather than resolving that upstream discrepancy on OpenSVF's behalf.

## 1. Local adapter setup

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e ".[dev]"
```

The adapter package declares the exact Core dependency it requires.

Run the repository checks:

```bash
ruff check .
python tools/check_adapter_consistency.py
pytest -q
python -m build --wheel
mkdocs build --strict
```

## 2. OrbitFabric-side setup

The adapter consumes a coherent Core Integration Input Set and a version-controlled Projection Profile. It does not parse Mission Model YAML as a private semantic API.

Create the Core input set:

```bash
orbitfabric export integration-input-set <mission-dir> \
  --output-dir <core-input-dir>
```

A successful projection-capable input set contains:

```text
integration_input_manifest.json
mission_snapshot.json
entity_index.json
relationship_manifest.json
lint_report.json
model_summary.json
```

The manifest is the coherence boundary. Passing individual files to the adapter or reconstructing semantic identities from file names is not supported.

## 3. Adapter configuration

Target-specific choices belong to the Projection Profile, not to Core.

The Profile carries integration-owned information such as:

- target numeric allocations;
- target naming where it differs from Core identity;
- PUS service/subtype and APID choices;
- housekeeping SID and field projection choices;
- event severity mapping toward the target;
- expected protocol responses used by verification projection;
- target compatibility selection.

Core-owned values such as telemetry semantics, command arguments, event severity and packet membership are consumed from the Core Integration Input Set rather than duplicated as a second semantic authority.

See [Projection Profile and Bindings](projection-profile-and-bindings.md).

## 4. Run the project operation

```bash
orbitfabric-openobsw-opensvf run \
  --operation project \
  --input-set-manifest <core-input-dir>/integration_input_manifest.json \
  --profile <projection-profile.yaml> \
  --output-dir <output-dir>
```

A successful run produces:

```text
<output-dir>/
  integration_result.json
  flight_software/
    mission_contract.h
  obsw_srdb_contribution/
    contribution_manifest.json
    parameters.yaml
    telecommands.yaml
    hk_sets.yaml
    events.yaml
```

The SRDB output is a contribution, not a replacement database. Its manifest declares:

```text
mode = additive
complete_srdb = false
```

## 5. OpenOBSW / SRDB-side setup

OpenOBSW remains the owner of flight runtime behavior and build integration. The adapter supplies a contract header and an additive SRDB contribution.

### Required

If you want to consume the generated SRDB contribution, use an `obsw-srdb` implementation compatible with the adapter's declared baseline. The current CI baseline is taken from:

```text
OpenOBSW commit 44ceb71a016f0541ff7a0aa74191e13bafdb59c1
obsw-srdb 0.1.0
```

For a local compatibility exercise:

```bash
git clone https://github.com/lipofefeyt/openobsw.git
cd openobsw
git checkout 44ceb71a016f0541ff7a0aa74191e13bafdb59c1
python -m pip install -e ./srdb
```

The native composition model used by CI is:

```python
from pathlib import Path

from obsw_srdb.composition import SRDBComposer, SRDBContributionLoader, SRDBMaterializer
from obsw_srdb.loader import SRDBLoader

base = SRDBLoader.load(Path("openobsw/srdb/data"))
contribution = SRDBContributionLoader.load(Path("<output-dir>/obsw_srdb_contribution"))
composed = SRDBComposer.compose(base, [contribution])
SRDBMaterializer.write(composed, Path("<materialized-srdb>"))
```

This composition step is deliberately downstream-native. The adapter does not privately recreate SRDB composition semantics.

The generated `mission_contract.h` is a contract-only C artifact. The consuming OpenOBSW integration decides where it belongs in the target build and implements the runtime behavior behind the declared symbols.

### Recommended native checks

The repository CI additionally proves that the materialized SRDB can drive the target code generators:

```bash
python -m obsw_srdb.codegen \
  --data-dir <materialized-srdb> \
  --output <srdb-generated.h>

python -m obsw_srdb.codegen \
  --data-dir <materialized-srdb> \
  --xtce-output <mission.xtce>
```

The generated `mission_contract.h` is also compiled as C11 with `-Wall -Wextra -Werror` in the target compatibility control.

### Optional

Building or executing a specific OpenOBSW host, QEMU, Renode or hardware target is not required merely to generate or validate the integration contribution. Runtime evidence is a separate claim and must name the target that was actually exercised.

## 6. Run verification projection

The second operation consumes one explicit OrbitFabric Scenario resource:

```bash
orbitfabric-openobsw-opensvf run \
  --operation verification_projection \
  --input-set-manifest <core-input-dir>/integration_input_manifest.json \
  --profile <projection-profile.yaml> \
  --operation-input scenario <scenario.yaml> \
  --output-dir <output-dir>
```

The operation writes a Verification Projection Plan and then materializes the executable subset into OpenSVF-native assets:

```text
<output-dir>/
  integration_result.json
  verification_projection/
    verification_projection_plan.json
    opensvf/
      materialization_manifest.json
      opensvf/
        spacecraft.yaml
      campaigns/
        verification_projection_campaign.yaml
      procedures/
        verification_projection_procedure.py
```

The generated Procedure uses native `Procedure` / `ProcedureContext` primitives, including `ctx.tc()` and `ctx.expect_tm()` where the Scenario can be projected into the currently supported subset.

## 7. OpenSVF-side setup

OpenSVF remains the owner of spacecraft validation, campaign loading, Procedure execution, SIL behavior and optional YAMCS integration.

### Required for native acceptance validation

Use a compatible OpenSVF installation. The current CI pins:

```text
commit 667d3eadcb0bbd7814ac324b99946c4ed2f11f23
package metadata 1.0.0
```

A matching local setup is:

```bash
git clone https://github.com/lipofefeyt/opensvf.git
cd opensvf
git checkout 667d3eadcb0bbd7814ac324b99946c4ed2f11f23
python -m pip install -e .
```

Run the OpenSVF-native pre-flight validator on the generated spacecraft asset:

```bash
svf validate \
  <output-dir>/verification_projection/opensvf/opensvf/spacecraft.yaml
```

The CI baseline passes with zero warnings.

Then verify that OpenSVF can load the generated campaign and discover the generated Procedure:

```python
from svf.campaign.campaign_runner import CampaignRunner

runner = CampaignRunner.from_yaml(
    "<output-dir>/verification_projection/opensvf/campaigns/verification_projection_campaign.yaml"
)
assert runner._procedures
```

This is a native downstream acceptance check. It loads the campaign through OpenSVF's own `CampaignRunner` and imports the generated `Procedure` subclass.

### Recommended

Treat the generated materialization as a reviewable handoff. Keep `materialization_manifest.json` with the campaign/procedure assets so the Verification Projection Plan digest, Scenario provenance and generated-file digests remain inspectable.

### Optional runtime execution

Executing the campaign is a separate step:

```bash
svf campaign \
  <output-dir>/verification_projection/opensvf/campaigns/verification_projection_campaign.yaml \
  --report
```

A real campaign run requires the OpenOBSW binary and any physics/runtime resources expected by the selected OpenSVF spacecraft configuration. Do not interpret successful static/native acceptance as proof that a particular SIL, emulation or hardware target was executed.

YAMCS is optional. It is relevant only when the selected OpenSVF workflow uses the YAMCS bridge/ground path.

## 8. Adapter Manager lifecycle

The adapter is exercised as an installed distribution, not only from its source tree.

The CI control proves:

```text
build wheel
  -> construct exact release descriptor
  -> Adapter Manager install
  -> inventory
  -> verify
  -> project execution
  -> Integration Result conformance
  -> verification_projection execution
  -> OpenSVF materialization
  -> remove
  -> empty inventory
```

The provider-neutral release proof additionally exercises:

```text
Project Lock check = MISSING
  -> install from exact lock
  -> MATCH
  -> second install
  -> NOOP / MATCH
  -> verify
  -> remove
```

The stable release identity is:

```text
logical key        orbitfabric/openobsw-opensvf
source authority   github.com/FAROTECH
Source Coordinate  github.com/FAROTECH:orbitfabric/openobsw-opensvf
release version    0.1.0
```

The publisher-only release proof separately constructs the wheel, `adapter-release.json` and `SHA256SUMS` without treating a Project Lock as publisher release membership.

## 9. End-to-end validation model

A release is not accepted because one side alone passes:

```text
Core contract conformance
        +
Adapter projection tests
        +
OpenOBSW / SRDB native compatibility
        +
OpenSVF native compatibility
        +
installed Adapter Manager lifecycle
        +
release / Project Lock proof
        +
publisher release-only artifact proof
```

Historical PoC evidence also demonstrates representative live OpenOBSW/OpenSVF/YAMCS continuity. That evidence remains historical until a product release deliberately repeats or claims the corresponding runtime path.

## Next reading

- [Architecture and Ownership](architecture-and-ownership.md)
- [Adapter Identity](adapter-identity.md)
- [Projection Profile and Bindings](projection-profile-and-bindings.md)
- [Testing and Conformance](testing-and-conformance.md)
- [Evidence and Traceability](evidence-and-traceability.md)
- [Integration Coverage](integration-coverage.md)
- [Adapter Readiness Checklist](adapter-readiness-checklist.md)
