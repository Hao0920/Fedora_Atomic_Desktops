
#!/usr/bin/env bash
# Build an interactive Anaconda installer ISO from a published image.
# Usage: ./build-iso.sh [latest|amd|nvidia-latest|nvidia-580lts]

set -Eeuo pipefail

IMAGE_REPO="ghcr.io/hao0920/fedora-atomic-desktops"
IMAGE_TAG="${1:-latest}"
ISO_NAME="fedora-atomic-desktops-${IMAGE_TAG}.iso"

case "${IMAGE_TAG}" in
  latest|amd|nvidia-latest|nvidia-580lts) ;;
  *)
    echo "Unknown image tag: ${IMAGE_TAG}" >&2
    echo "Valid tags: latest, amd, nvidia-latest, nvidia-580lts" >&2
    exit 2
    ;;
esac

IMAGE="${IMAGE_REPO}:${IMAGE_TAG}"

echo "Building Anaconda installer ISO"
echo "Image: ${IMAGE}"
echo "ISO: ${ISO_NAME}"

sudo bluebuild generate-iso \
  --iso-name "${ISO_NAME}" \
  image "${IMAGE}"

echo "ISO generation finished: ${ISO_NAME}"
