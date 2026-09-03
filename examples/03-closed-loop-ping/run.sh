#!/usr/bin/env bash
set -euo pipefail

OPENOBSW_COMMIT="44ceb71a016f0541ff7a0aa74191e13bafdb59c1"
OPENSVF_COMMIT="667d3eadcb0bbd7814ac324b99946c4ed2f11f23"

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
work_root="${OF_EXAMPLE_WORK_ROOT:-$root/examples/.work}"
work="$work_root/03-closed-loop-ping"
core_input="$work/core-input"
project_output="$work/project-output"
verification_output="$work/verification-output"
assembled_srdb="$work/assembled-srdb"
build_dir="$work/openobsw-build"
evidence_dir="$work/native-evidence"
mission="$root/examples/reference/mission"
profile="$root/examples/profile.yaml"
scenario="$root/examples/reference/scenarios/ping-verification.yaml"

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Example 03 requires Linux or WSL2 for the validated native downstream runtime." >&2
  exit 2
fi

: "${OPENOBSW_ROOT:?Set OPENOBSW_ROOT to the validated OpenOBSW checkout}"
: "${OPENSVF_ROOT:?Set OPENSVF_ROOT to the validated OpenSVF checkout}"
openobsw="$(cd "$OPENOBSW_ROOT" && pwd)"
opensvf="$(cd "$OPENSVF_ROOT" && pwd)"

for command_name in orbitfabric orbitfabric-openobsw-opensvf python git cmake ninja svf; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    exit 2
  fi
done

actual_openobsw="$(git -C "$openobsw" rev-parse HEAD)"
actual_opensvf="$(git -C "$opensvf" rev-parse HEAD)"
if [[ "$actual_openobsw" != "$OPENOBSW_COMMIT" ]]; then
  echo "OpenOBSW checkout mismatch: expected $OPENOBSW_COMMIT, got $actual_openobsw" >&2
  exit 2
fi
if [[ "$actual_opensvf" != "$OPENSVF_COMMIT" ]]; then
  echo "OpenSVF checkout mismatch: expected $OPENSVF_COMMIT, got $actual_opensvf" >&2
  exit 2
fi

OPENOBSW="$openobsw" OPENSVF="$opensvf" python - <<'PY'
from __future__ import annotations

import inspect
import os
from pathlib import Path

import svf
from obsw_srdb.loader import SRDBLoader

openobsw = Path(os.environ["OPENOBSW"]).resolve()
opensvf = Path(os.environ["OPENSVF"]).resolve()
obsw_srdb_source = Path(inspect.getfile(SRDBLoader)).resolve()
svf_source = Path(svf.__file__).resolve()

if not obsw_srdb_source.is_relative_to(openobsw):
    raise SystemExit(f"obsw-srdb is not loaded from OPENOBSW_ROOT: {obsw_srdb_source}")
if not svf_source.is_relative_to(opensvf):
    raise SystemExit(f"OpenSVF is not loaded from OPENSVF_ROOT: {svf_source}")
PY

before_openobsw_status="$(git -C "$openobsw" status --porcelain=v1 --untracked-files=all)"
before_opensvf_status="$(git -C "$opensvf" status --porcelain=v1 --untracked-files=all)"

rm -rf "$work"
mkdir -p "$evidence_dir"

orbitfabric export integration-input-set \
  "$mission" \
  --output-dir "$core_input"

orbitfabric-openobsw-opensvf run \
  --operation project \
  --input-set-manifest "$core_input/integration_input_manifest.json" \
  --profile "$profile" \
  --output-dir "$project_output"

orbitfabric-openobsw-opensvf run \
  --operation verification_projection \
  --input-set-manifest "$core_input/integration_input_manifest.json" \
  --profile "$profile" \
  --operation-input scenario "$scenario" \
  --output-dir "$verification_output"

PROJECT_OUTPUT="$project_output" VERIFICATION_OUTPUT="$verification_output" python - <<'PY'
from __future__ import annotations

import json
import os
from pathlib import Path

project_output = Path(os.environ["PROJECT_OUTPUT"])
verification_output = Path(os.environ["VERIFICATION_OUTPUT"])
project = json.loads((project_output / "integration_result.json").read_text(encoding="utf-8"))
verification = json.loads(
    (verification_output / "integration_result.json").read_text(encoding="utf-8")
)
plan = json.loads(
    (verification_output / "verification_projection" / "verification_projection_plan.json").read_text(
        encoding="utf-8"
    )
)

assert project["result"] == "succeeded"
assert verification["result"] == "succeeded"
assert project["inputs"]["core_input_set"]["sha256"] == verification["inputs"]["core_input_set"]["sha256"]
assert project["inputs"]["profile"]["sha256"] == verification["inputs"]["profile"]["sha256"]
assert plan["core_input"]["input_set_sha256"] == project["inputs"]["core_input_set"]["sha256"]
assert plan["profile"]["sha256"] == project["inputs"]["profile"]["sha256"]
assert [item["id"] for item in plan["operations"]] == ["op-0001", "op-0002", "op-0003", "op-0004"]
assert plan["operations"][0]["resolved"] == {
    "apid": 16,
    "service": 17,
    "subtype": 1,
    "data_hex": "",
}
PY

OPENOBSW="$openobsw" PROJECT_OUTPUT="$project_output" ASSEMBLED_SRDB="$assembled_srdb" python - <<'PY'
from __future__ import annotations

import os
from pathlib import Path

from obsw_srdb.composition import SRDBComposer, SRDBContributionLoader, SRDBMaterializer
from obsw_srdb.loader import SRDBLoader

openobsw = Path(os.environ["OPENOBSW"])
project_output = Path(os.environ["PROJECT_OUTPUT"])
assembled = Path(os.environ["ASSEMBLED_SRDB"])

base = SRDBLoader.load(openobsw / "srdb" / "data")
contribution = SRDBContributionLoader.load(project_output / "obsw_srdb_contribution")
composed = SRDBComposer.compose(base, [contribution])
SRDBMaterializer.write(composed, assembled)
assert SRDBLoader.load(assembled) == composed
PY

cmake \
  -S "$openobsw" \
  -B "$build_dir" \
  -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DOBSW_BUILD_TESTS=OFF \
  -DOBSW_BUILD_SIM=ON \
  -DOBSW_ENABLE_ORBITFABRIC_CONTRACT=ON \
  -DORBITFABRIC_CONTRACT_DIR="$project_output/flight_software" \
  -DSRDB_DATA_DIR="$assembled_srdb" \
  -DPython3_EXECUTABLE="$(command -v python)"

cmake --build "$build_dir" --target obsw_sim

sim_binary="$build_dir/sim/obsw_sim"
if [[ ! -f "$sim_binary" ]]; then
  mapfile -t candidates < <(find "$build_dir" -type f -name obsw_sim -print)
  if [[ "${#candidates[@]}" -ne 1 ]]; then
    echo "Expected exactly one obsw_sim under $build_dir; found ${#candidates[@]}" >&2
    exit 1
  fi
  sim_binary="${candidates[0]}"
fi

materialized="$verification_output/verification_projection/opensvf"
spacecraft="$materialized/opensvf/spacecraft.yaml"
campaign="$materialized/campaigns/verification_projection_campaign.yaml"
plan="$verification_output/verification_projection/verification_projection_plan.json"
manifest="$materialized/materialization_manifest.json"
report="$evidence_dir/campaign-report.json"

mkdir -p "$materialized/bin"
cp "$sim_binary" "$materialized/bin/obsw_sim"
chmod +x "$materialized/bin/obsw_sim"

svf validate "$spacecraft"
svf campaign "$campaign" --json "$report"

PLAN="$plan" MANIFEST="$manifest" REPORT="$report" python - <<'PY'
from __future__ import annotations

import json
import os
from pathlib import Path

plan = json.loads(Path(os.environ["PLAN"]).read_text(encoding="utf-8"))
manifest = json.loads(Path(os.environ["MANIFEST"]).read_text(encoding="utf-8"))
report = json.loads(Path(os.environ["REPORT"]).read_text(encoding="utf-8"))
expected_ids = ["op-0001", "op-0002", "op-0003", "op-0004"]

assert [item["id"] for item in plan["operations"]] == expected_ids
assert [item["plan_operation_id"] for item in manifest["operation_trace"]] == expected_ids
assert manifest["execution_policy"]["scenario_time_interpretation"] == "provenance_only"

assert report["n_procedures"] == 1
assert report["n_inconclusive"] == 0
assert report["pass_rate"] == 1.0
assert report["declared_requirements"] == []
assert report["uncovered_requirements"] == []
assert len(report["results"]) == 1
result = report["results"][0]
assert result["verdict"] == "PASS"
assert result["error"] is None
assert result["requirement"] == ""
assert len(result["steps"]) == 4
assert all(step["verdict"] == "PASS" for step in result["steps"])
report_ids = [step["name"].split(":", 1)[0] for step in result["steps"]]
assert report_ids == expected_ids
PY

after_openobsw_status="$(git -C "$openobsw" status --porcelain=v1 --untracked-files=all)"
after_opensvf_status="$(git -C "$opensvf" status --porcelain=v1 --untracked-files=all)"
if [[ "$after_openobsw_status" != "$before_openobsw_status" ]]; then
  echo "OpenOBSW working tree changed during Example 03" >&2
  exit 1
fi
if [[ "$after_opensvf_status" != "$before_opensvf_status" ]]; then
  echo "OpenSVF working tree changed during Example 03" >&2
  exit 1
fi

printf 'Example 03: PASS\n'
printf '  OpenOBSW runtime: %s\n' "$sim_binary"
printf '  Verification plan: %s\n' "$plan"
printf '  Native CampaignReport: %s\n' "$report"
