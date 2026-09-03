#!/usr/bin/env bash
set -euo pipefail

root="${GITHUB_WORKSPACE:?GITHUB_WORKSPACE is required}"
target="$root/_opensvf"
work="/tmp/orbitfabric-opensvf-target-compatibility"
core_input="$work/core-input"
output="$work/adapter-output"
evidence="$work/evidence"
scenario="$root/tests/fixtures/lifecycle/scenarios/ping_verification.yaml"
profile="$root/examples/profile.yaml"

rm -rf "$work"
mkdir -p "$evidence"

orbitfabric export integration-input-set \
  "$root/tests/fixtures/lifecycle/mission" \
  --output-dir "$core_input"

orbitfabric-openobsw-opensvf run \
  --operation verification_projection \
  --input-set-manifest "$core_input/integration_input_manifest.json" \
  --profile "$profile" \
  --operation-input scenario "$scenario" \
  --output-dir "$output"

materialized="$output/verification_projection/opensvf"
spacecraft="$materialized/opensvf/spacecraft.yaml"
campaign="$materialized/campaigns/verification_projection_campaign.yaml"
procedure="$materialized/procedures/verification_projection_procedure.py"
manifest="$materialized/materialization_manifest.json"

for path in "$spacecraft" "$campaign" "$procedure" "$manifest"; do
  test -s "$path"
done

# OpenSVF-native pre-flight validation. This deliberately does not start
# DDS, an FMU, or an OBSW process.
svf validate "$spacecraft" | tee "$evidence/spacecraft-validation.txt"

TARGET="$target" CAMPAIGN="$campaign" PROCEDURE="$procedure" EVIDENCE="$evidence" python - <<'PY'
from __future__ import annotations

import importlib.metadata
import json
import os
from pathlib import Path

from svf.campaign.campaign_runner import CampaignRunner
from svf.campaign.procedure import Procedure

campaign = Path(os.environ["CAMPAIGN"])
procedure = Path(os.environ["PROCEDURE"])
evidence = Path(os.environ["EVIDENCE"])

runner = CampaignRunner.from_yaml(campaign)
procedures = runner._procedures
assert len(procedures) == 1, procedures
procedure_type = procedures[0]
assert issubclass(procedure_type, Procedure)
instance = procedure_type()
assert instance.id == "OF-VPROJ-ping_verification"
assert instance.title == "Verification projection: Ping verification"
assert procedure_type.__module__ == procedure.stem

package_version = importlib.metadata.version("opensvf")
assert package_version == "1.0.0", package_version

report = {
    "kind": "orbitfabric.opensvf_target_compatibility",
    "status": "PASS",
    "opensvf_commit": "667d3eadcb0bbd7814ac324b99946c4ed2f11f23",
    "opensvf_package_version": package_version,
    "checks": [
        "spacecraft_preflight_validation",
        "campaign_native_load",
        "generated_procedure_native_import",
    ],
}
(evidence / "target-acceptance.json").write_text(
    json.dumps(report, indent=2, sort_keys=True) + "\n",
    encoding="utf-8",
)
PY

cp "$output/integration_result.json" "$evidence/integration-result.json"
cp "$output/verification_projection/verification_projection_plan.json" \
  "$evidence/verification-projection-plan.json"
cp "$manifest" "$evidence/materialization-manifest.json"
cp "$campaign" "$evidence/verification-projection-campaign.yaml"
cp "$procedure" "$evidence/verification-projection-procedure.py"
cp "$spacecraft" "$evidence/spacecraft.yaml"
