#!/system/bin/sh
# ==============================================================================
# GameHub & Media Optimizer for Lenovo Legion Y700 Gen 4 (Snapdragon 8 Elite)
# Author: Sapatekno / WildKernels
# ==============================================================================

LOG_FILE="/data/local/tmp/gamehub_tweaks.log"
exec 1>>"$LOG_FILE" 2>&1
echo "=== [$(date)] System & GameHub Optimizer Initializing ==="

# Tunggu boot selesai sepenuhnya agar tidak mengganggu inisialisasi Android
until [ "$(getprop sys.boot_completed)" = "1" ]; do
    sleep 2
done
sleep 3

# 1. Driver NTSync Permissions (GameHub Wine x64)
if [ -e /dev/ntsync ]; then
    chmod 0666 /dev/ntsync
    echo "[OK] /dev/ntsync permission set to 0666"
fi

# 2. Virtual Memory & File Descriptors (Cegah crash game x64 / UE4/5)
sysctl -w vm.max_map_count=1048576
sysctl -w fs.file-max=2097152
echo "[OK] vm.max_map_count set to 1048576"

# 3. MGLRU & Memory Reclaim Tuning (Cegah frame drops saat memuat aset besar)
sysctl -w vm.watermark_boost_factor=0
sysctl -w vm.watermark_scale_factor=10
sysctl -w vm.vfs_cache_pressure=50
sysctl -w vm.swappiness=60
echo "[OK] MGLRU & VM parameters optimized"

# 4. Storage I/O Optimization (UFS 4.0 Multi-Queue & F2FS)
for dev in /sys/block/sd* /sys/block/dm-* /sys/block/mmcblk*; do
    if [ -f "$dev/queue/scheduler" ]; then
        echo "none" > "$dev/queue/scheduler" 2>/dev/null || echo "mq-deadline" > "$dev/queue/scheduler" 2>/dev/null
    fi
    [ -f "$dev/queue/iostats" ] && echo "0" > "$dev/queue/iostats" 2>/dev/null
    [ -f "$dev/queue/read_ahead_kb" ] && echo "512" > "$dev/queue/read_ahead_kb" 2>/dev/null
done
echo "[OK] UFS 4.0 Storage I/O schedulers tuned to none/mq-deadline"

# 5. Snapdragon 8 Elite (Qualcomm Oryon / WALT Scheduler)
if [ -d /proc/sys/walt ]; then
    echo 85 > /proc/sys/walt/sched_upmigrate 2>/dev/null
    echo 65 > /proc/sys/walt/sched_downmigrate 2>/dev/null
    echo 1 > /proc/sys/walt/sched_low_latency 2>/dev/null
    echo "[OK] Qualcomm Oryon WALT scheduler low-latency mode applied"
fi

# 6. Audio Low-Latency (AAudio MMAP Hardware Direct Buffer)
setprop aaudio.mmap_policy 1 2>/dev/null || true
setprop aaudio.mmap_exclusive_policy 1 2>/dev/null || true
echo "[OK] AAudio MMAP Low-Latency policy enabled"

echo "=== [$(date)] Optimizer successfully completed ==="
