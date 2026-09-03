# Migration from the PoC

This adapter was not created by turning the historical OpenOBSW/OpenSVF PoC repository into a product in place.

The PoC remains historical engineering evidence, while this repository is a clean adapter product created from the public OrbitFabric Adapter Developer Template and populated only with durable implementation, target resources, compatibility controls and reusable evidence patterns.

## Migration model

```text
historical PoC
    evidence + experiments + runtime scaffolding
            |
            | analysis and extraction
            v
clean adapter repository
    product code + contracts + tests + documentation
```

## What was retained

Product-relevant material extracted from the validated PoC includes:

```text
OpenOBSW/SRDB projection behavior
target-specific Profile concepts
OpenSVF verification projection behavior
Scenario validation through OrbitFabric Core
target compatibility knowledge
regression fixtures and evidence patterns
```

The extracted behavior was then rebuilt around the current Core Integration Package, Adapter Manager and release lifecycle contracts rather than preserving the PoC repository architecture.

## What was not promoted

The clean product repository intentionally does not treat these as product architecture:

```text
PoC Stage numbering
experiment orchestration
workspace-specific checkout layout
temporary runtime topology
historical development branches
local support repositories
old package dependency assumptions
```

Historical live TM/TC and optional YAMCS exercises remain valuable evidence, but they are not silently converted into a current `0.1.0` runtime compatibility claim.

## Productization checks

The extracted adapter was accepted only after it independently established:

```text
Core contract conformance
explicit runtime dependencies
Target Applicable Surface analysis
Integration Coverage Matrix
OpenOBSW/SRDB native compatibility
OpenSVF native compatibility
installed Adapter Manager lifecycle
Release Descriptor and Project Lock proof
publisher-only release construction
product-facing documentation
```

## Why keep the PoC separate?

The separation preserves two useful assets without confusing their roles:

```text
PoC
    historical engineering evidence and regression reference

Adapter repository
    maintained reusable product and release source
```

Future adapter changes should be made against the product repository. The PoC may still be consulted when historical runtime evidence or design rationale is useful.
