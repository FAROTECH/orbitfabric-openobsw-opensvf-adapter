# v0.1.0 Publication Readiness Audit

Audit date: **2026-09-03**

Status: **PRODUCT READY / PUBLICATION GATES REMAIN**

This audit is the operational gate for the first public `v0.1.0` distribution of the OrbitFabric OpenOBSW/OpenSVF Adapter.

It separates product readiness from publication readiness. A green source baseline is not yet a published release.

## Executive conclusion

The adapter product is ready to enter final publication preparation.

The remaining work is not new adapter design. It is the controlled conversion of one accepted `main` commit into one exact, immutable and externally consumable release.

```text
accepted product
    -> accepted main commit
    -> exact v0.1.0 tag
    -> exact release assets
    -> local byte verification
    -> draft GitHub Release
    -> immutable publication
    -> published-byte verification
    -> external greenfield acceptance
```

`v0.1.0` must not be published until every blocking item below is closed.

## Current PASS evidence

### Repository and product identity

- Repository is public.
- Distribution version is `0.1.0`.
- Logical adapter key is `orbitfabric/openobsw-opensvf`.
- First source coordinate is `github.com/FAROTECH:orbitfabric/openobsw-opensvf`.
- No existing GitHub Release is published for this repository.
- No `v0.1.0` tag currently exists, so there is no tag collision to resolve.

### Core and target compatibility

Validated baselines remain:

```text
OrbitFabric Core
4377d6656c62aa1dc19a7ed81d2de872b6b22ccd

OpenOBSW
44ceb71a016f0541ff7a0aa74191e13bafdb59c1

OpenSVF
667d3eadcb0bbd7814ac324b99946c4ed2f11f23
```

The accepted product baseline proves:

- Core conformance;
- Python 3.11 and 3.12 checks;
- OpenOBSW/SRDB target-native compatibility;
- OpenSVF target-native compatibility;
- isolated Adapter Manager installed lifecycle;
- provider-neutral Release Descriptor / Project Lock proof;
- publisher-only release construction.

### Consumer product examples

Manual clean greenfield acceptance has passed through Adapter Manager for:

```text
Example 01 - Mission Contract Projection
Example 02 - Scenario Verification Projection
Example 03 - Closed-Loop Ping
```

The closed-loop path additionally proved:

- target-owned SRDB composition;
- native OpenOBSW `obsw_sim` build;
- generated OpenSVF campaign execution;
- 100% campaign pass rate;
- native CampaignReport JSON evidence;
- unchanged OpenOBSW and OpenSVF source checkouts.

The Product Examples CI now exercises the same managed consumer lifecycle.

### Documentation product model

The publication-preparation branch separates:

```text
USER
    install / verify / execute / examples

DEVELOPER / CONTRIBUTOR
    source checkout / editable install / internals / tests

MAINTAINER / PUBLISHER
    accepted source / release construction / publication / final acceptance
```

The repository README is a role-based landing page and `Getting Started` is consumer-first.

### Release notes source

`CHANGELOG.md` has been replaced with adapter-specific `0.1.0` content. Template/Dummy Adapter release notes are no longer considered valid publication material.

## Current blockers before release-source acceptance

### B1. Publication-preparation PR must be green

The current release-preparation branch must pass the complete repository CI after all documentation cleanup.

The first documentation run exposed one strict-MkDocs link issue. That issue has been corrected; the replacement CI run must pass before merge.

**Gate:** complete CI success on the reviewed PR head.

### B2. Consolidated readiness documents must match current claims

Older readiness text still contains historical publication steps such as making the repository public even though it is already public.

It also uses wording that can be read as requiring a cryptographic release attestation, although the current `0.1.0` release proof implements byte identity, hashes and lifecycle proof rather than a signature/attestation mechanism.

**Gate:** align Release Lifecycle and Adapter Readiness Checklist with the actual `0.1.0` claim before merge.

## v0.1.0 provenance boundary

For the first release, provenance means:

```text
exact accepted main commit
    + exact v0.1.0 tag
    + immutable GitHub Release
    + exact published asset SHA-256 values
    + Release Descriptor binding to the wheel and packaged manifest
```

`v0.1.0` does **not** claim cryptographic artifact signing or signature-attestation verification.

Those capabilities may be added later as a separate trust enhancement. They must not be implied by the first release documentation unless an implementation and verification path is added before publication.

This boundary is also consistent with Adapter Manager acceptance warnings that distinguish exact byte/lifecycle checks from unavailable signature or publisher-trust attestations.

## Required publisher-owned release membership

The normative publisher-owned asset set is:

```text
orbitfabric_openobsw_opensvf_adapter-0.1.0-py3-none-any.whl
adapter-release.json
SHA256SUMS
```

The GitHub Release body carries the release notes.

GitHub-generated source archives may exist as provider conveniences, but they are not OrbitFabric adapter release membership.

`adapter-project-lock.json` is explicitly excluded. A Project Lock belongs to a consuming project and records that project's exact selected resolution.

## Publication gates after merge

### P1. Select the accepted release source commit

Merge the fully green publication-preparation PR to `main`.

Then record the exact resulting `main` commit as the release source.

Do not release from:

- a feature branch;
- a pull-request synthetic merge ref;
- an unreviewed local working tree.

### P2. Reconfirm accepted-main CI

The exact accepted `main` commit must retain green evidence for the release-relevant controls.

At minimum confirm:

```text
CI
Product Examples
```

and the release-proof evidence emitted by CI.

### P3. Confirm GitHub immutable-release configuration

Before creating the final release, confirm that GitHub Immutable Releases is enabled for the repository and understand the point after which release assets cannot be changed.

This is currently a manual/provider configuration gate and is not inferred from source code.

### P4. Create exact `v0.1.0` tag

Create `v0.1.0` against the accepted `main` source commit and verify:

```text
v0.1.0 -> exact accepted source SHA
```

No tag should be created before the release source is frozen.

### P5. Build definitive release bytes from the accepted source

From a clean checkout of the accepted release commit:

```bash
python -m build --wheel

python tools/build_release_bundle.py \
  --wheel dist/orbitfabric_openobsw_opensvf_adapter-0.1.0-py3-none-any.whl \
  --authority github.com/FAROTECH \
  --publisher orbitfabric \
  --name openobsw-opensvf \
  --release-only
```

Record the resulting exact SHA-256 values.

The definitive bytes are the bytes that will be attached to GitHub. CI artifacts from a different build are evidence, not automatically the publication bytes.

### P6. Freeze release notes

Prepare the GitHub Release notes from the accepted `CHANGELOG.md` scope.

The notes must state:

- first stable adapter release;
- validated Core/OpenOBSW/OpenSVF baselines;
- product examples and closed-loop evidence;
- explicit semantic non-claims;
- consumer installation path through Adapter Manager.

### P7. Verify definitive assets locally

Before uploading:

- verify `SHA256SUMS` against the wheel and descriptor;
- load/validate `adapter-release.json`;
- confirm release identity and version;
- confirm descriptor wheel digest equals the definitive wheel;
- confirm the wheel contains the expected Integration Package Manifest and Profile schema.

A final local Adapter Manager install/verify from these exact bytes is recommended before upload.

### P8. Create draft GitHub Release

Create a draft GitHub Release for `v0.1.0` from the exact accepted tag.

Attach only the definitive publisher-owned assets:

```text
wheel
adapter-release.json
SHA256SUMS
```

Add the frozen release notes.

### P9. Verify draft release before immutable publication

Before the irreversible publication step, verify:

- tag points to the accepted source commit;
- asset names are exact;
- downloaded draft asset bytes match the local SHA-256 values;
- Release Descriptor still binds the published wheel;
- no Project Lock is attached;
- release notes match the accepted product scope.

### P10. Publish immutably

Publish the verified draft under the repository's immutable-release policy.

After publication confirm the release is final/immutable according to GitHub's repository state.

### P11. Verify published distribution

Download the public release assets again and verify their SHA-256 values independently.

Record:

```text
release URL
tag
source commit
wheel SHA-256
Release Descriptor SHA-256
SHA256SUMS identity
publication state
```

### P12. External greenfield acceptance

Repeat the clean consumer exercise from a new workspace, but **do not clone/build the adapter as a publisher**.

The intended final path is:

```text
install OrbitFabric Core
    -> obtain public v0.1.0 release assets
    -> orbitfabric adapter install
    -> inspect / verify
    -> execute product examples
    -> native closed-loop acceptance
```

The adapter source repository may be cloned only if needed to obtain example source inputs; it must not be used to install or build the adapter in this acceptance run.

### P13. Retain Architecture Lab publication evidence

After successful public acceptance, retain a final Architecture Lab evidence record containing:

- exact accepted adapter source commit;
- tag association;
- immutable release identity;
- published asset digests;
- post-publication Adapter Manager verification;
- external greenfield example evidence;
- any lessons that should feed the cross-adapter Product Model or Developer Template.

## Release decision rule

The release may be published only when:

```text
all source/product gates PASS
and all pre-publication gates P1-P9 PASS
```

The release is considered fully accepted only when post-publication gates P10-P13 also PASS.

Until then, the correct product status is:

```text
0.1.0 validated release candidate
```

not:

```text
0.1.0 published release
```
