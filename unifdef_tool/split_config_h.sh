#!/bin/bash

COMPAT_FILE=$1
FOR_SED="xx00"
FOR_UNIFDEF="xx01"
CONFIG_PATH=/tmp/config.h
CONFIGURE_PATH=/tmp/configure.ac
echo "splitting file.."
if [ ! -f $COMPAT_FILE ]; then
	echo "-E- File entered not exist"
	exit 1
fi
if [ ! "X$(basename $COMPAT_FILE)" == "Xconfig.h" ]; then
	echo "-E- Argument for script must be config.h"
	exit 1
fi
if !(grep -q "split here" $COMPAT_FILE); then
	echo "-E- Could not found where to split, Aborting.."
	exit 1
fi

csplit -q $COMPAT_FILE '/* split here for unifdef */'
mv $FOR_SED $CONFIG_PATH
mv $FOR_UNIFDEF $CONFIGURE_PATH

echo "create '$CONFIG_PATH'"
echo "create '$CONFIGURE_PATH'"

