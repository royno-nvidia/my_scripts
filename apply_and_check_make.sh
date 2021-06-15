#!/bin/bash -x
PATCHES_DIR=$1
ALL_PATCHES=$(ls $PATCHES_DIR)

for patch in $ALL_PATCHES;
do
	echo "Work on: $patch"
	git am --reject $PATCHES_DIR/$patch
	if [ $? -ne 0 ]; then
		echo
		echo "----------------------------------------------------------------------"
		echo "Failed to apply: '$patch'"
		echo "Please resolve"
		echo "When resolve use 'git add -u ; git am --continue ; rm -rf $PATCHES_DIR/$patch' "
		echo "----------------------------------------------------------------------"
		exit 1
	fi
	rm -rf $PATCHES_DIR/$patch
	make -j20
	if [ $? -ne 0 ]; then
		echo
		echo "----------------------------------------------------------------------"
		echo "Make Failed at patch: '$patch'"
		echo "Please resolve"
		echo "When resolve use 'git add -u ; git commit --amend' and run script again"
		echo "----------------------------------------------------------------------"
		exit 1
	fi
done
exit 0
