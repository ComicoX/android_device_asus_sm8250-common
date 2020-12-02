#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
#           (C) 2018 The Omnirom Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi

HAVOC_ROOT="$MY_DIR"/../../..

HELPER="${HAVOC_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "$HELPER" ]; then
    echo "Unable to find helper script at $HELPER"
    exit 1
fi
. "$HELPER"

if [ $# -eq 0 ]; then
    SRC=adb
else
    if [ $# -eq 1 ]; then
        SRC=$1
    else
        echo "$0: bad number of arguments"
        echo ""
        echo "usage: $0 [PATH_TO_EXPANDED_ROM]"
        echo ""
        echo "If PATH_TO_EXPANDED_ROM is not specified, blobs will be extracted from"
        echo "the device using adb pull."
        exit 1
    fi
fi

# Initialize the helper for common device
setup_vendor "$DEVICE_COMMON" "$VENDOR" "$HAVOC_ROOT" true

extract "$MY_DIR"/proprietary-files-product.txt "$SRC"
extract "$MY_DIR"/proprietary-files.txt "$SRC"

# Reinitialize the helper for device
source "${MY_DIR}/../${DEVICE}/extract-files.sh"
setup_vendor "${DEVICE}" "${VENDOR}" "${HAVOC_ROOT}" false "${CLEAN_VENDOR}"
for BLOB_LIST in "${MY_DIR}"/../"${DEVICE}"/proprietary-files*.txt; do
    extract "${BLOB_LIST}" "${SRC}" \
            "${KANG}" --section "${SECTION}"
done

COMMON_BLOB_ROOT="${HAVOC_ROOT}/vendor/${VENDOR}/${DEVICE_COMMON}/proprietary"

sed -i 's/<library name="android.hidl.manager-V1.0-java"/<library name="android.hidl.manager@1.0-java"/g' \
        "${COMMON_BLOB_ROOT}/etc/permissions/qti_libpermissions.xml"

"$MY_DIR"/setup-makefiles.sh
