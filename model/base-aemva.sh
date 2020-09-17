#!/usr/bin/env bash
#
# Copyright (c) 2019-2020, Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

set_model_path "$warehouse/SysGen/Models/$model_version/$model_build/models/$model_flavour/FVP_Base_AEMvA"

default_var sve_plugin_path "$warehouse/SysGen/PVModelLib/$model_version/$model_build/external/plugins/$model_flavour/sve2-HEAD/ScalableVectorExtension.so"

default_var is_dual_cluster 0

source "$ci_root/model/base-aemva-common.sh"
