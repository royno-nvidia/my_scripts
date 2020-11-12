#!/bin/bash

COMPAT_FILE=$1
FOR_SED="splited00"
FOR_UNIFDEF="splited02"
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
	echo "compat/config.h must have '/* unifdef tool split here */'"
	exit 1
fi

csplit -q --suppress-matched $COMPAT_FILE '/* unifdef tool split here */' -f splited '{*}'
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

