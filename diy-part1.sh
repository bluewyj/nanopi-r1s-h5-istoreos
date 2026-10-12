#!/bin/bash
#
# diy-part1.sh
# 执行时机：`./scripts/feeds update -a` 之前
#
# 作用：追加官方 iStoreOS 额外 feeds（商店 / QuickStart / DiskMan / 易有云等）。
#       软件集对齐官方 512MB 机型 GL-MT3000；不追加无线驱动源。
#
set -e

OPENWRT_DIR="${GITHUB_WORKSPACE:-$(pwd)}/openwrt"
FEEDS_FILE="${OPENWRT_DIR}/feeds.conf.default"

echo "==> [diy-part1] 源码目录: ${OPENWRT_DIR}"
echo "==> [diy-part1] 当前 feeds.conf.default:"
cat "${FEEDS_FILE}"

# ---------------------------------------------------------------------------
# 官方 iStoreOS 额外 feeds（与 fw0.koolcenter.com 发布固件一致）
# ---------------------------------------------------------------------------
cat >> "${FEEDS_FILE}" <<'EOF'

# --- NanoPi R1S H5 iStoreOS 额外源（本仓库 diy-part1 注入） ---
src-git third_party https://github.com/linkease/istore-packages.git;main
src-git diskman https://github.com/jjm2473/luci-app-diskman.git;dev
src-git oaf https://github.com/jjm2473/OpenAppFilter.git;dev7
src-git linkease_nas https://github.com/linkease/nas-packages.git;master
src-git linkease_nas_luci https://github.com/linkease/nas-packages-luci.git;main
src-git jjm2473_apps https://github.com/jjm2473/openwrt-apps.git;main
EOF

echo "==> [diy-part1] 完成后的 feeds.conf.default:"
cat "${FEEDS_FILE}"
echo "==> [diy-part1] 完成"
