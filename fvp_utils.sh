#!/usr/bin/env bash
#
# Copyright (c) 2019-2020, Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

set -u

bl1_addr="${bl1_addr:-0x0}"
bl31_addr="${bl31_addr:-0x04001000}"
bl32_addr="${bl32_addr:-0x04003000}"
bl33_addr="${bl33_addr:-0x88000000}"
dtb_addr="${dtb_addr:-0x82000000}"
fip_addr="${fip_addr:-0x08000000}"
initrd_addr="${initrd_addr:-0x84000000}"
kernel_addr="${kernel_addr:-0x80080000}"
el3_payload_addr="${el3_payload_addr:-0x80000000}"

# SPM requires following addresses for RESET_TO_BL31 case
spm_addr="${spm_addr:-0x6000000}"
spmc_manifest_addr="${spmc_addr:-0x0403f000}"
sp1_addr="${sp1_addr:-0x7000000}"
sp2_addr="${sp2_addr:-0x7100000}"
sp3_addr="${sp3_addr:-0x7200000}"

ns_bl1u_addr="${ns_bl1u_addr:-0x0beb8000}"
fwu_fip_addr="${fwu_fip_addr:-0x08400000}"
backup_fip_addr="${backup_fip_addr:-0x09000000}"
romlib_addr="${romlib_addr:-0x03ff2000}"

uboot32_fip_url="$linaro_release/fvp32-latest-busybox-uboot/fip.bin"

rootfs_url="$linaro_release/lt-vexpress64-openembedded_minimal-armv8-gcc-4.9_20150912-729.img.gz"

# FVP Kernel URLs
declare -A fvp_kernels
fvp_kernels=(
[fvp-aarch32-zimage]="$linaro_release/fvp32-latest-busybox-uboot/Image"
[fvp-busybox-uboot]="$linaro_release/fvp-latest-busybox-uboot/Image"
[fvp-oe-uboot32]="$linaro_release/fvp32-latest-oe-uboot/Image"
[fvp-oe-uboot]="$linaro_release/fvp-latest-oe-uboot/Image"
[fvp-quad-busybox-uboot]="$tfa_downloads/quad_cluster/Image"
)

# FVP initrd URLs
declare -A fvp_initrd_urls
fvp_initrd_urls=(
[aarch32-ramdisk]="$linaro_release/fvp32-latest-busybox-uboot/ramdisk.img"
[dummy-ramdisk]="$linaro_release/fvp-latest-oe-uboot/ramdisk.img"
[dummy-ramdisk32]="$linaro_release/fvp32-latest-oe-uboot/ramdisk.img"
[default]="$linaro_release/fvp-latest-busybox-uboot/ramdisk.img"
)

get_optee_bin() {
	url="$jenkins_url/job/tf-optee-build/PLATFORM_FLAVOR=fvp,label=arch-dev/lastSuccessfulBuild/artifact/artefacts/tee.bin" \
               saveas="bl32.bin" fetch_file
	archive_file "bl32.bin"
}

# For Measured Boot tests using a TA based on OPTEE, it is necessary to use a
# specific build rather than the default one generated by Jenkins.
get_ftpm_optee_bin() {
	url="${nfs_volume}/pdsw/downloads/tf-a/ftpm/optee/tee-header_v2.bin" \
		saveas="bl32.bin" fetch_file
	archive_file "bl32.bin"

	url="${nfs_volume}/pdsw/downloads/tf-a/ftpm/optee/tee-pager_v2.bin" \
		saveas="bl32_extra1.bin" fetch_file
	archive_file "bl32_extra1.bin"

	url="${nfs_volume}/pdsw/downloads/tf-a/ftpm/optee/tee-pageable_v2.bin" \
		saveas="bl32_extra2.bin" fetch_file
	archive_file "bl32_extra2.bin"
}

get_uboot32_bin() {
	local tmpdir="$(mktempdir)"

	pushd "$tmpdir"
	extract_fip "$uboot32_fip_url"
	mv "nt-fw.bin" "uboot.bin"
	archive_file "uboot.bin"
	popd
}

get_uboot_bin() {
	local uboot_url="$linaro_release/fvp-latest-busybox-uboot/bl33-uboot.bin"

	url="$uboot_url" saveas="uboot.bin" fetch_file
	archive_file "uboot.bin"
}

get_uefi_bin() {
	uefi_downloads="${uefi_downloads:-http://files.oss.arm.com/downloads/uefi}"
	uefi_ci_bin_url="${uefi_ci_bin_url:-$uefi_downloads/Artifacts/Linux/github/fvp/static/DEBUG_GCC5/FVP_AARCH64_EFI.fd}"

	url=$uefi_ci_bin_url saveas="uefi.bin" fetch_file
	archive_file "uefi.bin"
}

get_kernel() {
	local kernel_type="${kernel_type:?}"
	local url="${fvp_kernels[$kernel_type]}"

	url="${url:?}" saveas="kernel.bin" fetch_file
	archive_file "kernel.bin"
}

get_initrd() {
	local initrd_type="${initrd_type:?}"
	local url="${fvp_initrd_urls[$initrd_type]}"

	url="${url:?}" saveas="initrd.bin" fetch_file
	archive_file "initrd.bin"
}

get_dtb() {
	local dtb_type="${dtb_type:?}"
	local dtb_url
	local dtb_saveas="$workspace/dtb.bin"
	local cc="$(get_tf_opt CROSS_COMPILE)"
	local pp_flags="-P -nostdinc -undef -x assembler-with-cpp"

	case "$dtb_type" in
		"fvp-base-quad-cluster-gicv3-psci")
			# Get the quad-cluster FDT from pdsw area
			dtb_url="$tfa_downloads/quad_cluster/fvp-base-quad-cluster-gicv3-psci.dtb"
			url="$dtb_url" saveas="$dtb_saveas" fetch_file
			;;
		"sgm775")
			# Get the SGM775 FDT from pdsw area
			dtb_url="$sgm_prebuilts/sgm775.dtb"
			url="$dtb_url" saveas="$dtb_saveas" fetch_file
			;;
		*)
			# Preprocess DTS file
			${cc}gcc -E ${pp_flags} -I"$tf_root/fdts" -I"$tf_root/include" \
				-o "$workspace/${dtb_type}.pre.dts" \
				"$tf_root/fdts/${dtb_type}.dts"
			# Generate DTB file from DTS
			dtc -I dts -O dtb \
				"$workspace/${dtb_type}.pre.dts" -o "$dtb_saveas"
	esac

	archive_file "$dtb_saveas"
}

get_rootfs() {
	local tmpdir
	local fs_base="$(echo $(basename $rootfs_url) | sed 's/\.gz$//')"
	local cached="$project_filer/ci-files/$fs_base"

	if upon "$jenkins_run" && [ -f "$cached" ]; then
		# Job workspace is limited in size, and the root file system is
		# quite large. This means, parallel runs of root file system
		# tests could fail. So, for Jenkins runs, copy and use the root
		# file system image from the $CI_SCRATCH location
		local private="$CI_SCRATCH/$JOB_NAME-$BUILD_NUMBER"
		mkdir -p "$private"
		rm -f "$private/rootfs.bin"
		url="$cached" saveas="$private/rootfs.bin" fetch_file
		ln -s "$private/rootfs.bin" "$archive/rootfs.bin"
		return
	fi

	tmpdir="$(mktempdir)"
	pushd "$tmpdir"
	url="$rootfs_url" saveas="rootfs.bin" fetch_file

	# Possibly, the filesystem image we just downloaded is compressed.
	# Decompress it if required.
	if file "rootfs.bin" | grep -iq 'gzip compressed data'; then
		echo "Decompressing root file system image rootfs.bin ..."
		gunzip --stdout "rootfs.bin" > uncompressed_fs.bin
		mv uncompressed_fs.bin "rootfs.bin"
	fi

	archive_file "rootfs.bin"
	popd
}

fvp_romlib_jmptbl_backup="$(mktempdir)/jmptbl.i"

fvp_romlib_runtime() {
	local tmpdir="$(mktempdir)"

	# Save BL1 and romlib binaries from original build
	mv "${tf_build_root:?}/${plat:?}/${mode:?}/romlib/romlib.bin" "$tmpdir/romlib.bin"
	mv "${tf_build_root:?}/${plat:?}/${mode:?}/bl1.bin" "$tmpdir/bl1.bin"

	# Patch index file
	cp "${tf_root:?}/plat/arm/board/fvp/jmptbl.i" "$fvp_romlib_jmptbl_backup"
	sed -i '/fdt/ s/.$/&\ patch/' ${tf_root:?}/plat/arm/board/fvp/jmptbl.i

	# Rebuild with patched file
	echo "Building patched romlib:"
	build_tf

	# Retrieve original BL1 and romlib binaries
	mv "$tmpdir/romlib.bin" "${tf_build_root:?}/${plat:?}/${mode:?}/romlib/romlib.bin"
	mv "$tmpdir/bl1.bin" "${tf_build_root:?}/${plat:?}/${mode:?}/bl1.bin"
}

fvp_romlib_cleanup() {
	# Restore original index
	mv "$fvp_romlib_jmptbl_backup" "${tf_root:?}/plat/arm/board/fvp/jmptbl.i"
}


fvp_gen_bin_url() {
    local bin_mode="${bin_mode:?}"
    local bin="${1:?}"

    if upon "$jenkins_run"; then
        echo "$jenkins_url/job/$JOB_NAME/$BUILD_NUMBER/artifact/artefacts/$bin_mode/$bin"
    else
        echo "file://$workspace/artefacts/$bin_mode/$bin"
    fi
}

gen_fvp_yaml_template() {
    local yaml_template_file="$workspace/fvp_template.yaml"

    # must parameters for yaml generation
    local payload_type="${payload_type:?}"

    "$ci_root/script/gen_fvp_${payload_type}_yaml.sh" > "$yaml_template_file"

    archive_file "$yaml_template_file"
}

gen_fvp_yaml() {
    local yaml_template_file="$workspace/fvp_template.yaml"
    local yaml_file="$workspace/fvp.yaml"

    # must parameters for yaml generation
    local model="${model:?}"
    local dtb="${dtb:?}"
    local container_name="${container_name:?}"
    local container_model_params="${container_model_params:?}"
    local container_entrypoint="${container_entrypoint:?}"
    local archive="${archive:?}"

    # general artefacts
    bl1="$(fvp_gen_bin_url bl1.bin)"
    fip="$(fvp_gen_bin_url fip.bin)"

    # linux artefacts
    dtb="$(fvp_gen_bin_url $dtb)"
    image="$(fvp_gen_bin_url kernel.bin)"
    ramdisk="$(fvp_gen_bin_url initrd.bin)"

    # tftf's ns_bl[1|2]u.bin artefacts
    ns_bl1u="$(fvp_gen_bin_url ns_bl1u.bin)"
    ns_bl2u="$(fvp_gen_bin_url ns_bl2u.bin)"

    docker_registry="${docker_registry:-}"
    docker_registry="$(docker_registry_append)"

    docker_name="${docker_registry}$container_name"

    version_string="\"ARM ${model}"' [^\\n]+'"\""

    sed -e "s|\${ACTIONS_DEPLOY_IMAGES_BL1}|${bl1}|" \
        -e "s|\${ACTIONS_DEPLOY_IMAGES_FIP}|${fip}|" \
        -e "s|\${ACTIONS_DEPLOY_IMAGES_DTB}|${dtb}|" \
        -e "s|\${ACTIONS_DEPLOY_IMAGES_IMAGE}|${image}|" \
        -e "s|\${ACTIONS_DEPLOY_IMAGES_RAMDISK}|${ramdisk}|" \
        -e "s|\${ACTIONS_DEPLOY_IMAGES_NS_BL1U}|${ns_bl1u}|" \
        -e "s|\${ACTIONS_DEPLOY_IMAGES_NS_BL2U}|${ns_bl2u}|" \
        -e "s|\${BOOT_DOCKER_NAME}|${docker_name}|" \
        -e "s|\${BOOT_IMAGE}|${container_entrypoint}|" \
        -e "s|\${BOOT_VERSION_STRING}|${version_string}|" \
        < "$yaml_template_file" \
        > "$yaml_file"

    # include the model parameters
    while read -r line; do
        if [ -n "$line" ]; then
	    yaml_line="- \"${line}\""
            sed -i -e "/\${BOOT_ARGUMENTS}/i \ \ \ \ $yaml_line" "$yaml_file"
        fi
    done < "$archive/model_params"
    sed -i -e '/\${BOOT_ARGUMENTS}/d' "$yaml_file"

    archive_file "$yaml_file"
}

docker_registry_append() {
    # if docker_registry is empty, just use local docker registry
    [ -z "$docker_registry" ] && return

    local last=-1
    local last_char="${docker_registry:last}"

    if [ "$last_char" != '/' ]; then
        docker_registry="${docker_registry}/";
    fi
    echo "$docker_registry"
}

set +u
