#!/usr/bin/env bash
# Report a suitable image tag for the detected display controller.
# This is a diagnostic helper; it does not install or switch the running system.

set -Eeuo pipefail

GPU_INFO="$(lspci -nn | grep -Ei 'VGA compatible controller|3D controller|Display controller' || true)"

if grep -qi 'NVIDIA' <<<"${GPU_INFO}"; then
  # Maxwell / Pascal / Volta need the NVIDIA 580 legacy branch.
  if grep -qiE 'GM[0-9]{3}|GP[0-9]{3}|GTX 9[0-9]{2}|GTX 10[0-9]{2}|Maxwell|Pascal|Volta' <<<"${GPU_INFO}"; then
    echo "nvidia-580lts"
  else
    echo "nvidia-latest"
  fi
elif grep -qiE 'AMD|Radeon' <<<"${GPU_INFO}"; then
  echo "amd"
elif grep -qi 'Intel' <<<"${GPU_INFO}"; then
  echo "latest"
else
  echo "latest"
fi
