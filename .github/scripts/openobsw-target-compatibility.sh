#!/usr/bin/env bash
set -euo pipefail

root="${GITHUB_WORKSPACE:?GITHUB_WORKSPACE is required}"
target="$root/_openobsw"
work="/tmp/orbitfabric-openobsw-target-compatibility"
core_input="$work/core-input"
output="$work/adapter-output"
materialized="$work/materialized-srdb"
evidence="$work/evidence"

rm -rf "$work"
mkdir -p "$evidence"

orbitfabric export integration-input-set \
  "$root/tests/fixtures/lifecycle/mission" \
  --output-dir "$core_input"

orbitfabric-openobsw-opensvf run \
  --operation project \
  --input-set-manifest "$core_input/integration_input_manifest.json" \
  --profile "$root/examples/profile.yaml" \
  --output-dir "$output"

test -f "$output/flight_software/mission_contract.h"
test -f "$output/obsw_srdb_contribution/contribution_manifest.json"

TARGET="$target" OUTPUT="$output" MATERIALIZED="$materialized" EVIDENCE="$evidence" python - <<'PY'
from __future__ import annotations

import json
import os
from pathlib import Path

from obsw_srdb.composition import SRDBComposer, SRDBContributionLoader, SRDBMaterializer
from obsw_srdb.loader import SRDBLoader

root = Path(os.environ["TARGET"])
output = Path(os.environ["OUTPUT"])
materialized = Path(os.environ["MATERIALIZED"])
evidence = Path(os.environ["EVIDENCE"])

base = SRDBLoader.load(root / "srdb" / "data")
contribution = SRDBContributionLoader.load(output / "obsw_srdb_contribution")
composed = SRDBComposer.compose(base, [contribution])
SRDBMaterializer.write(composed, materialized)

assert any(item.id == 0x6001 and item.name == "eps_obc_bus_voltage_mv" for item in composed.parameters)
assert any(item.id == 0x5001 and item.name == "eps_voltage_out_of_bounds" for item in composed.events)
assert any(item.id == 5 and item.name == "obc_hk" for item in composed.hk_sets)
assert any(
    item.name == "are_you_alive"
    and item.apid == 16
    and item.service == 17
    and item.subservice == 1
    for item in composed.telecommands
)
assert len(composed.telecommands) == len(base.telecommands)

report = {
    "kind": "orbitfabric.openobsw_target_compatibility",
    "status": "PASS",
    "openobsw_commit": "44ceb71a016f0541ff7a0aa74191e13bafdb59c1",
    "obsw_srdb_version": "0.1.0",
    "checks": [
        "contribution_load",
        "additive_composition",
        "materialization_round_trip",
        "existing_telecommand_reuse",
    ],
}
(evidence / "target-acceptance.json").write_text(
    json.dumps(report, indent=2, sort_keys=True) + "\n",
    encoding="utf-8",
)
PY

PYTHONPATH="$target/srdb" python -m obsw_srdb.codegen \
  --data-dir "$materialized" \
  --output "$evidence/srdb_generated.h"
PYTHONPATH="$target/srdb" python -m obsw_srdb.codegen \
  --data-dir "$materialized" \
  --xtce-output "$evidence/mission.xtce"

test -s "$evidence/srdb_generated.h"
test -s "$evidence/mission.xtce"

cat > "$work/mission_contract_smoke.c" <<'C'
#include "mission_contract.h"

int main(void) {
    return OF_CMD_PING == 0x1701 ? 0 : 1;
}
C

cc -std=c11 -Wall -Wextra -Werror \
  -I "$output/flight_software" \
  "$work/mission_contract_smoke.c" \
  -o "$work/mission_contract_smoke"
"$work/mission_contract_smoke"

cp "$output/integration_result.json" "$evidence/integration-result.json"
cp "$output/obsw_srdb_contribution/contribution_manifest.json" \
  "$evidence/contribution-manifest.json"
cp "$output/flight_software/mission_contract.h" "$evidence/mission-contract.h"
