#
# Copyright (c) 2023 Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
export CROSS_COMPILE=aarch64-none-elf-
export CROSS_COMPILE2=arm-none-eabi-
export CC_ALIASES="${CROSS_COMPILE}gcc"
export CC_ALIASES="${CC_ALIASES} ${CROSS_COMPILE2}gcc"
export CXX_ALIASES="${CROSS_COMPILE}g++"
export LD_ALIASES="${CROSS_COMPILE}ld"
export AR_ALIASES="${CROSS_COMPILE}ar"
export AS_ALIASES="${CROSS_COMPILE}as"
export FILEMANIP_ALIASES="cp mv ${CROSS_COMPILE}objcopy"
export ECLAIR_PROJECT_NAME="TF_A_${JOB_NAME}_${BUILD_NUMBER}"
export ECLAIR_PROJECT_ROOT="${WORKSPACE}/trusted-firmware-a"
