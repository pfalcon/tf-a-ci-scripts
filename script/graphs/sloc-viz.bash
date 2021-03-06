#
# Copyright (c) 2021 Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
#!/usr/bin/env bash
set -euo pipefail

# Overview
# ========
#
# This script generates source lines of code as a tab separated values (TSV)
# file and a stacked bar chart. It uses `tokei` for gathering the data, and
# `gnuplot` for generating the plot. The data is available on stderr and the
# plot will be put in stdout.
#
# This script generates information about the directory that it's run in,
# aggregated by subdirectory.
# It is recommended that you run it from within the TF-A root directory for
# best results.

# Variables
# =========

# convert newlines to tabs
n2t="tr \n \t"

# We will build the final data file incrementally throughout the script. We need
# A place to store this data, temporarily, so mktemp fills the role.
data=$(mktemp XXXXXX-sloc.tsv)

# Top level TF-A directories that we consider by themselves.
toplevel=$(find -mindepth 1 -maxdepth 1 -type d -and ! -name ".*" | sed "s|./||g")

# Second level TF-A directories that we consider separately.
secondlevel=$(find drivers plat -mindepth 1 -maxdepth 1 -type d || true)

# We want to be sure that we always put the data in the same order, with the
# same keys in the resulting TSV file. To ensure this, we keep a json-encoded
# array of the categories we would like to show in the graph.
# This was generated by taking the output of `tokei --output json | jq keys`
# and trimming out things that we don't really need like "Svg"
categories='["AssemblyGAS", "C", "CHeader", "DeviceTree", "Makefile", "Python", "ReStructuredText"]'

# Data File Generation
# ====================
#
# Below we generate the data file used for the graph. The table is a
# tab separated value(TSV) matrix with columns of code language (Bash, C, etc),
# and rows of subdirectories of TF-A that contain the code.

# Column headers
# --------------
(echo module; echo $categories | jq ".[]" ) | $n2t  > $data
# add a newline
echo >> $data

# Build Each Row
# --------------
for dir in $toplevel $secondlevel; do
	# Gnuplot likes to treat underscores as a syntax for subscripts. This
	# looks weird, as module names are not named with this syntax in mind.
	# Further, it turns out that we go through 3 expansions, so we need 8 (2^3)
	# backslashes.
	echo $dir | sed -e "s/_/\\\\\\\\_/g" | $n2t >> $data
	# This is the heart of the implementation, and probably the most
	# complicated line in this script. First, we generate the subdirectory
	# sloc with tokei, in json format. We then filter it with jq. The jq
	# filter iterates over the column names as saved in the categories
	# variable. Each iteration through the loop, we print out the code
	# value, when it exists, or null + 0. This takes advantage of the
	# property of null:
	#  > null can be added to any value, and returns the other value
	#  > unchanged.
	tokei --output json $dir \
	        | jq " .[$categories[]].code + 0" \
		| $n2t >> $data
	echo  >> $data
done

cat $data 1>&2
gnuplot -c ${0%bash}plot $data

rm $data
