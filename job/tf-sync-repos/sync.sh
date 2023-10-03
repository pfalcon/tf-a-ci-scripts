#!/usr/bin/env bash
#
# Copyright (c) 2019-2020 Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

# Push the updated master from local to the selected remote
#
# $1 = git remote human readable name
# $2 = git remote URL
sync_repo()
{
	local result

	echo Pushing to "$1"...
	git push --tags $2 master
	result=$?
	if [ $result != 0 ]
	then
		echo Pushing to $1 FAILED!
	else
		echo Pushing to $1 SUCCEEDED!
	fi
	return $result
}

# Clone the selected repo, including submodules, if applicable, from tf.org
#
# Some variables utilised inside this function come from utils.sh
#
# $1 = repo to clone
# $2 = additional parameters passed to clone command
clone_repo()
{
	local repo_url
	local repo_name

	case $1 in
		trusted-firmware-a)
			repo_url=$tf_src_repo_url
			repo_name="TF-A"
			;;
		tf-a-tests)
			repo_url=$tftf_src_repo_url
			repo_name="TF-A-Tests"
			;;
		tf-a-ci-scripts)
			repo_url=$ci_src_repo_url
			repo_name="TF-A-CI-Scripts"
			;;
		hafnium)
			repo_url=$spm_src_repo_url
			repo_name="hafnium"
			;;
		*)
			echo "ERROR: Unknown repo to be cloned. sync.sh failed!"
			exit 1
			;;
	esac

	case $2 in
		--recurse-submodules)
			;;
		*)
			echo "ERROR: Unknown parameter passed to clone command. sync.sh failed!"
			exit 1
			;;
	esac

	# Remove old tree if it exists
	if [ -d $1 ]; then
		rm -rf "$1"
	fi

	# Fresh clone
	echo Cloning $repo_name from trustedfirmware.org...
	git clone $2 $repo_url
}

# Pull changes from tf.org to the local repo
#
# $1 = repo to update. It must be the same with the directory name
pull_changes()
{
	cd $1
	echo Pulling $1 from trustedfirmware.org...
	git remote update --prune
	git checkout master
	git merge --ff-only origin/master
	cd - > /dev/null
}

# exit if anything fails
set -e

# Source this file to get TF-A and TF-A-Tests repo URLs
source "$CI_ROOT/utils.sh"

clone_repo trusted-firmware-a
clone_repo tf-a-tests
clone_repo tf-a-ci-scripts
clone_repo hafnium --recurse-submodules

pull_changes trusted-firmware-a
pull_changes tf-a-tests
pull_changes tf-a-ci-scripts
pull_changes hafnium/project/reference
pull_changes hafnium/prebuilts
pull_changes hafnium/driver/linux
pull_changes hafnium

# stop exiting automatically
set +e

# Update TF-A remotes
cd trusted-firmware-a
sync_repo GitHub https://$GH_USER:$GH_PASSWORD@github.com/ARM-software/arm-trusted-firmware.git
github=$?
sync_repo "internal TF-A Gerrit" $tf_arm_gerrit_repo
tfa_gerrit=$?

# Update TF-A-Tests
cd ../tf-a-tests
sync_repo "internal TF-A-Tests Gerrit" $tftf_arm_gerrit_repo
tftf_gerrit=$?

# Update TF-A-CI-Scripts
cd ../tf-a-ci-scripts
sync_repo "internal TF-A-CI-Scripts Gerrit" $ci_arm_gerrit_repo
ci_gerrit=$?

# Update project/reference submodule of Hafnium
cd ../hafnium/project/reference
sync_repo "internal Hafnium project/reference Gerrit" $spm_proj_ref_arm_gerrit_repo
spm_proj_ref_gerrit=$?

# Update prebuilts submodule of Hafnium
cd ../../prebuilts
sync_repo "internal Hafnium prebuilts Gerrit" $spm_prebuilts_arm_gerrit_repo
spm_prebuilts_gerrit=$?

# Update driver/linux submodule of Hafnium
cd ../driver/linux
sync_repo "internal Hafnium driver/linux Gerrit" $spm_driver_linux_arm_gerrit_repo
spm_driver_linux_gerrit=$?

# Update Hafnium
cd ../../
sync_repo "internal Hafnium Gerrit" $spm_arm_gerrit_repo
spm_gerrit=$?

if [ $github != 0 -o $tfa_gerrit != 0 -o $tftf_gerrit != 0 -o $ci_gerrit != 0 -o $spm_gerrit != 0 ] ||
   [ $spm_proj_ref_gerrit != 0 -o $spm_prebuilts_gerrit != 0 -o $spm_driver_linux_gerrit != 0 ];
then
	exit 1
fi
