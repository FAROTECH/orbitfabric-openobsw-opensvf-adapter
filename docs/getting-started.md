# Getting Started

This guide is for **users of the adapter**.

It covers the consumer path:

```text
install OrbitFabric Core
    -> obtain a published adapter release
    -> install it through Adapter Manager
    -> verify the installed instance
    -> generate a Core Integration Input Set
    -> execute adapter operations
    -> try the product examples
```

You do **not** need to install this repository in editable mode, build a wheel, run the adapter release tooling or use the direct contributor CLI.

If you want to modify the adapter, use the [Developer / Contributor Guide](development.md). If you are preparing a release, use the [Maintainer / Publisher Guide](publishing.md).

!!! note "v0.1.0 publication status"
    The `0.1.0` source baseline is validated, but the first immutable GitHub Release is prepared as a separate publication step. Until `v0.1.0` is actually published, locally built assets are engineering/release-candidate material rather than the normal external-consumer installation path.

## Validated baselines

| System | Validated baseline |
| --- | --- |
| OrbitFabric Core | `4377d6656c62aa1dc19a7ed81d2de872b6b22ccd` |
| OpenOBSW | `44ceb71a016f0541ff7a0aa74191e13bafdb59c1` |
| `obsw-srdb` | `0.1.0` at the validated OpenOBSW checkout |
| OpenSVF | `667d3eadcb0bbd7814ac324b99946c4ed2f11f23`, package metadata `1.0.0` |

The exact Core commit matters because it contains the Adapter Manager and Integration Input Set surfaces exercised by this adapter baseline.

## 1. Create a clean consumer environment

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
```

Use an isolated Adapter Manager state directory when you want a self-contained evaluation workspace:

```bash
export ORBITFABRIC_STATE_DIR="$PWD/.orbitfabric-state"
```

## 2. Install the validated OrbitFabric Core baseline

```bash
python -m pip install \
  "git+https://github.com/FAROTECH/orbitfabric.git@4377d6656c62aa1dc19a7ed81d2de872b6b22ccd"
```

Check that Core and Adapter Manager are available:

```bash
orbitfabric --help
orbitfabric adapter list
```

A new isolated state directory should initially report no installed adapters.

## 3. Obtain the published adapter release assets

A published `v0.1.0` release contains the consumer-relevant assets:

```text
orbitfabric_openobsw_opensvf_adapter-0.1.0-py3-none-any.whl
adapter-release.json
SHA256SUMS
```

Download those exact files from the GitHub Release. Do not rebuild them locally for normal consumer use.

After publication, keep the three files together in a local release directory, for example:

```text
release-v0.1.0/
  orbitfabric_openobsw_opensvf_adapter-0.1.0-py3-none-any.whl
  adapter-release.json
  SHA256SUMS
```

## 4. Install through OrbitFabric Adapter Manager

From the directory containing the downloaded assets:

```bash
orbitfabric adapter install \
  adapter-release.json \
  --artifact orbitfabric_openobsw_opensvf_adapter-0.1.0-py3-none-any.whl
```

Then inspect the installed inventory:

```bash
orbitfabric adapter list
orbitfabric adapter list --json
```

Record the returned instance ID:

```bash
export ORBITFABRIC_ADAPTER_INSTANCE_ID=<instance-id>
```

Verify the managed installation:

```bash
orbitfabric adapter inspect "$ORBITFABRIC_ADAPTER_INSTANCE_ID"
orbitfabric adapter verify "$ORBITFABRIC_ADAPTER_INSTANCE_ID"
```

A valid installation must finish with:

```text
Result: PASSED
```

The adapter itself lives in the dedicated environment materialized by Adapter Manager. It does not need to be installed into the consumer host virtual environment.

## 5. Produce a Core Integration Input Set

The adapter consumes a coherent Core Integration Input Set, not Mission Model YAML files as a private API.

```bash
orbitfabric export integration-input-set \
  <mission-directory> \
  --output-dir <core-input-directory>
```

The generated manifest is the handoff boundary:

```text
<core-input-directory>/integration_input_manifest.json
```

## 6. Execute `project`

```bash
orbitfabric adapter execute "$ORBITFABRIC_ADAPTER_INSTANCE_ID" \
  --operation project \
  --input-set-manifest <core-input-directory>/integration_input_manifest.json \
  --profile <projection-profile.yaml> \
  --output-dir <project-output-directory>
```

A successful run produces, among other artifacts:

```text
integration_result.json
flight_software/mission_contract.h
obsw_srdb_contribution/
```

The SRDB output is additive. Complete SRDB composition remains owned by OpenOBSW/`obsw-srdb`.

## 7. Execute `verification_projection`

This operation additionally consumes one OrbitFabric Scenario resource:

```bash
orbitfabric adapter execute "$ORBITFABRIC_ADAPTER_INSTANCE_ID" \
  --operation verification_projection \
  --input-set-manifest <core-input-directory>/integration_input_manifest.json \
  --profile <projection-profile.yaml> \
  --operation-input scenario=<scenario.yaml> \
  --output-dir <verification-output-directory>
```

The output includes:

```text
integration_result.json
verification_projection/verification_projection_plan.json
verification_projection/opensvf/
```

The current release projects only the documented executable subset. Unsupported Scenario semantics remain explicit rather than being guessed.

## 8. Try the product examples

The repository provides three progressive examples:

| Example | What it proves |
| --- | --- |
| [Mission Contract Projection](examples/mission-contract-projection.md) | Core input -> adapter `project` -> OpenOBSW-facing contract and additive SRDB contribution |
| [Scenario Verification Projection](examples/scenario-verification-projection.md) | Scenario intent -> explicit Verification Projection Plan and OpenSVF-native assets |
| [Closed-Loop Ping](examples/closed-loop-ping.md) | Generated artifacts -> OpenOBSW `obsw_sim` -> native OpenSVF campaign -> CampaignReport |

For a released version, obtain the matching repository source archive or `v0.1.0` tag **only to access the example inputs and runner scripts**. Do not install the adapter from that checkout.

With `ORBITFABRIC_ADAPTER_INSTANCE_ID` set, the example runners use the already-installed Adapter Manager instance.

Examples 01 and 02 need only Core plus the installed adapter. Example 03 additionally requires the validated OpenOBSW/OpenSVF downstream checkouts and their native prerequisites.

## 9. Downstream-native consumption

OpenOBSW and OpenSVF remain independent downstream systems.

The adapter does not patch either source tree. Generated artifacts are explicit handoff material:

```text
OrbitFabric intent
    -> adapter projection
    -> OpenOBSW-facing contract / SRDB contribution
    -> OpenSVF-native verification assets
    -> downstream-native execution and evidence
```

For the exact runtime path used by the product acceptance test, see [Closed-Loop Ping](examples/closed-loop-ping.md).

## Where to go next

As a user:

- [Examples](examples/index.md)
- [Projection Profile and Bindings](projection-profile-and-bindings.md)
- [Runtime Dependencies](runtime-dependencies.md)
- [Integration Coverage](integration-coverage.md)

If you are changing the source:

- [Developer / Contributor Guide](development.md)

If you are publishing a release:

- [Maintainer / Publisher Guide](publishing.md)
