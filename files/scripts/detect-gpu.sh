#!/bin/bash
# 显卡检测脚本
# 输出: nvidia-latest / nvidia-580lts / amd / intel / none

set -e

GPU_INFO=$(lspci | grep -i vga || true)

# 检测 NVIDIA
if echo "$GPU_INFO" | grep -qi nvidia; then
    # 获取详细型号
    NVIDIA_MODEL=$(lspci -nn | grep -i nvidia | head -1)
    
    # Maxwell/Pascal 检测 (GTX 900/10xx 系列)
    if echo "$NVIDIA_MODEL" | grep -qiE "GM[0-9]{3}|GP[0-9]{3}|GTX 9[0-9]{2}|GTX 10[0-9]{2}|Maxwell|Pascal"; then
        echo "nvidia-580lts"
    else
        echo "nvidia-latest"
    fi
    exit 0
fi

# 检测 AMD
if echo "$GPU_INFO" | grep -qiE "amd|radeon"; then
    echo "amd"
    exit 0
fi

# 检测 Intel
if echo "$GPU_INFO" | grep -qi intel; then
    echo "intel"
    exit 0
fi

# 无独显
echo "none"
