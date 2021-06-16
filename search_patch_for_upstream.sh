#!/bin/bash
SLOG="/var/tmp/slog.txt"
OUTPUTFILE="/var/tmp/wait_upstream_table.csv"
CWD=$PWD
UPSTREAM_DIR=$1
if [ -z "$UPSTREAM_DIR" ]; then
	echo "-E- Missing upstream/linux project path, Aborting.."
	exit 1
fi
echo "current dir: $CWD"
git log --oneline --color=never --pretty=format:%s > $SLOG

cd $UPSTREAM_DIR
echo "Get all patches info from $PWD"
BRANCHES=("for-upstream" "rdma-next-mlx" "rdma-rc-mlx" "net-next-mlx5" "net-mlx5")
#BRANCHES=("for-upstream")
echo "sep=;">$OUTPUTFILE
echo "Subject;Branch;SHA" >> $OUTPUTFILE
git fetch
for branch in ${BRANCHES[@]};
do
	git checkout $branch
	git rebase origin/$branch
	while IFS= read -r line
	do
		LOG=""
		LOG=$(git log --oneline --color=never | grep "$line")
		if [ ! -z "$LOG" ]; then
			SHA=$(echo "$LOG" | cut -d" " -f1)
			echo "$line; $branch; $SHA"
			echo "$line; $branch; $SHA" >> $OUTPUTFILE
		fi
	done < $SLOG
done
rm -rf $SLOG
#for branch in ${BRANCHES[@]};
#do
#	FILE="/tmp/${branch}.txt"
#	git checkout $branch
#	git rebase origin/$branch
#	echo $(git log --oneline --color=never --pretty=format:%s) > $FILE
#	echo "Created $FILE"
#done
#cd $CWD
#echo "Moved back to $CWD"
########while IFS= read -r line
########do
########	for branch in ${BRANCHES[@]};
########	do
########		FILE="/tmp/${branch}.txt"
########		if (echo $line | grep -q $FILE); then
########			SHA=$(echo $line | grep -q $FILE | cut -d" " -f1)
########			echo "$line; $branch; $SHA"
########			break
########		fi
########	done
########done < $SLOG

#clean tmp files
#for branch in ${BRANCHES[@]};
#do
#	rm -rf ${branch}.txt
#done
echo
echo "Script finished"
echo "----------------------------------"
echo "see results in '${OUTPUTFILE}'"
echo "----------------------------------"
exit 0
