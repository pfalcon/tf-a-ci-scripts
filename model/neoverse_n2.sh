#!/usr/bin/env bash
#
# Copyright (c) 2020 Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

# model_version, model_build set in post_fetch_tf_resource
set_model_path "$warehouse/SysGen/Models/$model_version/$model_build/models/$model_flavour/FVP_Base_Neoverse-N2x4"

source "$ci_root/model/fvp_common.sh"
