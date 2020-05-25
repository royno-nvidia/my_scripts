#!/bin/bash

NEVET_SET_LIST=$1; shift
ALLWAYS_SET_LIST=$1; shift
MLNX_OFA_DIR=$1; shift
OUTPUT_FILE="results.csv"
count_refs()
{
	local current_def=$1; shift
	count=$(grep -r ${current_def} ${MLNX_OFA_DIR}/backports ${MLNX_OFA_DIR}/include ${MLNX_OFA_DIR}/compat | grep -v ${current_def}_ | wc -l)
	echo ${count}
}


if [ "X$MLNX_OFA_DIR" == "X" ]; then
	echo "Must provide path to mlnx_ofa dir for statisics!" >&2
	exit 1
fi

echo "sep=;">$OUTPUT_FILE
echo "number; name; lines;" >>$OUTPUT_FILE

echo
echo "-------------------------------------------------------------"
echo "counting NEVER set instance" >>$OUTPUT_FILE
echo "-------------------------------------------------------------"
echo

overall=0
i=0
while read -r dd
do
	i=$(($i+1))
	thisTime=$(count_refs "${dd}")
	overall=$(($overall+${thisTime}))
	echo -e "$i:\t\t $dd\t\t\t\t\t\t\t ${thisTime}" >&2
	echo "$i;$dd;$thisTime">>$OUTPUT_FILE
done < $NEVET_SET_LIST

echo
echo "-------------------------------------------------------------"
echo "counting ALLWAYS set instance" >>$OUTPUT_FILE
echo "-------------------------------------------------------------"
echo

while read -r dd
do
	i=$(($i+1))
	thisTime=$(count_refs "${dd}")
	overall=$(($overall+${thisTime}))
	echo -e "$i:\t\t $dd\t\t\t\t\t\t\t ${thisTime}" >&2
	echo "$i;$dd;$thisTime">>$OUTPUT_FILE

done < $ALLWAYS_SET_LIST
echo "-----------------" >&2
echo "overall lines: ${overall}" >&2
echo "-----------------" >&2
