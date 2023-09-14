#!/bin/bash
#
# Copyright (c) 2023 Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

set -ex

num_configs=$(echo ${TF_CONFIG_LIST} | wc -w)

cnt=1

for TF_CONFIG in ${TF_CONFIG_LIST}; do
    echo "============== ${TF_CONFIG} (${cnt}/${num_configs}) =============="
    export TF_CONFIG
    detachLicense 3000
    time tf-a-ci-scripts/eclair/build-tfa.sh ${TF_CONFIG}
    cnt=$((cnt + 1))
done
