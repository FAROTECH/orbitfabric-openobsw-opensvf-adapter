from __future__ import annotations

import hashlib
import json
from pathlib import Path

import rfc8785

SURFACE_SPECS = {
    "entity_index": ("required", "orbitfabric.entity_index", "0.1", "entity_index.json"),
    "lint_report": ("required", "orbitfabric-lint", "v1", "lint_report.json"),
    "mission_snapshot": (
        "required",
        "orbitfabric.mission_snapshot",
        "0.1-candidate",
        "mission_snapshot.json",
    ),
    "model_summary": ("companion", "orbitfabric.model_summary", "0.1", "model_summary.json"),
    "relationship_manifest": (
        "required",
        "orbitfabric.relationship_manifest",
        "0.1-candidate",
        "relationship_manifest.json",
    ),
}


def _write_json(path: Path, payload: dict) -> str:
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return hashlib.sha256(path.read_bytes()).hexdigest()


def _input_set_digest(manifest: dict) -> str:
    surfaces = [
        {
            "role": record["role"],
            "requirement": record["requirement"],
            "status": record["status"],
            "kind": record["kind"],
            "format_version": record["format_version"],
            "sha256": record["sha256"],
            "unavailable_reason": record["unavailable_reason"],
        }
        for record in sorted(manifest["surfaces"], key=lambda item: item["role"])
    ]
    payload = {
        "kind": manifest["kind"],
        "input_set_version": manifest["input_set_version"],
        "orbitfabric_version": manifest["orbitfabric_version"],
        "mission": manifest["mission"],
        "load_result": manifest["load_result"],
        "lint_result": manifest["lint_result"],
        "surfaces": surfaces,
    }
    return hashlib.sha256(rfc8785.dumps(payload)).hexdigest()


def build_input_set(root: Path, *, packet_members: list[str] | None = None) -> Path:
    if packet_members is None:
        packet_members = ["eps.obc.bus_voltage_mv"]
    mission = {"id": "poc-cubesat", "model_version": "0.1.0"}
    model = {
        "telemetry": [
            {
                "id": "eps.obc.bus_voltage_mv",
                "name": "OBC Bus Voltage",
                "type": "uint16",
                "unit": "mV",
                "source": "eps",
                "limits": {"warning_high": 3500},
                "description": "OBC bus voltage.",
            }
        ],
        "commands": [
            {"id": "obc.ping", "target": "obc", "arguments": [], "description": "Ping command."}
        ],
        "events": [
            {
                "id": "obc.ping_requested",
                "source": "obc",
                "severity": "info",
                "description": "Ping requested.",
            },
            {
                "id": "eps.voltage_out_of_bounds",
                "source": "eps",
                "severity": "warning",
                "description": "Voltage out of bounds.",
            },
        ],
        "packets": [
            {
                "id": "obc_hk",
                "name": "OBC Housekeeping Packet",
                "telemetry": packet_members,
                "description": "OBC housekeeping.",
            }
        ],
    }
    payloads = {
        "mission_snapshot": {
            "kind": "orbitfabric.mission_snapshot",
            "snapshot_version": "0.1-candidate",
            "result": "loaded",
            "mission": mission,
            "model": model,
        },
        "entity_index": {
            "kind": "orbitfabric.entity_index",
            "index_version": "0.1",
            "mission": mission,
            "entities": [
                {"domain": domain, "id": item["id"], "entity_type": domain}
                for domain, items in model.items()
                for item in items
            ],
        },
        "relationship_manifest": {
            "kind": "orbitfabric.relationship_manifest",
            "manifest_version": "0.1-candidate",
            "mission": mission,
            "relationships": [],
        },
        "lint_report": {
            "tool": "orbitfabric-lint",
            "version": "1.2.0",
            "result": "passed",
            "mission": mission["id"],
            "model_version": mission["model_version"],
            "findings": [],
        },
        "model_summary": {
            "kind": "orbitfabric.model_summary",
            "summary_version": "0.1",
            "mission": mission,
        },
    }
    surfaces = []
    for role in sorted(SURFACE_SPECS):
        requirement, kind, format_version, filename = SURFACE_SPECS[role]
        digest = _write_json(root / filename, payloads[role])
        surfaces.append(
            {
                "role": role,
                "requirement": requirement,
                "status": "available",
                "kind": kind,
                "format_version": format_version,
                "path": filename,
                "sha256": digest,
                "unavailable_reason": None,
            }
        )
    manifest = {
        "kind": "orbitfabric.integration_input_set",
        "input_set_version": "0.1-candidate",
        "orbitfabric_version": "1.2.0",
        "mission": mission,
        "load_result": "loaded",
        "lint_result": "passed",
        "surfaces": surfaces,
    }
    manifest["input_set_sha256"] = _input_set_digest(manifest)
    manifest_path = root / "integration_input_manifest.json"
    _write_json(manifest_path, manifest)
    return manifest_path
