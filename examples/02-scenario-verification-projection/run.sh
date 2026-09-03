#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
work_root="${OF_EXAMPLE_WORK_ROOT:-$root/examples/.work}"
work="$work_root/02-scenario-verification-projection"
core_input="$work/core-input"
output="$work/verification-output"
mission="$root/examples/reference/mission"
profile="$root/examples/profile.yaml"
scenario="$root/examples/reference/scenarios/ping-verification.yaml"
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
    --operation verification_projection \
    --input-set-manifest "$core_input/integration_input_manifest.json" \
    --profile "$profile" \
    --operation-input "scenario=$scenario" \
    --output-dir "$output"
else
  orbitfabric-openobsw-opensvf run \
    --operation verification_projection \
    --input-set-manifest "$core_input/integration_input_manifest.json" \
    --profile "$profile" \
    --operation-input scenario "$scenario" \
    --output-dir "$output"
fi

OUTPUT="$output" python - <<'PY'
from __future__ import annotations

import json
import os
from pathlib import Path

output = Path(os.environ["OUTPUT"])
result = json.loads((output / "integration_result.json").read_text(encoding="utf-8"))
root = output / "verification_projection"
plan = json.loads((root / "verification_projection_plan.json").read_text(encoding="utf-8"))
materialized = root / "opensvf"
manifest = json.loads((materialized / "materialization_manifest.json").read_text(encoding="utf-8"))
procedure = (materialized / "procedures" / "verification_projection_procedure.py").read_text(
    encoding="utf-8"
)

assert result["result"] == "succeeded"
assert result["operation"]["id"] == "verification_projection"
assert result["mission"]["id"] == "openobsw-opensvf-reference"
assert result["inputs"]["operation_inputs"][0]["id"] == "ping_verification"

assert plan["status"] == "executable_subset"
assert plan["source"]["scenario_id"] == "ping_verification"
assert plan["accounting"] == {
    "source_atoms": 6,
    "projected_atoms": 2,
    "not_projected_atoms": 4,
    "blocked_atoms": 0,
    "source_actions": 1,
    "source_expectations": 3,
    "projected_source_actions": 1,
    "projected_source_expectations": 0,
    "profile_verification_obligations": 3,
}

operations = plan["operations"]
assert [item["id"] for item in operations] == ["op-0001", "op-0002", "op-0003", "op-0004"]
assert operations[0]["operation"] == "pus_tc"
assert operations[0]["origin"] == "profile_mapping"
assert operations[0]["resolved"] == {
    "apid": 16,
    "service": 17,
    "subtype": 1,
    "data_hex": "",
}
assert [(item["resolved"]["service"], item["resolved"]["subtype"]) for item in operations[1:]] == [
    (1, 1),
    (17, 2),
    (1, 7),
]
assert all(item["origin"] == "profile_expected_response" for item in operations[1:])

not_projected = {item["kind"] for item in plan["atoms"] if item["disposition"] == "not_projected"}
assert not_projected == {
    "initial_mode",
    "expect_command_status",
    "expect_event",
    "expect_scenario_status",
}
assert manifest["execution_policy"]["scenario_time_interpretation"] == "provenance_only"
assert [item["plan_operation_id"] for item in manifest["operation_trace"]] == [
    "op-0001",
    "op-0002",
    "op-0003",
    "op-0004",
]
assert "ctx.tc(" in procedure
assert procedure.count("ctx.expect_tm(") == 3
assert "ctx.wait(" not in procedure
PY

printf 'Example 02: PASS\n'
printf '  Verification plan: %s\n' "$output/verification_projection/verification_projection_plan.json"
printf '  Materialization: %s\n' "$output/verification_projection/opensvf/materialization_manifest.json"
printf '  Integration Result: %s\n' "$output/integration_result.json"
