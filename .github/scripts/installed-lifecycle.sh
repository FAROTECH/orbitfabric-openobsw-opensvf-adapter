#!/usr/bin/env bash
set -euo pipefail

if [[ "${GITHUB_ACTIONS:-}" != "true" ]]; then
  echo "This is a destructive CI isolation proof and must run only inside GitHub Actions." >&2
  exit 2
fi

root="${GITHUB_WORKSPACE:?GITHUB_WORKSPACE is required}"
work="/tmp/orbitfabric-openobsw-opensvf-installed-lifecycle"
state="$work/state"
evidence="$work/evidence"
wheelhouse="$work/wheelhouse"
release_dir="$work/release"
core_input="$work/core-input"
project_output="$work/project-output"
verification_output="$work/verification-output"
fixture="$root/tests/fixtures/lifecycle"
profile="$root/examples/profile.yaml"

export ORBITFABRIC_STATE_DIR="$state"

rm -rf "$work"
mkdir -p "$evidence" "$wheelhouse" "$release_dir"

cd "$root"
rm -rf dist
python -m build --wheel
wheel="$(realpath "$(find "$root/dist" -maxdepth 1 -name '*.whl' -print -quit)")"
test -n "$wheel"

orbitfabric export integration-input-set \
  "$fixture/mission" \
  --output-dir "$core_input"
test -f "$core_input/integration_input_manifest.json"

python -m pip download --dest "$wheelhouse" "$wheel"
python -m pip download --dest "$wheelhouse" "hatchling>=1.24"
test -n "$(find "$wheelhouse" -maxdepth 1 -type f -print -quit)"

python tools/build_release_bundle.py \
  --wheel "$wheel" \
  --authority local.adapter.test \
  --publisher farotech \
  --name openobsw-opensvf \
  --output-dir "$release_dir"

descriptor="$release_dir/adapter-release.json"
descriptor_sha="$(sha256sum "$descriptor" | awk '{print $1}')"
cp "$descriptor" "$evidence/release-descriptor.json"
cp "$core_input/integration_input_manifest.json" "$evidence/core-input-manifest.json"
sha256sum "$wheel" > "$evidence/adapter-wheel.sha256"

export PIP_NO_INDEX=1
export PIP_FIND_LINKS="$wheelhouse"
orbitfabric adapter install "$descriptor" \
  --artifact "$wheel" \
  --descriptor-sha256 "$descriptor_sha" \
  --json | tee "$evidence/install.json"
unset PIP_NO_INDEX
unset PIP_FIND_LINKS

EVIDENCE="$evidence" python - <<'PY' > "$work/install-env"
import json
import os
from pathlib import Path

record = json.loads((Path(os.environ["EVIDENCE"]) / "install.json").read_text(encoding="utf-8"))
assert record["backend_id"] == "python-wheel-managed-env"
assert Path(record["execution_argv_prefix"][0]).is_absolute()
assert Path(record["manifest_path"]).is_file()
print("INSTANCE_ID=" + record["instance_id"])
print("INSTALLED_MANIFEST=" + record["manifest_path"])
PY
source "$work/install-env"

rm -f "$wheel" "$descriptor"
rm -rf "$wheelhouse"
rm -rf "$root/src"
test ! -e "$wheel"
test ! -d "$root/src"

cd /tmp
PYTHONPATH= orbitfabric adapter verify "$INSTANCE_ID" --json \
  | tee "$evidence/verify.json"
EVIDENCE="$evidence" python - <<'PY'
import json
import os
from pathlib import Path

report = json.loads((Path(os.environ["EVIDENCE"]) / "verify.json").read_text(encoding="utf-8"))
for name in (
    "release_descriptor_integrity",
    "manifest_integrity",
    "manifest_conformance",
    "execution_binding",
    "backend_materialization",
):
    assert report[name]["status"] == "PASS", (name, report[name])
PY

mkdir -p "$project_output"
PYTHONPATH= orbitfabric adapter execute "$INSTANCE_ID" \
  --operation project \
  --input-set-manifest "$core_input/integration_input_manifest.json" \
  --profile "$profile" \
  --output-dir "$project_output" \
  --json | tee "$evidence/project-execution.json"
python -m orbitfabric.conformance.integration_contracts result \
  "$INSTALLED_MANIFEST" \
  "$project_output/integration_result.json"
PROJECT_OUTPUT="$project_output" python - <<'PY'
import json
import os
from pathlib import Path

output = Path(os.environ["PROJECT_OUTPUT"])
result = json.loads((output / "integration_result.json").read_text(encoding="utf-8"))
header = (output / "flight_software" / "mission_contract.h").read_text(encoding="utf-8")
contribution = json.loads(
    (output / "obsw_srdb_contribution" / "contribution_manifest.json").read_text(
        encoding="utf-8"
    )
)

assert result["result"] == "succeeded"
assert result["operation"]["id"] == "project"
assert result["mission"]["id"] == "openobsw-opensvf-lifecycle"
assert result["inputs"]["operation_inputs"] == []
assert [item["id"] for item in result["artifacts"]] == [
    "flight.mission_contract",
    "ground.obsw_srdb_contribution",
]
for symbol in (
    "OF_TM_OBC_BUS_VOLTAGE_MV",
    "OF_CMD_PING",
    "OF_EVENT_VOLTAGE_OUT_OF_BOUNDS",
    "OF_HK_SET_OBC",
):
    assert symbol in header
assert contribution["kind"] == "orbitfabric.openobsw_opensvf.obsw_srdb_contribution"
assert contribution["mode"] == "additive"
assert contribution["complete_srdb"] is False
reused = contribution["reused_targets"]
assert len(reused) == 1
assert reused[0]["binding"] == "cmd.ping"
assert reused[0]["id"] == "are_you_alive"
PY
cp "$project_output/integration_result.json" "$evidence/project-integration-result.json"
cp "$project_output/flight_software/mission_contract.h" "$evidence/mission-contract.h"
cp "$project_output/obsw_srdb_contribution/contribution_manifest.json" \
  "$evidence/obsw-srdb-contribution-manifest.json"

scenario="$fixture/scenarios/ping_verification.yaml"
mkdir -p "$verification_output"
PYTHONPATH= orbitfabric adapter execute "$INSTANCE_ID" \
  --operation verification_projection \
  --input-set-manifest "$core_input/integration_input_manifest.json" \
  --profile "$profile" \
  --operation-input "scenario=$scenario" \
  --output-dir "$verification_output" \
  --json | tee "$evidence/verification-execution.json"
python -m orbitfabric.conformance.integration_contracts result \
  "$INSTALLED_MANIFEST" \
  "$verification_output/integration_result.json"
SCENARIO="$scenario" VERIFICATION_OUTPUT="$verification_output" python - <<'PY'
import hashlib
import json
import os
from pathlib import Path

scenario = Path(os.environ["SCENARIO"])
output = Path(os.environ["VERIFICATION_OUTPUT"])
result = json.loads((output / "integration_result.json").read_text(encoding="utf-8"))
plan = json.loads(
    (output / "verification_projection" / "verification_projection_plan.json").read_text(
        encoding="utf-8"
    )
)

assert result["result"] == "succeeded"
assert result["operation"]["id"] == "verification_projection"
provenance = result["inputs"]["operation_inputs"]
assert len(provenance) == 1
assert provenance[0]["role"] == "scenario"
assert provenance[0]["id"] == "ping_verification"
assert provenance[0]["sha256"] == hashlib.sha256(scenario.read_bytes()).hexdigest()
assert [item["id"] for item in result["artifacts"]] == [
    "verification.projection_plan",
    "verification.opensvf_materialization",
    "verification.opensvf_procedure",
    "verification.opensvf_campaign",
    "verification.opensvf_spacecraft",
]
assert plan["status"] == "executable_subset"
assert plan["source"]["scenario_id"] == "ping_verification"
assert plan["accounting"]["projected_source_actions"] == 1
assert any(
    operation["operation"] == "pus_tc"
    and operation["resolved"]["apid"] == 16
    and operation["resolved"]["service"] == 17
    and operation["resolved"]["subtype"] == 1
    for operation in plan["operations"]
)
materialization = output / "verification_projection" / "opensvf"
for relative in (
    "materialization_manifest.json",
    "procedures/verification_projection_procedure.py",
    "campaigns/verification_projection_campaign.yaml",
    "opensvf/spacecraft.yaml",
):
    assert (materialization / relative).is_file(), relative
PY
cp "$verification_output/integration_result.json" \
  "$evidence/verification-integration-result.json"
cp "$verification_output/verification_projection/verification_projection_plan.json" \
  "$evidence/verification-projection-plan.json"
cp "$verification_output/verification_projection/opensvf/materialization_manifest.json" \
  "$evidence/opensvf-materialization-manifest.json"

orbitfabric adapter remove "$INSTANCE_ID" --json | tee "$evidence/remove.json"
orbitfabric adapter list --json | tee "$evidence/final-inventory.json"
EVIDENCE="$evidence" python - <<'PY'
import json
import os
from pathlib import Path

inventory = json.loads(
    (Path(os.environ["EVIDENCE"]) / "final-inventory.json").read_text(encoding="utf-8")
)
assert inventory == []
PY
