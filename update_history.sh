#!/bin/bash

SCRIPT_NAME="$(basename $0)"
GIT_REV=""
TEMP_DIR="/tmp/update_history"
BASE_DIR=""
BACK_DIR=""
CLEANUP=0
DEBUG=0
new_cmsg=""
author=""

build_new_commit()
{
	old_cmsg="$1"
	author=$(echo "$a" | grep -oP "Author:.*>" | sed -r 's/Author: //')
	new_cmsg=$(echo -e "$old_cmsg" | sed -r -e '/(commit|Author|Date)/d' \
			-e 's/^[[:space:]]*//;s/[[:space:]]*$//')
}

while [ ! -z "$1" ]
do
	case "$1" in
		--srpm)
		echo "HERE2"
		SRPM_PATH="$2"
		shift
		;;
		--base-branch)
		BASE_DIR="$2"
		shift
		;;
		--backport-branch)
		BACK_DIR="$2"
		shift
		;;
		--cleanup)
		CLEANUP=1
		shift
		;;
		--debug)
		DEBUG=1
		shift
		;;
		-h | --help)
		echo "Usage: ${SCRIPT_NAME} [options]
		NEED DESCRIPTION!!
"
		exit 1
		;;
		*)
		echo "-E- Unsupported option: $1" >&2
		echo "use -h flag to display help menu"
		exit 1
		;;
	esac
	shift
done
if [ "$CLEANUP" -eq 1 ]; then
	cd "$BASE_DIR"
	./ofed_scripts/cleanup
	cd "$BACK_DIR"
	git checkout poc_5_6_history
	git branch -D copy_on_top
	exit 1
fi
if [ "$DEBUG" -eq 1 ]; then
	echo "base = $BASE_DIR
	backport = $BACK_DIR"
fi
cd "$BASE_DIR"
cmsg_head=$(git log --color=never -1)
cur_branch=$(git rev-parse --abbrev-ref HEAD)
merge_ancestor="$(git rev-list poc_5_6 ^origin/poc_5_6 | tail -1)^"
cmsg_merge="$(git log --color=never -1 $merge_ancestor)"
search_id=$(echo $cmsg_merge | grep -oE 'I[0-9a-f]{40}')
if [ "$DEBUG" -eq 1 ]; then
	echo "inside $(pwd)"
	echo
	echo "saving HEAD commit:"
	echo  "cmsg_head=
	$cmsg_head"
	echo "cur_branch= $cur_branch"
	echo  "cmsg_merge=
	$cmsg_merge"
	echo "search_id= |$search_id|"
fi
if [ ! -f backports_applied ];then
	"$BASE_DIR"/ofed_scripts/ofed_patch.sh >/dev/null 2>&1  # Apply patches to ready for copy
	# this place need to check if ofed_patch failed!
fi
if [ "$DEBUG" -eq 1 ]; then
	echo "------------------STAGE 1 finished--------------------------"
	echo "inside $(pwd)"
fi
cd "$BACK_DIR"
for sha in $(git log --pretty="%h") #search for similar change-id
do
	cur_cmsg="$(git log -1 $sha)"
	cur_id="$(echo "$cur_cmsg" | grep -oE 'I[0-9a-f]{40}')"
	if [ "$cur_id" = "$search_id" ];then
		if [ "$DEBUG" -eq 1 ]; then
			echo "------------------------------------------------"
			echo "$cur_id"
			echo "similar!! at commit:
			$cur_cmsg"
			echo "------------------------------------------------"
		fi
		FOUND=1
		break
	fi
done
if [ "$FOUND" -ne 1 ];then
	# What happen if fail?
	echo "Failed to found aligned commit"
fi
push_branch=$(git rev-parse --abbrev-ref HEAD)
git checkout $sha -b copy_on_top # checkout to aligned commit to get actual diff
dir_owner=$(stat -c "%U" "$BACK_DIR")
# Need to install rsync before script run
rsync -a --exclude=.git --exclude=backports "$BASE_DIR/" "$BACK_DIR" # copy base applied over backports history
build_new_commit "$cmsg_head"
topic="Automatic_backports_history"
git add -u; git commit --no-verify -m "$new_cmsg" #miss sign-off
git commit --amend --author="$author" --no-edit
push_output=$(git push origin HEAD:refs/for/"$push_branch"/"$topic" 2>&1)
commit_link="$(echo $push_output | grep -oP "http.*\/[0-9]+")"
if [ "$DEBUG" -eq 1 ]; then
	echo "Create new commit"
	echo "new_cmsg= $new_cmsg"
fi
echo "@@ commit_link= $commit_link @@" # '@@ <String> @@' means <String> will be dump to user from job
exit 0
#=========================END============================#
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
