#!/usr/bin/env python3
"""Rewrite OpenWrt scripts/projectsmirrors.json for GitHub-hosted runners.

Hosted runners are overseas: drop slow/broken CN mirrors, prefer CDN.
Must use JSON parse/dump — never sed-delete lines (trailing commas break JSON).
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path


def main() -> int:
    p = Path(sys.argv[1] if len(sys.argv) > 1 else "scripts/projectsmirrors.json")
    if not p.is_file():
        print(f"skip: {p} not found")
        return 0

    data = json.loads(p.read_text(encoding="utf-8"))
    drop = re.compile(r"(\.cn/|tencent|aliyun)", re.I)

    for key, urls in list(data.items()):
        if not isinstance(urls, list):
            continue
        kept = [u for u in urls if isinstance(u, str) and not drop.search(u)]
        seen, out = set(), []
        for u in kept:
            if u not in seen:
                seen.add(u)
                out.append(u)
        data[key] = out

    ow = data.get("@OPENWRT") or []
    pref = [
        "https://sources.cdn.openwrt.org",
        "https://sources.openwrt.org",
        "https://mirror2.openwrt.org/sources",
    ]
    ordered = []
    for u in pref + list(ow):
        if u not in ordered:
            ordered.append(u)
    data["@OPENWRT"] = ordered

    text = json.dumps(data, indent="\t", ensure_ascii=False) + "\n"
    json.loads(text)  # self-check
    p.write_text(text, encoding="utf-8")
    print("mirrors OK @OPENWRT=", data["@OPENWRT"])
    print("mirrors OK @DEBIAN=", data.get("@DEBIAN"))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
