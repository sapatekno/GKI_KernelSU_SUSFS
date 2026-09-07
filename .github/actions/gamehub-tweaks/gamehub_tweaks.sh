#!/system/bin/sh
# GameHub Kernel Optimizer for Lenovo Legion Y700 Gen 4 (Snapdragon 8 Elite)
[ -e /dev/ntsync ] && chmod 0666 /dev/ntsync
sysctl -w vm.max_map_count=1048576 2>/dev/null || true
sysctl -w fs.file-max=2097152 2>/dev/null || true
sysctl -w vm.watermark_boost_factor=0 2>/dev/null || true
sysctl -w vm.watermark_scale_factor=10 2>/dev/null || true
sysctl -w vm.vfs_cache_pressure=50 2>/dev/null || true
sysctl -w vm.swappiness=60 2>/dev/null || true
for dev in /sys/block/sd* /sys/block/dm-* /sys/block/mmcblk*; do
  [ -f "$dev/queue/scheduler" ] && (echo "none" > "$dev/queue/scheduler" 2>/dev/null || echo "mq-deadline" > "$dev/queue/scheduler" 2>/dev/null)
  [ -f "$dev/queue/iostats" ] && echo "0" > "$dev/queue/iostats" 2>/dev/null || true
  [ -f "$dev/queue/read_ahead_kb" ] && echo "512" > "$dev/queue/read_ahead_kb" 2>/dev/null || true
done
