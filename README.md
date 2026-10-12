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
| 根分区 | 2048 MiB |

## 刷机

1. 下载 **`*-squashfs-sdcard.img.gz`**，**先解压**成 `.img`。  
2. Rufus / balenaEtcher 写入 TF（Class10+）。  
3. **5V/2A** 供电；PWR 亮、STAT 闪 = 启动成功。  
4. 网线接 **LAN(eth1)** → `http://192.168.5.1`（用户 `root`）。

## 编译

推到 GitHub → Actions 写权限 → 运行 `Build iStoreOS (NanoPi R1S H5)`。

本仓库与 `nanopi-r1s-h5-immortalwrt` 独立，互不修改。
