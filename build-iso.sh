#!/usr/bin/env bash
# Build an installer ISO for one explicitly selected image variant.
# Usage: ./build-iso.sh [latest|amd|nvidia-latest|nvidia-580lts]
# Optional: ROOTFS=xfs|ext4|btrfs OUTPUT_DIR=./output ./build-iso.sh nvidia-580lts

set -Eeuo pipefail

IMAGE_REPO="ghcr.io/hao0920/fedora-atomic-desktops"
IMAGE_TAG="${1:-latest}"
ROOTFS="${ROOTFS:-ext4}"
OUTPUT_DIR="${OUTPUT_DIR:-./output}"

case "${IMAGE_TAG}" in
  latest|amd|nvidia-latest|nvidia-580lts) ;;
  *)
    echo "Unknown image tag: ${IMAGE_TAG}" >&2
    echo "Valid tags: latest, amd, nvidia-latest, nvidia-580lts" >&2
    exit 2
    ;;
esac

case "${ROOTFS}" in
  xfs|ext4|btrfs) ;;
  *)
    echo "Unsupported root filesystem: ${ROOTFS}" >&2
    echo "Valid filesystems: xfs, ext4, btrfs" >&2
    exit 2
    ;;
esac

IMAGE="${IMAGE_REPO}:${IMAGE_TAG}"

echo "Building installer ISO"
echo "Image: ${IMAGE}"
echo "Root filesystem: ${ROOTFS}"

mkdir -p "${OUTPUT_DIR}"

# bootc-image-builder uses the rootful Podman image store mounted below.
sudo podman pull "${IMAGE}"

sudo podman run --rm --privileged \
  --security-opt label=type:unconfined_t \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  -v /dev:/dev \
  -v "${OUTPUT_DIR}:/output" \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type iso \
  --target-arch x86_64 \
  --rootfs "${ROOTFS}" \
  "${IMAGE}"

echo "ISO build finished. Output directory: ${OUTPUT_DIR}"
