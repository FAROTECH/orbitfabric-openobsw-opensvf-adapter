# Target Compatibility Tests

Target compatibility is intentionally separate from OrbitFabric Core conformance.

The current OpenOBSW control pins upstream commit `44ceb71a016f0541ff7a0aa74191e13bafdb59c1` and verifies the adapter handoff against the target-owned SRDB implementation.

The control:

1. exports the lifecycle fixture through OrbitFabric Core;
2. generates the adapter project artifacts;
3. loads the additive SRDB contribution with OpenOBSW `SRDBContributionLoader`;
4. composes it with the canonical OpenOBSW SRDB using `SRDBComposer`;
5. materializes and round-trips the complete SRDB with `SRDBMaterializer`;
6. runs the canonical OpenOBSW SRDB code generator for C and XTCE outputs;
7. compiles the generated `mission_contract.h` as C11;
8. records target acceptance evidence.

This proves target-native acceptance of the currently declared OpenOBSW handoff. It does not replace OrbitFabric Integration Result conformance, and it does not imply compatibility with arbitrary future OpenOBSW revisions.
