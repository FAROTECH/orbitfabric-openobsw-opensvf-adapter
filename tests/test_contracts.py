from __future__ import annotations

import json
from importlib.resources import files
from pathlib import Path

from orbitfabric.conformance.integration_contracts import validate_manifest

from orbitfabric_openobsw_opensvf_adapter.adapter.profile import load_projection_profile

ROOT = Path(__file__).resolve().parents[1]


def test_manifest_conforms_to_core_contract() -> None:
    manifest_path = files("orbitfabric_openobsw_opensvf_adapter").joinpath(
        "integration_package.json"
    )
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))

    validate_manifest(manifest)

    assert {item["id"] for item in manifest["operations"]} == {
        "project",
        "verification_projection",
    }
    assert manifest["execution"]["protocol"] == "orbitfabric.adapter_cli.v1"


def test_reference_profile_conforms_to_adapter_schema() -> None:
    profile = load_projection_profile(ROOT / "examples" / "profile.yaml")

    assert profile.document["integration"]["id"] == "orbitfabric-openobsw-opensvf"
    assert profile.document["settings"]["compatibility"]["target_baseline"] == (
        "openobsw-0.7.0-obsw-srdb-0.1.0-reference"
    )
