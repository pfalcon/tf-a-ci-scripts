#
# Copyright (c) 202-2023, Arm Limited. All rights reserved.
#
# SPDX-License-Identifier: BSD-3-Clause
#
# External aka 3rd-party sources included in a project.
# These are intended to be filtered from MISRA reports (as we don't have
# control over them, can't easily fix issues in them, and generally that's
# normally out of scope of the project).

-doc_begin="Treat LIBC as external, as they have many peculiar declarations leading to spurious warnings."
-file_tag+={external, "^include/lib/libc/.*$"}
-file_tag+={external, "^lib/libc/.*$"}
-doc_end

-file_tag+={external, "^lib/compiler-rt/.*$"}
-file_tag+={external, "^include/lib/libfdt/.*$"}
-file_tag+={external, "^lib/libfdt/.*$"}
