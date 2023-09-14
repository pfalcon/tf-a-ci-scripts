#!/bin/bash
#
# Copyright (c) 2021-2022 BUGSENG srl. All rights reserved.
# Copyright (c) 2022 Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause

set -ex

. tf-a-ci-scripts/eclair/analyze_common2.sh

env

cd ${WORKSPACE}/trusted-firmware-a
make clean DEBUG=${DEBUG}

# Replace '$(PWD)' with the *current* $PWD.
MAKE_TARGET=$(echo "${MAKE_TARGET}" | sed "s|\$(PWD)|$PWD|")

make ${MAKE_TARGET} -j${MAKE_JOBS:-3} $(cat ${WORKSPACE}/tf-a-ci-scripts/tf_config/$1) DEBUG=${DEBUG}
