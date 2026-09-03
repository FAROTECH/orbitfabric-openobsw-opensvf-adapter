# v0.1.0 Publication Readiness Audit

Audit date: **2026-09-03**  
Final status: **COMPLETED / P1-P13 PASS**

This document is the completed publication audit for the first public `v0.1.0` distribution of the OrbitFabric OpenOBSW/OpenSVF Adapter.

The publication process is closed. The release is published, immutable, provider-attested and externally accepted from a clean consumer workspace.

## Executive conclusion

```text
accepted product
    -> accepted main commit
    -> exact signed v0.1.0 tag
    -> exact release assets
    -> local byte verification
    -> verified draft GitHub Release
    -> immutable publication
    -> published-byte verification
    -> GitHub release-attestation verification
    -> external greenfield acceptance
    -> Architecture Lab evidence retention
```

Result:

```text
OpenOBSW/OpenSVF Adapter v0.1.0
PUBLICATION ACCEPTED
EXTERNAL GREENFIELD ACCEPTED
P1-P13 PASS
```

## Final release identity

Repository:

```text
FAROTECH/orbitfabric-openobsw-opensvf-adapter
```

Logical adapter key:

```text
orbitfabric/openobsw-opensvf
```

Source Coordinate:

```text
github.com/FAROTECH:orbitfabric/openobsw-opensvf
```

Accepted release source commit:

```text
8f26955e573d6ea5917ece927742aaf9ede30365
```

Tag:

```text
v0.1.0
```

Annotated tag object:

```text
02003e4d1457880ba05bcaef21c2e6c5e2e6e18c
```

Public release:

```text
https://github.com/FAROTECH/orbitfabric-openobsw-opensvf-adapter/releases/tag/v0.1.0
```

Observed release state:

```text
draft:      false
prerelease: false
immutable:  true
```

## Publisher-owned release membership

The exact publisher-owned release membership is:

```text
orbitfabric_openobsw_opensvf_adapter-0.1.0-py3-none-any.whl
adapter-release.json
SHA256SUMS
```

`adapter-project-lock.json` is not release membership. A Project Lock belongs to a consuming project.

Observed SHA-256 identities:

```text
wheel
ed4a6316d66fc7267320083d3bbd482374f529b797937d5ef85e805e45230696

adapter-release.json
ef1b568c06a1573b580bbb91308b1311b81ba65dca29331fcf1610fc7ee5c016

SHA256SUMS
295bc1dcf06caf876e9456880e339a051e3f7afd195e515086d11567ada3ce4a
```

The Release Descriptor additionally binds the packaged Integration Package Manifest digest:

```text
fe10afebb38311549c8fb66497678267108b476593c087c241178637b05c889c
```

## Validated compatibility baselines

```text
OrbitFabric Core
4377d6656c62aa1dc19a7ed81d2de872b6b22ccd

OpenOBSW
44ceb71a016f0541ff7a0aa74191e13bafdb59c1

OpenSVF
667d3eadcb0bbd7814ac324b99946c4ed2f11f23
```

The accepted product baseline retains Core conformance, Python 3.11/3.12 checks, OpenOBSW/SRDB compatibility, OpenSVF compatibility, managed Adapter Manager lifecycle proof, Release Descriptor / Project Lock proof, publisher release-only proof and consumer product examples.

## Final gate record

| Gate | Result | Final evidence |
| --- | --- | --- |
| P1 accepted source commit | PASS | `8f26955e573d6ea5917ece927742aaf9ede30365` |
| P2 accepted-main CI | PASS | final release source retained green release-relevant CI evidence |
| P3 immutable release configuration | PASS | repository Immutable Releases enabled before publication |
| P4 exact signed tag | PASS | `v0.1.0`, GitHub-valid signed annotated tag resolving to accepted source |
| P5 definitive release bytes | PASS | wheel + Release Descriptor + SHA256SUMS built from exact release source |
| P6 frozen release notes | PASS | final GitHub Release body published |
| P7 local asset verification | PASS | checksum, descriptor and packaged-manifest verification passed |
| P8 draft release | PASS | exact tag and three normative assets attached |
| P9 pre-publication audit | PASS | draft metadata and GitHub-computed asset digests matched frozen local bytes |
| P10 immutable publication | PASS | public release reports `immutable: true` |
| P11 public release verification | PASS | `gh release verify` and all three `gh release verify-asset` checks passed |
| P12 external greenfield acceptance | PASS | public release installed through Adapter Manager; Examples 01-03 passed |
| P13 Architecture Lab evidence | PASS | `evidence/adapter-management/046-openobsw-opensvf-v0.1.0-publication-and-greenfield-acceptance.md` |

## P11 release attestation result

GitHub's provider-generated immutable-release attestation was verified successfully:

```text
gh release verify v0.1.0
    -> PASS
```

Each frozen publication asset was independently checked against the release attestation:

```text
wheel
    -> PASS

adapter-release.json
    -> PASS

SHA256SUMS
    -> PASS
```

This is provider publication evidence. It does not replace the OrbitFabric Release Descriptor and does not introduce an OrbitFabric-specific signing format.

## P12 external greenfield result

The final consumer exercise used a new workspace and the public `v0.1.0` release assets.

The adapter was not built or installed from the adapter source checkout.

Observed path:

```text
install exact validated Core baseline
    -> download public v0.1.0 assets
    -> verify SHA256SUMS
    -> Adapter Manager install
    -> inspect / verify
    -> Example 01
    -> Example 02
    -> pinned OpenOBSW/OpenSVF downstreams
    -> Example 03 native closed loop
```

Adapter Manager verification:

```text
release_descriptor_integrity: PASS
manifest_integrity:            PASS
manifest_conformance:          PASS
execution_binding:             PASS
backend_materialization:       PASS
Result:                        PASSED
```

Product examples:

```text
Example 01 - Mission Contract Projection
PASS

Example 02 - Scenario Verification Projection
PASS

Example 03 - Closed-Loop Ping
PASS
```

Native closed-loop evidence:

```text
OpenOBSW obsw_sim build: PASS
OpenSVF validation:      PASS, 0 warnings
Campaign procedures:     1
PASS:                    1
FAIL:                    0
ERROR:                   0
INCONCLUSIVE:            0
Pass rate:               100.0%
```

The runner also verified that the pinned OpenOBSW and OpenSVF source checkout states were unchanged by execution.

## P13 retained Architecture Lab evidence

Final cross-repository publication evidence is retained in:

```text
FAROTECH/OrbitFabric-Architecture-Lab

evidence/adapter-management/
046-openobsw-opensvf-v0.1.0-publication-and-greenfield-acceptance.md
```

That record retains:

- exact release source and tag association;
- immutable release state;
- published asset digests;
- provider-generated attestation verification;
- post-publication Adapter Manager verification;
- external greenfield Examples 01-03 evidence;
- native downstream closed-loop acceptance;
- lessons for the next Catalog / Release Resolution frontier.

## Current consumer boundary after v0.1.0

The current normal consumer flow is intentionally explicit:

```text
GitHub Release
    -> manually obtain adapter-release.json + wheel
    -> Adapter Manager install
    -> verify
    -> execute
```

`SHA256SUMS` accompanies the release for independent integrity checking.

Catalog discovery, remote exact release resolution and automatic artifact acquisition are not part of the `v0.1.0` Core consumer surface.

That limitation does not invalidate this release. The future Catalog / Release Resolution layer should discover and consume this same immutable `v0.1.0` release rather than requiring it to be rebuilt.

## Post-release findings

### Remote release acquisition

The current Adapter Manager source layer still uses explicit local descriptor/artifact inputs. The next architecture frontier is therefore above the already-proven installation boundary:

```text
Adapter Catalog
release discovery
remote exact resolution
automatic acquisition
```

### Trust evidence ingestion

The GitHub release is immutable and provider-attested, but the current explicit-source installation path does not automatically import those remote publication facts into Adapter Manager trust evidence.

This is a resolver/source-layer capability gap, not a defect in the immutable `v0.1.0` release.

## Release classification

`v0.1.0` is an:

```text
OrbitFabric-maintained stable adapter
```

This audit does not self-promote it to a generic registry-classified official adapter. Generic catalog, source-authority and publisher-governance policy remains a separate architecture concern.

## Closure

The first OpenOBSW/OpenSVF Adapter publication cycle is complete.

```text
P1  PASS
P2  PASS
P3  PASS
P4  PASS
P5  PASS
P6  PASS
P7  PASS
P8  PASS
P9  PASS
P10 PASS
P11 PASS
P12 PASS
P13 PASS
```

The next adapter-management task is no longer publication readiness. It is the separate **Adapter Catalog + Release Resolution** frontier.
