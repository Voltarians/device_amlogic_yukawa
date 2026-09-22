# Promethean VIM3 3 GiB Super-Partition Geometry

Status: **ACCEPTED**
Acceptance date: 2026-09-22

This note documents the dynamic-partition geometry required by Promethean Core on the Khadas VIM3 Pro and the reason for the VIM3-specific override in `yukawa/BoardConfig.mk`.

## Accepted source commit

- Branch: `promethean-vim3-super-3g`
- Commit: `eb21bf8`
- Message: `Match VIM3 super geometry to physical 3 GiB partition`

Companion VIM3 Ethernet RRO:

- Repository: `Voltarians/device_snappautomotive_vim3`
- Branch: `promethean-vim3-ethernet`
- Commit: `d4689a6`

## Physical hardware geometry

The actual VIM3 `super` GPT partition was measured from the running board:

```text
/dev/block/by-name/super = 3221225472 bytes
                         = 0xC0000000
                         = 3 GiB
```

Before correction, the installed LP metadata described a smaller backing device:

```text
Installed LP metadata super size = 2415919104 bytes
```

The original non-A/B Yukawa build configuration also described a smaller super partition:

```text
BOARD_SUPER_PARTITION_SIZE = 2625634304
BOARD_DB_DYNAMIC_PARTITIONS_SIZE = 2621440000
```

This disagreement caused dynamic-partition metadata writes to fail. A logical `system` flash in fastbootd failed before any payload write:

```text
Resizing 'system' FAILED (remote: 'Failed to write partition table')
```

## Accepted VIM3-specific override

The VIM3/Snapp product resolves to `TARGET_DEVICE=yukawa`, so the device-specific override is placed after `BoardConfigCommon.mk` in:

`yukawa/BoardConfig.mk`

Accepted override:

```make
# Promethean VIM3 physical super geometry
ifeq ($(TARGET_PRODUCT),snapp_car_vim3)
BOARD_SUPER_PARTITION_SIZE := 3221225472
BOARD_DB_DYNAMIC_PARTITIONS_SIZE := 3217031168
endif
```

This keeps the override scoped to `snapp_car_vim3` rather than changing every Yukawa target.

The dynamic group reserves 4 MiB for metadata:

```text
3221225472 - 4194304 = 3217031168
```

## Verify resolved build variables

From the AAOS root:

```bash
source build/envsetup.sh
export TARGET_KERNEL_USE=5.15
lunch snapp_car_vim3-ap3a-userdebug

echo "TARGET_PRODUCT=$(get_build_var TARGET_PRODUCT)"
echo "TARGET_DEVICE=$(get_build_var TARGET_DEVICE)"
echo "BOARD_SUPER_PARTITION_SIZE=$(get_build_var BOARD_SUPER_PARTITION_SIZE)"
echo "BOARD_DB_DYNAMIC_PARTITIONS_SIZE=$(get_build_var BOARD_DB_DYNAMIC_PARTITIONS_SIZE)"
```

Accepted output:

```text
TARGET_PRODUCT=snapp_car_vim3
TARGET_DEVICE=yukawa
BOARD_SUPER_PARTITION_SIZE=3221225472
BOARD_DB_DYNAMIC_PARTITIONS_SIZE=3217031168
```

## Build and verify super.img

Build:

```bash
m superimage -j2
```

Accepted image SHA256:

```text
75949c296255c9494747abb236a1097e3ed5d48aaf089a6789b36e325b662ce4
```

Convert the sparse image to raw for LP inspection:

```bash
rm -f /tmp/yukawa-super-3g.raw.img

out/host/linux-x86/bin/simg2img \
  out/target/product/yukawa/super.img \
  /tmp/yukawa-super-3g.raw.img

stat -c '%s bytes' /tmp/yukawa-super-3g.raw.img

out/host/linux-x86/bin/lpdump \
  /tmp/yukawa-super-3g.raw.img 2>&1 | head -160
```

Accepted raw image size:

```text
3221225472 bytes
```

Accepted LP metadata:

```text
Block device table:
  Partition name: super
  First sector: 2048
  Size: 3221225472 bytes

Group table:
  Name: db_dynamic_partitions
  Maximum size: 3217031168 bytes
```

The accepted image contained:

```text
system: 3387504 sectors
vendor: 366640 sectors
```

## Hardware verification

Before flashing, bootloader fastboot must report:

```text
is-userspace: no
partition-size:super: 0x00000000c0000000
```

After flashing and booting, Android `lpdump` must report:

```text
Partition name: super
Size: 3221225472 bytes

Name: db_dynamic_partitions
Maximum size: 3217031168 bytes
```

## Flashing rule

For this accepted baseline, do not rely on `fastboot flash system` in fastbootd when the installed LP metadata has the old size. Host fastboot attempts to resize the logical partition first, and that path failed against the mismatched metadata.

The tested method is:

1. Build a complete `super.img` with the 3 GiB geometry.
2. Keep a full backup of the existing physical `super` partition.
3. Reboot to bootloader fastboot, not fastbootd.
4. Confirm `is-userspace: no`.
5. Confirm `partition-size:super: 0xC0000000`.
6. Flash the complete sparse `super.img` to the physical `super` partition.
7. Reboot and verify `lpdump`.

This procedure was hardware-tested successfully on the Promethean Core Khadas VIM3 baseline.
