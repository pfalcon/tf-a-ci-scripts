#!/usr/bin/env bash
#
# Copyright (c) 2019-2023 Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

set -e

if [ -d artefacts ]; then
	# Remove everything except logs and scan-build artefacts such as
	# .html, .js and .css files useful for offline debug of static
	# analysis defects. The .elf, .bin and .dump are needed for code
	# coverage
	find artefacts -type f -not \( -name "*.log" -o -name "*.html" -o -name "*.js" -o -name "*.css" -o -name "*.elf" -o -name "*.bin"  -o -name "*.dump" \) -exec rm -f {} +
fi
