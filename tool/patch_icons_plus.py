#!/usr/bin/env python3
"""Patch icons_plus 5.0.0 in the local pub cache for Dart 3.14+ compatibility.

Flutter 3.50.1 / Dart 3.14 marks `IconData` as `final class IconData`, which
causes `icons_plus` 5.0.0's `*IconData extends IconData` wrapper classes to fail
compilation on clean CI runners. This script removes those wrapper classes and
uses `IconData(...)` directly.
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from urllib.parse import unquote, urlparse

CLASS_PATTERN = re.compile(
    r"class\s+(\w+)\s+extends\s+IconData\s*\{[^}]*\}\s*",
    re.MULTILINE | re.DOTALL,
)


def find_icons_plus_dir(repo_root: Path) -> Path:
    pkg_config = repo_root / ".dart_tool" / "package_config.json"
    if not pkg_config.is_file():
        raise FileNotFoundError(f"Missing {pkg_config}. Run 'flutter pub get' first.")

    data = json.loads(pkg_config.read_text(encoding="utf-8"))
    for pkg in data.get("packages", []):
        if pkg.get("name") == "icons_plus":
            root_uri = pkg["rootUri"]
            parsed = urlparse(root_uri)
            if parsed.scheme == "file":
                path_str = unquote(parsed.path)
                # Handle Windows drive paths like /C:/Users/...
                if len(path_str) >= 3 and path_str[0] == "/" and path_str[2] == ":":
                    path_str = path_str[1:]
                return Path(path_str)
            return (pkg_config.parent / root_uri).resolve()

    raise RuntimeError("Package 'icons_plus' not found in package_config.json.")


def patch_icons_plus(icons_dir: Path) -> int:
    src_dir = icons_dir / "lib" / "src"
    if not src_dir.is_dir():
        raise FileNotFoundError(f"Expected directory not found: {src_dir}")

    patched_files = 0
    for dart_file in sorted(src_dir.glob("*.dart")):
        content = dart_file.read_text(encoding="utf-8")
        matches = CLASS_PATTERN.findall(content)
        if not matches:
            continue

        updated = CLASS_PATTERN.sub("", content)
        for wrapper_name in matches:
            updated = re.sub(rf"\b{re.escape(wrapper_name)}\(", "IconData(", updated)

        if updated != content:
            dart_file.write_text(updated, encoding="utf-8")
            patched_files += 1

    return patched_files


def main() -> None:
    repo_root = Path(__file__).resolve().parent.parent
    icons_dir = find_icons_plus_dir(repo_root)
    count = patch_icons_plus(icons_dir)
    print(f"icons_plus directory: {icons_dir}")
    print(f"Patched {count} file(s) in icons_plus.")


if __name__ == "__main__":
    main()
