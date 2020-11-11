#!/bin/bash

OLD_CONFIGURE=$1; shift
defsfile=/tmp/defs_file.h
MANIP=$OLD_CONFIGURE.tmp
FINAL=/tmp/final_config.h

if [ ! -f "${OLD_CONFIGURE}" ]; then
	echo "-E- File entered not exist" >&2
	exit 1
fi
echo "Processing $OLD_CONFIGURE ..."

sed -i ':x /\\$/ { N; s/\\\n//g ; bx }'  $OLD_CONFIGURE


cat $defsfile > $FINAL
unifdef -f $defsfile $OLD_CONFIGURE >> $FINAL

echo "Final config file ready at: '${FINAL}'"
