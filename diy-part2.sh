#!/bin/bash
#
# diy-part2.sh
# 执行时机：feeds 安装完成、`make defconfig` 之前
#
# 作用：注入 files/；Argon；主机名 NanoPi-R1S-H5；LAN 192.168.5.1。
#       软件集对齐官方 MT3000（512MB）。
#
set -e

OPENWRT_DIR="${GITHUB_WORKSPACE:-$(pwd)}/openwrt"
SRC_FILES="${GITHUB_WORKSPACE:-$(pwd)}/files"

echo "==> [diy-part2] 注入自定义文件覆盖层"

if [ -d "${SRC_FILES}" ]; then
    rm -rf "${OPENWRT_DIR}/files"
    cp -rf "${SRC_FILES}" "${OPENWRT_DIR}/files"
    find "${OPENWRT_DIR}/files/etc" -type f \
         \( -path '*/uci-defaults/*' -o -path '*/init.d/*' -o -path '*/board.d/*' -o -path '*/hotplug.d/*' \) \
         -exec chmod 0755 {} \; 2>/dev/null || true
    echo "==> [diy-part2] 已注入:"
    find "${OPENWRT_DIR}/files" -type f | sed "s#${OPENWRT_DIR}/##"
else
    echo "!! 未找到 ${SRC_FILES}，跳过 files 注入"
fi

cd "${OPENWRT_DIR}"

# 默认主题：Argon（若 Makefile 仍指向 bootstrap）
if [ -f feeds/luci/collections/luci/Makefile ]; then
    sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile || true
fi

# 主机名 + 默认 LAN 地址
# 注意：iStoreOS 默认是 192.168.100.1（不是 OpenWrt 的 1.1）！
# 只 sed 1.1→5.1 会导致首启仍落在 100.1，表现为“5.1 无法联通”。
if [ -f package/base-files/files/bin/config_generate ]; then
    sed -i 's/OpenWrt/NanoPi-R1S-H5/g' package/base-files/files/bin/config_generate || true
    sed -i "s/hostname='iStoreOS'/hostname='NanoPi-R1S-H5'/g" package/base-files/files/bin/config_generate || true
    sed -i 's/192\.168\.100\.1/192.168.5.1/g' package/base-files/files/bin/config_generate || true
    sed -i 's/192\.168\.1\.1/192.168.5.1/g' package/base-files/files/bin/config_generate || true
    grep -nE '192\.168\.(100|5|1)\.1|hostname=' package/base-files/files/bin/config_generate | head -20 || true
fi

# ---------------------------------------------------------------------------
# 内核新符号钉死：避免 CI 非交互 syncconfig 卡在 (NEW)
# 现象：HWMON support for Realtek PHYs (REALTEK_PHY_HWMON) [N/y/?] (NEW)
# 原因：上游把 REALTEK_PHY_HWMON 改成用户可见，但 sunxi config 未收录
# 参考：https://github.com/openwrt/openwrt/pull/18677
# ---------------------------------------------------------------------------
pin_kconfig() {
    local cfg="$1" sym="$2" val="$3"
    [ -f "$cfg" ] || return 0
    if grep -q "^${sym}=" "$cfg"; then
        sed -i "s|^${sym}=.*|${sym}=${val}|" "$cfg"
    elif grep -q "^# ${sym} is not set" "$cfg"; then
        sed -i "s|^# ${sym} is not set|${sym}=${val}|" "$cfg"
    else
        echo "${sym}=${val}" >> "$cfg"
    fi
    echo "==> [diy-part2] kernel pin ${sym}=${val} -> ${cfg}"
}
for cfg in \
    target/linux/sunxi/config-6.6 \
    target/linux/sunxi/cortexa53/config-6.6
do
    pin_kconfig "$cfg" CONFIG_REALTEK_PHY_HWMON y
done

echo "==> [diy-part2] 完成"
