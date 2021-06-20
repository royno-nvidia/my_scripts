#!/bin/bash
CWD=$PWD
OLD_OFED_DIR=$1
FORMAT_ALL='':
OLD_P_DIR="/tmp/old_patches"
NEW_P_DIR="/tmp/new_patches"
REVIEW=0
PLUS=0
MISSING=0
RC=0
OUTPUTFILE="need_review_patches.csv"
#i=0

cd $OLD_OFED_DIR
echo "Format patch old ofed from $PWD"
git format-patch --root -o $OLD_P_DIR
cd $CWD
echo "Format patch new ofed from $PWD"
git format-patch --root -o $NEW_P_DIR

echo "sep=;">$OUTPUTFILE
echo "Subject; Feature; Status; Note;" >>$OUTPUTFILE

for patch in $(ls $NEW_P_DIR);
do
	#let i++
	#if [ $i -eq 200 ]; then
	#	break
	#fi
	echo "--------------------------------------------------------------------------------------------------"
	echo "Work on: $patch"
	sub=$(cat $NEW_P_DIR/$patch | grep -w "Subject" | grep -oE "[0-9]\].*" | grep -oE "[a-zA-Z].*" | head -1)
	feature=$(git grep "$sub" | grep -oE "feature=.*" | cut -d";" -f1 | sed 's/feature=//' | head -1)
	echo "subject = $sub"
	echo "feature = $feature"
	patch_name=${patch:5}
	old_patch_name=""
	old_patch_name=$(ls $OLD_P_DIR | grep -w "$patch_name" | head -1)
	if [ ! -z "$old_patch_name" ]; then
		let HAVE++
		# compare patches
		if (diff -uBZ $OLD_P_DIR/$old_patch_name $NEW_P_DIR/$patch | grep -vE -- "^(\-\-\-|\+\+\+) backports|insertions|\+\+$|\-\-$" | grep -E -- "^(\-|\+)" | grep -vE -- "^(\-|\+)@@|files changed" | grep -vE -- "\| [0-9]+ [+|-]+$" | grep -qvE "index|Subject|From|Change-Id|metadata\/|[0-9]{4}-[0-9]{2}-[0-9]{2}"); then
			echo "$sub; $feature; Review; ;" >> $OUTPUTFILE
			echo "-E- need review '$sub'"
			let REVIEW++
		else
			echo "$sub; $feature; Approved; ;" >> $OUTPUTFILE
			echo "-I- Approved '$sub'"
			let PLUS++
		fi
		
	else
		echo "$sub; $feature; New; ;" >> $OUTPUTFILE
		let MISSING++
		echo "-E- New '$sub'"
	fi
	echo "--------------------------------------------------------------------------------------------------"
done
echo 
echo "Overall patches need review: $REVIEW"
echo "Overall +1 patches: $PLUS"
echo "Overall new patches: $MISSING"
echo "----------------------------"
echo "See full results in '$OUTPUTFILE'"
echo "----------------------------"
RC=$((MISSING + REVIEW))
exit $RC
