from __future__ import annotations

import json
from pathlib import Path

from orbitfabric_openobsw_opensvf_adapter.adapter.preflight import run_project
from tests.helpers import build_input_set

ROOT = Path(__file__).resolve().parents[1]
PROFILE = ROOT / "examples" / "profile.yaml"


def test_reference_projection_resolves_real_target_mappings(tmp_path: Path) -> None:
    manifest = build_input_set(tmp_path)
    result = run_project(manifest, PROFILE)

    assert result["result"] == "succeeded"
    assert [item["id"] for item in result["mappings"]] == [
        "mapping.cmd.ping",
        "mapping.event.voltage_out_of_bounds",
        "mapping.packet.obc_hk",
        "mapping.tm.obc_bus_voltage",
    ]
    resolutions = {item["id"]: item["value"] for item in result["resolutions"]}
    assert resolutions["resolution.cmd.ping.target_action"] == "reuse_existing"
    assert resolutions["resolution.cmd.ping.target_name"] == "are_you_alive"
    assert resolutions["resolution.event.voltage_out_of_bounds.severity"] == "MEDIUM"


def test_project_materializes_openobsw_and_srdb_artifacts(tmp_path: Path) -> None:
    manifest = build_input_set(tmp_path)
    output = tmp_path / "output"
    result = run_project(manifest, PROFILE, output_dir=output)

    assert result["result"] == "succeeded"
    header = (output / "flight_software" / "mission_contract.h").read_text(encoding="utf-8")
    assert "OF_TM_OBC_BUS_VOLTAGE_MV = 0x6001" in header
    assert "OF_CMD_PING = 0x1701" in header
    assert "OF_EVENT_VOLTAGE_OUT_OF_BOUNDS = 0x5001" in header
    contribution = json.loads(
        (output / "obsw_srdb_contribution" / "contribution_manifest.json").read_text(
            encoding="utf-8"
        )
    )
    assert contribution["mode"] == "additive"
    assert contribution["complete_srdb"] is False
    assert contribution["reused_targets"][0]["id"] == "are_you_alive"


def test_tampered_core_surface_fails_closed(tmp_path: Path) -> None:
    manifest = build_input_set(tmp_path)
    snapshot = tmp_path / "mission_snapshot.json"
    snapshot.write_text(snapshot.read_text(encoding="utf-8") + " ", encoding="utf-8")

    from orbitfabric_openobsw_opensvf_adapter.adapter.model import AdapterFailure

    try:
        run_project(manifest, PROFILE)
    except AdapterFailure as exc:
        assert exc.code == "OFI-INPUT-SURFACE-002"
    else:
        raise AssertionError("Tampered Core surface was accepted")
