#!/bin/bash

OLD_CONFIGURE=$1; shift
defsfile=/tmp/defs_file.h
MANIP=$OLD_CONFIGURE.tmp
FINAL=/tmp/final_config.h
IGNORE_LIST="LINUX_BACKPORT \
	HAVE_DEVLINK_HEALTH_REPORT_SUPPORT"

if [ ! -f "${OLD_CONFIGURE}" ]; then
	echo "-E- File entered not exist" >&2
	exit 1
fi
echo "Processing $OLD_CONFIGURE ..."
#rm -rf $MANIP
#IGNORE_LINE=0
#while read -r line;
#do
#	if (echo "$line" | grep -q "$IGNORE_LIST"); then
#		IGNORE_LINE=1
#	fi
#	if [ $IGNORE_LINE -eq 0 ];then
#		echo "$line" >> $MANIP
#	fi
#	if (echo "$line" | grep -q "#endif"); then
#		IGNORE_LINE=0
#	fi
#done < $OLD_CONFIGURE
#mv -f $MANIP $OLD_CONFIGURE
sed -i ':x /\\$/ { N; s/\\\n//g ; bx }'  $OLD_CONFIGURE
sed -i '1,4d' $OLD_CONFIGURE
cat $defsfile > $FINAL
unifdef -f $defsfile $OLD_CONFIGURE >> $FINAL

echo "Final config file ready at: '${FINAL}'"
