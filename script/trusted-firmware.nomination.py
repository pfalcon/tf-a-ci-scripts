#
# Copyright (c) 2019-2020, Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#

#
# Nomination map for Trusted Firmware.
#
# This file is EXECED from gen_nomination.py

nomination_rules = {
        # Run RDN1EDGE TF-A Tests and MISRA checks for any platform changes
        "path:plat/arm/board/rdn1edge":
            ["tf-l3-boot-tests-css/fvp-rdn1edge-tbb,fvp-rdn1edge-default:fvp-tftf-fip.tftf-rdn1edge",
             "tf-l2-coverity-misra-nominated/fvp-rdn1edge-tbb:coverity-tf-misra.diff",
             "tf-l3-boot-tests-css/fvp-rdn1edgex2-tbb:fvp-linux.sgi-fip.sgi-rdn1edgex2-debug",
             "tf-l2-coverity-misra-nominated/fvp-rdn1edgex2-tbb:coverity-tf-misra.diff"],

        # Run RD-Daniel TF-A Tests and MISRA checks for any platform changes
        "path:plat/arm/board/rddaniel":
            ["tf-l3-boot-tests-css/fvp-rddaniel-tbb:fvp-linux.sgi-fip.sgi-rddaniel-debug",
             "tf-l2-coverity-misra-nominated/fvp-rddaniel-tbb:coverity-tf-misra.diff"],

        # Run SGI575 boot test, TF-A Tests and MISRA checks for any changes with "sgi" in the path
        "pathre:sgi":
            ["tf-l3-boot-tests-css/fvp-sgi575-tbb:fvp-linux.sgi-fip.sgi-sgi575-debug",
             "tf-l3-boot-tests-css/fvp-sgi575-tbb,fvp-sgi575-default:fvp-tftf-fip.tftf-sgi575",
             "tf-l2-coverity-misra-nominated/fvp-sgi575-tbb:coverity-tf-misra.diff"],

        # Run SGM775 boot test and MISRA checks for any changes with "sgm" in the path
        "pathre:sgm":
            ["tf-l3-boot-tests-css/fvp-sgm775-tbb:fvp-linux.sgm-dtb.sgm775-fip.sgm-sgm775-debug",
             "tf-l2-coverity-misra-nominated/fvp-sgm775-tbb:coverity-tf-misra.diff"],

        # Run Coverity MISRA checks for tc0 platform changes
        "path:plat/arm/board/tc0":
            ["tf-l2-coverity-misra-nominated/fvp-tc0-tbb:coverity-tf-misra.diff"],

         # Run Coverity MISRA checks for n1sdp platform changes
        "path:plat/arm/board/n1sdp":
            ["tf-l2-coverity-misra-nominated/n1sdp-default:coverity-tf-misra.diff"],

        # Run Coverity MISRA checks for arm_fpga platform changes
        "path:plat/arm/board/arm_fpga":
            ["tf-l2-coverity-misra-nominated/arm_fpga-default:coverity-tf-misra.diff"],

        # Run Coverity MISRA checks for rde1edge platform changes
        "path:plat/arm/board/rde1edge":
            ["tf-l2-coverity-misra-nominated/fvp-rde1edge-tbb:coverity-tf-misra.diff"],

        # Run Coverity MISRA checks for fvp_ve platform changes
        "path:plat/arm/board/fvp_ve":
            ["tf-l2-coverity-misra-nominated/fvp_ve-a7:coverity-tf-misra.diff"],

        # Run Coverity MISRA checks for a5ds platform changes
        "path:plat/arm/board/a5ds":
            ["tf-l2-coverity-misra-nominated/a5ds:coverity-tf-misra.diff"],

        # Run Coverity MISRA checks for corstone700 platform changes
        "path:plat/arm/board/corstone700":
            ["tf-l2-coverity-misra-nominated/corstone700-fvp-default:coverity-tf-misra.diff",
             "tf-l2-coverity-misra-nominated/corstone700-fpga-default:coverity-tf-misra.diff"],

        # Run Coverity MISRA checks for SPM_MM changes
        "pathre:spm_mm":
            ["tf-l2-coverity-misra-nominated/fvp-spm-mm:coverity-tf-misra.diff"],

         # Run Coverity MISRA checks for Debugfs changes
         "pathre:debugfs":
            ["tf-l2-coverity-misra-nominated/fvp-debugfs:coverity-tf-misra.diff"],

        # Run Coverity MISRA checks for fconf changes
        "pathre:fconf":
            ["tf-l2-coverity-misra-nominated/fvp-aarch64-sdei-fconf:coverity-tf-misra.diff"],

        # Run Coverity MISRA checks for pauth changes
        "pathre:pauth":
            ["tf-l2-coverity-misra-nominated/fvp-pauth-standard:coverity-tf-misra.diff"],

        # Run Coverity MISRA checks for RAS extension changes
        ("path:lib/extensions/ras", "pathre:fvp_ras"):
            ["tf-l2-coverity-misra-nominated/fvp-ras-fault-inject:coverity-tf-misra.diff"],

        # Run SDEI boot test for SDEI, EHF, or RAS changes or mention
        ("pathre:sdei", "pathre:ehf", "pathre:ras", "has:SDEI_SUPPORT",
              "has:EL3_EXCEPTION_HANDLING"):
            ["tftf-l2-fvp/fvp-aarch64-sdei,fvp-default:fvp-tftf-fip.tftf-aemv8a-debug",
             "tf-l2-coverity-misra-nominated/fvp-aarch64-sdei:coverity-tf-misra.diff"],

        }
