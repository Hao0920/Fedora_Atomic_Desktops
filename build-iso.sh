#!/bin/bash
# 构建 Live ISO
# 需要先构建并推送基础镜像

set -e

IMAGE="ghcr.io/Hao0920/Fedora_Atomic_Desktops:latest"
OUTPUT_DIR="./output"

echo "构建 Live ISO..."
echo "镜像: $IMAGE"

mkdir -p "$OUTPUT_DIR"

sudo podman run --rm --privileged \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  -v "$OUTPUT_DIR:/output" \
  -v ./files:/files:ro \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type iso \
  --target-arch x86_64 \
  --rootfs xfs \
  "$IMAGE"

echo "ISO 构建完成: $OUTPUT_DIR/*.iso"
