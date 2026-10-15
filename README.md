# iStoreOS for 友善 NanoPi R1S H5（对齐官方 512MB：GL-MT3000）

源码：[bluewyj/istoreos](https://github.com/bluewyj/istoreos) · 分支 `istoreos-24.10`  
目标：`sunxi/cortexa53` / `friendlyarm_nanopi-r1s-h5`

软件包按官方 **GL-MT3000（512MB）** 固件实机清单对齐  
（参考：`istoreos-21.02-2025112415-mt3000`），**不是** armsr/R2S 那套大内存全量 NAS。

## 对齐说明

| 项目 | 处理 |
|---|---|
| 参考机型 | 官方 [GL-MT3000](https://fw.koolcenter.com/iStoreOS/mt3000/)（512MB） |
| 含 | 商店、QuickStart、OTA、易有云、DDNSTO、DiskMan、Samba、NFS、CIFS、文件传输、cpufreq、zram |
| 不含 | Docker、OAF、MergerFS、板载 WiFi、MTK WiFi/风扇（MT3000 专有） |
| LAN | **192.168.5.1**（MT3000 官方默认 192.168.100.1，本板按你要求改） |
| 根分区 | **两版**：`370m`（370 MiB，日常推荐） / `20g`（20480 MiB，大空间） |

## 刷机

1. 下载对应规格的 **`*-squashfs-sdcard.img.gz`**，**先解压**成 `.img`。  
   - `370m`：TF ≥4GB 即可  
   - `20g`：TF **≥32GB**；解压后约 20GB+，刷写较慢  
2. Rufus / balenaEtcher 写入 TF（Class10+）。  
3. **5V/2A** 供电；PWR 亮、STAT（红）心跳闪 = 系统在跑。  
4. 网线接丝印 **LAN**（USB RTL8153 → `eth1` / `r8152`）；WAN 是板载 `eth0`。  
   - 板载绿灯：`green:lan` 跟 eth1，`green:wan` 跟 eth0（有链路/收发才亮）。  
   - 若网口只闪黄、不闪绿且拿不到 IP：多半是 LAN（USB）未起来，不是“没刷上系统”。  
5. 管理地址：`http://192.168.5.1`（用户 `root`）。  
   - 若不通，先试 `http://192.168.100.1`（iStoreOS 原厂默认）。  
   - 对照可运行机（pudie88 ImmortalWrt 23.05）为 `192.168.10.1`，勿混淆。

## 与可运行 ImmortalWrt 的差异（实机对照）

| 项 | 可运行机（SSH 实测） | 本仓库 iStoreOS |
|---|---|---|
| 系统 | ImmortalWrt **23.05** / 内核 **5.15** | iStoreOS **24.10** / 内核 **6.6** |
| LAN/WAN | `br-lan`←**eth1/r8152**，wan←**eth0/dwmac** | 同映射（board.d + 启动等待绑定） |
| USB 固件 | 必有 `r8152-firmware`，dmesg：`load rtl8153b-2 ... successfully` | 配置已钉死 `CONFIG_PACKAGE_r8152-firmware=y` |
| 内存占用 | 空闲约 **350MB**/512MB（包集轻） | 对齐 MT3000，首启更重；已加 zram + USB-LAN 早启 |

## 编译

推到 GitHub → Actions 写权限 → 运行 `Build iStoreOS (NanoPi R1S H5)`。  
手动触发可选 `370m` / `20g` / `both`（默认两者都编）。  
配置文件：`configs/nanopi-r1s-h5.config`、`configs/nanopi-r1s-h5-20g.config`（仅 `ROOTFS_PARTSIZE` 不同；两版都出 squashfs + ext4）。

本仓库与 `nanopi-r1s-h5-immortalwrt` 独立，互不修改。
