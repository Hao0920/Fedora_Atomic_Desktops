#!/bin/bash
# Live 环境显卡检测和镜像选择
# 需要 gum: https://github.com/charmbracelet/gum

set -e

IMAGE_REGISTRY="ghcr.io/hao0920/fedora-atomic-desktops"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 检查是否已运行过
if [ -f /var/lib/live-detect-done ]; then
    echo -e "${YELLOW}已检测过，跳过。${NC}"
    exit 0
fi

clear
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║         Fedora Atomic Desktops - 显卡检测与安装               ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# 检测显卡
echo -e "${YELLOW}正在检测显卡...${NC}"
DETECTED=$(detect-gpu.sh)
GPU_INFO=$(lspci | grep -i vga || echo "未知")

echo -e "${GREEN}检测到显卡: $GPU_INFO${NC}"
echo ""

# 显示推荐选项
case $DETECTED in
    nvidia-latest)
        RECOMMEND="nvidia-latest"
        DESC="NVIDIA 最新驱动 (推荐)"
        ;;
    nvidia-580lts)
        RECOMMEND="nvidia-580lts"
        DESC="NVIDIA 580 LTS (老显卡推荐)"
        ;;
    amd)
        RECOMMEND="amd"
        DESC="AMD 开源驱动 (推荐)"
        ;;
    intel)
        RECOMMEND="latest"
        DESC="Intel 核显 (基础版即可)"
        ;;
    none)
        RECOMMEND="latest"
        DESC="无独显 (基础版)"
        ;;
esac

# 使用 gum 显示选择界面
CHOICE=$(gum choose \
    --header "请选择要安装的版本:" \
    "$DESC" \
    "NVIDIA 最新驱动" \
    "NVIDIA 580 LTS (老显卡)" \
    "AMD 显卡" \
    "基础版 (无专有驱动)" \
    "取消安装")

# 解析选择
case $CHOICE in
    "$DESC"|"NVIDIA 最新驱动")
        TARGET="nvidia-latest"
        ;;
    "NVIDIA 580 LTS (老显卡)")
        TARGET="nvidia-580lts"
        ;;
    "AMD 显卡")
        TARGET="amd"
        ;;
    "基础版 (无专有驱动)")
        TARGET="latest"
        ;;
    "取消安装"|"")
        echo -e "${RED}已取消。${NC}"
        exit 1
        ;;
esac

# 确认
echo ""
echo -e "${YELLOW}将安装: $TARGET${NC}"
CONFIRM=$(gum confirm "确认安装?" && echo "yes" || echo "no")

if [ "$CONFIRM" != "yes" ]; then
    echo -e "${RED}已取消。${NC}"
    exit 1
fi

# 执行安装
echo ""
echo -e "${CYAN}正在安装系统...${NC}"
echo -e "${YELLOW}镜像: $IMAGE_REGISTRY:$TARGET${NC}"

if bootc switch "$IMAGE_REGISTRY:$TARGET"; then
    # 标记已完成
    touch /var/lib/live-detect-done
    
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    安装完成！                                 ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}请重启系统:${NC}"
    echo -e "  ${YELLOW}systemctl reboot${NC}"
    echo ""
    
    # 询问是否重启
    if gum confirm "立即重启?"; then
        systemctl reboot
    fi
else
    echo -e "${RED}安装失败！${NC}"
    exit 1
fi
