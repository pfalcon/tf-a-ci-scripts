#!/bin/bash
#
# Copyright (c) 2021-2022 BUGSENG srl. All rights reserved.
# Copyright (c) 2022 Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
# Common code to setup analysis environment.

# Automatically export vars
set -a
source ${WORKSPACE}/tf-a-ci-scripts/tf_config/${TF_CONFIG}
set +a

if [ "${TRUSTED_BOARD_BOOT}" = 1 -o "${MEASURED_BOOT}" = 1 ]; then
    # These configurations require mbedTLS component
    wget -q ${MBEDTLS_URL}
    tar xaf $(basename ${MBEDTLS_URL})
    rm $(basename ${MBEDTLS_URL})
    pwd; ls -l
    export MBEDTLS_DIR="${PWD}/$(ls -1d mbedtls-*)"
fi

which ${CROSS_COMPILE}gcc
${CROSS_COMPILE}gcc -v
