#!/bin/bash

COMPAT_FILE=$1
FOR_SED="splited00"
FOR_UNIFDEF="splited01"
CONFIG_PATH=/tmp/config.h
CONFIGURE_PATH=/tmp/configure.ac
SPLIT_LINE="Make sure LINUX_BACKPORT macro is defined for all external users"
echo "splitting file.."
if [ ! -f $COMPAT_FILE ]; then
	echo "-E- File entered not exist"
	exit 1
fi
if [ ! "X$(basename $COMPAT_FILE)" == "Xconfig.h" ]; then
	echo "-E- Argument for script must be config.h"
	exit 1
fi
if !(grep -q "$SPLIT_LINE" $COMPAT_FILE); then
	echo "-E- Could not found where to split, Aborting.."
	echo "current split at '${SPLIT_LINE}' pattern"
	exit 1
fi

csplit -q --suppress-matched $COMPAT_FILE "/.*${SPLIT_LINE}.*/" -f splited '{*}'
mv -f $FOR_SED $CONFIG_PATH
if [ $? -ne 0 ]; then
	echo "-E- command 'mv -f $FOR_SED $CONFIG_PATH' failed"
fi
mv -f $FOR_UNIFDEF $CONFIGURE_PATH
if [ $? -ne 0 ]; then
	echo "-E- command 'mv -f $FOR_UNIFDEF $CONFIGURE_PATH' failed"
fi
rm -rf splited0*
if [ $? -ne 0 ]; then
	echo "-E- command 'rm -rf splited0*' failed"
fi
echo "create '$CONFIG_PATH'"
echo "create '$CONFIGURE_PATH'"

