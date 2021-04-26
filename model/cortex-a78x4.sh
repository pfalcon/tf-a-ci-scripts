#!/usr/bin/env bash
#
# Copyright (c) 2020, Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

set_model_path "$warehouse/SysGen/Models/$model_version/$model_build/external/models/$model_flavour/FVP_Base_Cortex-A78x4"

# Option not supported on A78 FVP yet.
export no_quantum=""

source "$ci_root/model/fvp_common.sh"
