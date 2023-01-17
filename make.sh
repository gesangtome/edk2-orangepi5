#!/bin/bash

echo "Build EDK-II FD Image ..."
export WORKSPACE=`pwd`
export PACKAGES_PATH=$WORKSPACE/edk2:$WORKSPACE/edk2-platforms:$WORKSPACE/edk2-non-osi
export GCC5_AARCH64_PREFIX=aarch64-none-linux-gnu-

. edk2/edksetup.sh
build -a AARCH64 -t GCC5 -p Platform/Rockchip/RK3588/RK3588.dsc -D ROCKCHIP_PCIE30 -D ROCKCHIP_VOPEN -D ROCKCHIP_ACPIEN

