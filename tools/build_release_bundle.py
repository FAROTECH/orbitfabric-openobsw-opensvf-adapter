from __future__ import annotations

import argparse
import hashlib
import json
import tomllib
from pathlib import Path
from typing import Any


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def discover_manifest(root: Path) -> Path:
    matches = sorted((root / "src").glob("*/integration_package.json"))
    if len(matches) != 1:
        raise ValueError(
            "Expected exactly one namespaced integration_package.json under src/, "
            f"found {len(matches)}"
        )
    return matches[0]


def project_version(pyproject_path: Path) -> str:
    payload = tomllib.loads(pyproject_path.read_text(encoding="utf-8"))
    version = payload.get("project", {}).get("version")
    if not isinstance(version, str) or not version:
        raise ValueError("pyproject.toml must define a non-empty project.version")
    return version


def build_release_descriptor(
    *,
    wheel: Path,
    manifest: Path,
    authority: str,
    publisher: str,
    name: str,
    release_version: str,
    artifact_id: str,
    artifact_type: str,
) -> dict[str, Any]:
    return {
        "kind": "orbitfabric.adapter_release",
        "descriptor_version": "0.1-candidate",
        "source_coordinate": {
            "authority": authority,
            "publisher": publisher,
            "name": name,
        },
        "release_version": release_version,
        "artifacts": [
            {
                "id": artifact_id,
                "artifact_type": artifact_type,
                "filename": wheel.name,
                "sha256": sha256_file(wheel),
                "size": wheel.stat().st_size,
            }
        ],
        "integration_package": {"sha256": sha256_file(manifest)},
    }


def build_project_lock(
    *,
    descriptor: dict[str, Any],
    descriptor_sha256: str,
    artifact_id: str,
    backend_id: str,
) -> dict[str, Any]:
    artifacts = {
        artifact["id"]: artifact
        for artifact in descriptor["artifacts"]
        if isinstance(artifact, dict) and isinstance(artifact.get("id"), str)
    }
    artifact = artifacts.get(artifact_id)
    if artifact is None:
        raise ValueError(f"Artifact id is not present in Release Descriptor: {artifact_id}")

    return {
        "kind": "orbitfabric.adapter_project_lock",
        "lock_version": "0.1-candidate",
        "adapters": [
            {
                "source_coordinate": descriptor["source_coordinate"],
                "release_version": descriptor["release_version"],
                "release_descriptor": {"sha256": descriptor_sha256},
                "artifact": {
                    "id": artifact_id,
                    "sha256": artifact["sha256"],
                },
                "installation_backend": {"id": backend_id},
            }
        ],
    }


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def parser() -> argparse.ArgumentParser:
    result = argparse.ArgumentParser(
        description="Build an exact OrbitFabric Adapter Release Descriptor and Project Lock."
    )
    result.add_argument("--wheel", type=Path, required=True)
    result.add_argument("--authority", required=True)
    result.add_argument("--publisher", required=True)
    result.add_argument("--name", required=True)
    result.add_argument("--output-dir", type=Path, default=Path("generated/release"))
    result.add_argument("--manifest", type=Path)
    result.add_argument("--pyproject", type=Path, default=Path("pyproject.toml"))
    result.add_argument("--release-version")
    result.add_argument("--artifact-id", default="python-wheel")
    result.add_argument("--artifact-type", default="python-wheel")
    result.add_argument("--backend-id", default="python-wheel-managed-env")
    return result


def main(argv: list[str] | None = None) -> int:
    args = parser().parse_args(argv)
    root = Path.cwd()
    wheel = args.wheel.resolve()
    if not wheel.is_file():
        raise SystemExit(f"Wheel does not exist: {wheel}")

    manifest = (args.manifest or discover_manifest(root)).resolve()
    if not manifest.is_file():
        raise SystemExit(f"Integration Package Manifest does not exist: {manifest}")

    version = args.release_version or project_version(args.pyproject)
    for label, value in (
        ("authority", args.authority),
        ("publisher", args.publisher),
        ("name", args.name),
        ("release version", version),
        ("artifact id", args.artifact_id),
        ("artifact type", args.artifact_type),
        ("backend id", args.backend_id),
    ):
        if not isinstance(value, str) or not value.strip():
            raise SystemExit(f"{label} must be non-empty")

    descriptor = build_release_descriptor(
        wheel=wheel,
        manifest=manifest,
        authority=args.authority.strip(),
        publisher=args.publisher.strip(),
        name=args.name.strip(),
        release_version=version.strip(),
        artifact_id=args.artifact_id.strip(),
        artifact_type=args.artifact_type.strip(),
    )

    output_dir = args.output_dir.resolve()
    descriptor_path = output_dir / "adapter-release.json"
    write_json(descriptor_path, descriptor)
    descriptor_sha = sha256_file(descriptor_path)

    lock = build_project_lock(
        descriptor=descriptor,
        descriptor_sha256=descriptor_sha,
        artifact_id=args.artifact_id.strip(),
        backend_id=args.backend_id.strip(),
    )
    lock_path = output_dir / "adapter-project-lock.json"
    write_json(lock_path, lock)

    sums_path = output_dir / "SHA256SUMS"
    sums_path.write_text(
        "\n".join(
            [
                f"{sha256_file(wheel)}  {wheel.name}",
                f"{descriptor_sha}  {descriptor_path.name}",
                f"{sha256_file(lock_path)}  {lock_path.name}",
                f"{sha256_file(manifest)}  {manifest.name}",
            ]
        )
        + "\n",
        encoding="utf-8",
    )

    print(f"Release Descriptor: {descriptor_path}")
    print(f"Project Lock: {lock_path}")
    print(f"SHA-256 summary: {sums_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
