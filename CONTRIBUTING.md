# Contributing

This repository maintains the OrbitFabric OpenOBSW/OpenSVF adapter.

Contributions should preserve the ownership boundary between OrbitFabric Core, adapter-specific projection and the native OpenOBSW/OpenSVF ecosystems.

## Preserve these boundaries

1. OrbitFabric Core remains the normative authority for generic integration contracts and conformance.
2. OpenOBSW/OpenSVF-specific mappings, Profile settings and compatibility logic belong in this adapter.
3. OpenOBSW and OpenSVF retain ownership of their native runtime, validation and execution semantics.
4. Tests must exercise packaged or installed behavior when the relevant lifecycle control exists.
5. Do not rely on ambient `PYTHONPATH`, host-global executable discovery or undeclared runtime dependencies.
6. Keep release construction provider-neutral. Publication provider details must not redefine logical adapter identity.
7. Do not silently widen the declared Integration Coverage. New semantic families require an explicit target mapping and evidence.
8. Do not import historical PoC Stage structure or temporary workspace assumptions into product architecture.

## Before changing behavior

Classify the proposed change by ownership:

```text
Core contract
adapter target semantics
OpenOBSW/SRDB compatibility
OpenSVF compatibility
Python packaging/backend
release lifecycle
documentation
Integration Coverage
```

If a change modifies generic OrbitFabric contract meaning, it probably belongs in OrbitFabric Core rather than this repository.

If a change depends on a new downstream semantic assumption, add or update the corresponding target-native compatibility evidence.

## Local checks

Run before opening a pull request:

```bash
ruff check .
python tools/check_adapter_consistency.py
pytest -q
python -m build --wheel
mkdocs build --strict
```

The stronger installed-lifecycle and release-proof shell scripts are CI controls. They intentionally exercise isolated Adapter Manager environments and exact release behavior.

Use `tools/build_release_bundle.py` for local release construction. Use `--release-only` when constructing publisher-owned release material without a consumer Project Lock.

## Compatibility changes

The stable release currently pins exact validated baselines for OrbitFabric Core, OpenOBSW and OpenSVF.

Changing one of those baselines is not a documentation-only update. The relevant native compatibility control must pass against the new baseline, and the compatibility documentation and evidence must be updated together.

## Coverage changes

The maintained coverage declaration is:

```text
coverage/integration-coverage.md
```

When adding a new capability:

```text
define the OrbitFabric semantic area
identify the downstream representation or limitation
update the declared scope/disposition
implement the mapping
add positive and negative tests
add downstream-native evidence where applicable
update user documentation
```

Do not convert an unknown or unimplemented mapping into `TARGET_UNSUPPORTED` without target evidence.

## Documentation changes

Write for users arriving from either side of the integration. Documentation should make clear:

```text
what OrbitFabric owns
what the adapter owns
what OpenOBSW owns
what OpenSVF owns
what is required for generation
what is required for native validation
what is optional runtime/SIL work
what the release actually claims
```

Keep architecture investigation and historical construction detail in the Architecture Lab or historical PoC rather than making them active product instructions.
