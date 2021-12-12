#!/bin/bash

echo "Update history"
SRPM_PATH="$1"
GIT_REV="$2"
TEMP_DIR="/tmp/update_history"
GIT_DIR="/var/tmp/royno_OFED_5_5/mlnx-ofa_kernel-4.0"

rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cp "$SRPM_PATH" "$TEMP_DIR"
cd "$TEMP_DIR"
rpm2cpio mlnx-ofa_kernel-*.src.rpm | cpio -id
tar -xzf mlnx-ofa_kernel-*.tgz
cd $(ls --color=never | grep -E "mlnx-ofa_kernel.*[0-9]\.[0-9]" | head -1) #Need better cd
ofed_scripts/ofed_patch.sh
rm -rf backports/
cp -r ./ "$GIT_DIR"
cd "$GIT_DIR"
git add -u
git commit -s -m "UPDATE HISTORY"
