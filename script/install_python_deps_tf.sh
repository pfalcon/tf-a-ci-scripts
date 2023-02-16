#!/usr/bin/env bash

#
# Copyright (c) 2021-2023 Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

if [ $(python3 -c 'import sys; print(sys.version_info[1])') -lt 7 ]; then
    function python3() { python3.8 "${@}"; }
fi

python3 -m virtualenv .venv

source .venv/bin/activate

(
    export PIP_CACHE_DIR=${project_filer}/pip-cache

    python3 -m pip install --upgrade pip
    python3 -m pip install poetry==1.3.2 ||
            python3 -m pip install poetry==1.3.2 --no-cache-dir
)
