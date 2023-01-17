#!/bin/bash

echo "Build EDK-II FD Image ..."
export WORKSPACE=`pwd`
export PACKAGES_PATH=$WORKSPACE/edk2:$WORKSPACE/edk2-platforms:$WORKSPACE/edk2-non-osi
export GCC5_AARCH64_PREFIX=aarch64-none-linux-gnu-

. edk2/edksetup.sh
build -a AARCH64 -t GCC5 -p Platform/Rockchip/RK3588/RK3588.dsc -D ROCKCHIP_PCIE30 -D ROCKCHIP_VOPEN -D ROCKCHIP_ACPIEN

echo "Build idblock Image ..."
./rkbin/tools/x86_64/mkimage \
    -n rk3588 -T rksd \
    -d rkbin/rk3588_ddr_lp4_2112MHz_lp5_2736MHz_v1.08.bin:rkbin/rk3588_spl_v1.11.bin \
    idblock.bin

echo "Build Rockchip Fit Image ..."
# FV Image
install Build/RK3588/DEBUG_GCC5/FV/BL33_AP_UEFI.Fv BL33_AP_UEFI.Fv

# FDT
install rkbin/UEFI.dtb UEFI.dtb

cat rkbin/UEFI.its | sed "s#@DEVICE@#UEFI#g" > UEFI.its

./rkbin/tools/x86_64/mkimage \
    -f UEFI.its -p 0x1000 -E RK3588_EFI.img

echo "Build SPI Image ..."
install Build/RK3588/DEBUG_GCC5/FV/NOR_FLASH_IMAGE.fd RK3588_NOR_FLASH.img

dd if=RK3588_NOR_FLASH.img of=nvdata.img bs=1K skip=7936
dd if=rkbin/rk3588_spi_nor_gpt.img of=RK3588_NOR_FLASH.img
dd if=idblock.bin of=RK3588_NOR_FLASH.img bs=1K seek=32
dd if=idblock.bin of=RK3588_NOR_FLASH.img bs=1K seek=544
dd if=RK3588_EFI.img of=RK3588_NOR_FLASH.img bs=1K seek=1024
dd if=nvdata.img of=RK3588_NOR_FLASH.img bs=1K seek=7936
echo "Target: RK3588_NOR_FLASH.img"