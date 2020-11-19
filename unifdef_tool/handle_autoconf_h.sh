#!/bin/bash

OLD_AUTOCONF=$1
AUTOCONF_PATH=/tmp/autoconf.h
SPLIT_LINE="#else"
WORK_FILE="autoconf01"
FINAL=/tmp/final_autoconf.h
echo "splitting file.."
if [ ! -f $OLD_AUTOCONF ]; then
	echo "-E- File entered not exist"
	exit 1
fi
if !(grep -q "$SPLIT_LINE" $OLD_AUTOCONF); then
	echo "-E- Could not found where to split, Aborting.."
	echo "current split at '${SPLIT_LINE}' pattern"
	exit 1
fi

csplit -q --suppress-matched $OLD_AUTOCONF "/${SPLIT_LINE}/" -f autoconf
mv -f $WORK_FILE $AUTOCONF_PATH
if [ $? -ne 0 ]; then
	echo "-E- command 'mv -f $WORK_FILE $AUTOCONF_PATH' failed"
fi
sed -i '/else/d' $AUTOCONF_PATH
sed -i '/endif/d' $AUTOCONF_PATH
sed -i '/^ *$/d' $AUTOCONF_PATH
echo "" > $FINAL
for def in $(grep "CONFIG_" $AUTOCONF_PATH | cut -d" " -f2 | sort | uniq)
do
	if (grep -wq "define $def" $AUTOCONF_PATH);then
		echo "#define $def 1" >> $FINAL 	
	else
		echo "#undef $def " >> $FINAL 	
	fi
done

rm -rf autoconf0{0..1}
rm -rf $AUTOCONF_PATH

echo "create '$FINAL'"
