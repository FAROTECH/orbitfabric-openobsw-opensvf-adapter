#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
work_root="${OF_EXAMPLE_WORK_ROOT:-$root/examples/.work}"
work="$work_root/01-mission-contract-projection"
core_input="$work/core-input"
output="$work/project-output"
mission="$root/examples/reference/mission"
profile="$root/examples/profile.yaml"
adapter_instance="${ORBITFABRIC_ADAPTER_INSTANCE_ID:-}"

for command_name in orbitfabric python; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    exit 2
  fi
done

if [[ -n "$adapter_instance" ]]; then
  if ! orbitfabric adapter inspect "$adapter_instance" --json >/dev/null 2>&1; then
    echo "Adapter Manager instance is not installed: $adapter_instance" >&2
    exit 2
  fi
  if ! orbitfabric adapter verify "$adapter_instance" >/dev/null; then
    echo "Adapter Manager verification failed: $adapter_instance" >&2
    exit 2
  fi
else
  if ! command -v orbitfabric-openobsw-opensvf >/dev/null 2>&1; then
    echo "Set ORBITFABRIC_ADAPTER_INSTANCE_ID to an installed Adapter Manager instance, or install the adapter console command for contributor mode." >&2
    exit 2
  fi
fi

rm -rf "$work"
mkdir -p "$work"

orbitfabric export integration-input-set \
  "$mission" \
  --output-dir "$core_input"

if [[ -n "$adapter_instance" ]]; then
  orbitfabric adapter execute "$adapter_instance" \
    --operation project \
    --input-set-manifest "$core_input/integration_input_manifest.json" \
    --profile "$profile" \
    --output-dir "$output"
else
  orbitfabric-openobsw-opensvf run \
    --operation project \
    --input-set-manifest "$core_input/integration_input_manifest.json" \
    --profile "$profile" \
    --output-dir "$output"
fi

OUTPUT="$output" python - <<'PY'
from __future__ import annotations

import json
import os
from pathlib import Path

output = Path(os.environ["OUTPUT"])
result = json.loads((output / "integration_result.json").read_text(encoding="utf-8"))
header = (output / "flight_software" / "mission_contract.h").read_text(encoding="utf-8")
contribution = json.loads(
    (output / "obsw_srdb_contribution" / "contribution_manifest.json").read_text(
        encoding="utf-8"
    )
)

assert result["result"] == "succeeded"
assert result["operation"]["id"] == "project"
assert result["mission"]["id"] == "openobsw-opensvf-reference"
assert result["inputs"]["operation_inputs"] == []
assert [item["id"] for item in result["artifacts"]] == [
    "flight.mission_contract",
    "ground.obsw_srdb_contribution",
]

for symbol in (
    "OF_TM_OBC_BUS_VOLTAGE_MV",
    "OF_HK_SET_OBC",
    "OF_CMD_PING",
    "OF_EVENT_VOLTAGE_OUT_OF_BOUNDS",
):
    assert symbol in header, symbol

assert contribution["mode"] == "additive"
assert contribution["complete_srdb"] is False
assert any(
    item["binding"] == "cmd.ping" and item["id"] == "are_you_alive"
    for item in contribution["reused_targets"]
)
PY

printf 'Example 01: PASS\n'
printf '  Core input: %s\n' "$core_input/integration_input_manifest.json"
printf '  Integration Result: %s\n' "$output/integration_result.json"
printf '  Flight contract: %s\n' "$output/flight_software/mission_contract.h"
printf '  SRDB contribution: %s\n' "$output/obsw_srdb_contribution"
