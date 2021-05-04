#!/bin/bash
# Author: Roy Novich <royno@nvidia.com>
# USAGE: ./ofed_base_code_version.sh <mlnx_ofa dir> <OFED version: major_minor>

SRC_DIR=$1
OFED_VER=$2
CHECKOUT_BRANCH="mlnx_ofed_${OFED_VER}"
cd $SRC_DIR
CUR_BRANCH=$(git rev-parse --abbrev-ref HEAD)
git checkout --quiet "origin/${CHECKOUT_BRANCH}"
BASE_VER=$(git log --oneline | grep -i "set base code" | grep -oE "v[0-9]\.[0-9]+.*")
echo
echo "$CHECKOUT_BRANCH base code: $BASE_VER"
git checkout --quiet "$CUR_BRANCH"
