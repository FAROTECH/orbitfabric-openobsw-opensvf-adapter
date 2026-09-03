# Changelog

## 0.1.0 - Pending publication

First stable OrbitFabric-maintained source baseline for the OpenOBSW/OpenSVF adapter.

### Added

- Concrete OrbitFabric adapter identity `orbitfabric/openobsw-opensvf` with source coordinate `github.com/FAROTECH:orbitfabric/openobsw-opensvf`.
- Exact OrbitFabric Core conformance baseline at commit `4377d6656c62aa1dc19a7ed81d2de872b6b22ccd`.
- `project` operation consuming a Core Integration Input Set and Projection Profile.
- OpenOBSW-facing `mission_contract.h` generation.
- Additive `obsw-srdb` contribution generation without modifying the OpenOBSW source checkout.
- Core-conformant Integration Result with projection mappings, provenance, coverage and generated-artifact identity.
- `verification_projection` operation for the supported OrbitFabric Scenario subset.
- Explicit Verification Projection Plan separating Scenario-authored intent from Profile-authored target verification obligations.
- OpenSVF-native spacecraft, campaign and Procedure materialization.
- Target-native OpenOBSW/SRDB compatibility controls.
- Target-native OpenSVF compatibility controls.
- Isolated OrbitFabric Adapter Manager installed lifecycle validation.
- Provider-neutral Release Descriptor and Project Lock proof.
- Publisher-only release construction producing the wheel, `adapter-release.json` and `SHA256SUMS`.
- Three consumer-facing product examples:
  - Mission Contract Projection.
  - Scenario Verification Projection.
  - Closed-Loop Ping with native OpenOBSW `obsw_sim` build and OpenSVF campaign execution.
- Clean greenfield acceptance through Adapter Manager, including a native closed-loop campaign with 100% pass rate.
- Role-separated documentation for Users, Developers/Contributors and Maintainers/Publishers.
- Strict MkDocs documentation validation and GitHub Pages documentation workflow.

### Validated compatibility

| System | Validated baseline |
| --- | --- |
| OrbitFabric Core | `4377d6656c62aa1dc19a7ed81d2de872b6b22ccd` |
| OpenOBSW | `44ceb71a016f0541ff7a0aa74191e13bafdb59c1` |
| `obsw-srdb` | package `0.1.0` at the validated OpenOBSW checkout |
| OpenSVF | `667d3eadcb0bbd7814ac324b99946c4ed2f11f23`, package metadata `1.0.0` |

### Scope boundaries

The first release intentionally does not claim complete OrbitFabric Scenario equivalence in OpenSVF.

In particular:

- commands with arguments are outside the current verification projection subset;
- Core `command_status` is not reinterpreted as PUS acceptance/completion telemetry;
- Core event, telemetry and mode expectations are not silently projected into OpenSVF observations;
- Scenario time remains provenance/order information rather than target scheduling semantics;
- YAMCS execution is not part of the `0.1.0` product claim;
- hardware or production-flight qualification is not claimed.

### Publication status

This changelog entry describes the accepted `0.1.0` product scope. Until the immutable GitHub Release is published and its assets are verified, `0.1.0` remains a validated release candidate rather than an already published distribution.
