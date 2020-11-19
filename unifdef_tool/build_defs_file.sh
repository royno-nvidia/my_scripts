#!/bin/bash

WORK_DIR=$1
COMPAT_FILE=$WORK_DIR/compat/config.h
AUTOCONF_FILE=$WORK_DIR/include/generated/autoconf.h
CONFIG_PATH=/tmp/config.h
CONFIGURE_PATH=/tmp/configure.ac
DEFSFILE=/tmp/defs_file.h
AUTOCONF_PATH=/tmp/final_autoconf.h
FINAL=/tmp/final_defs.h


echo "$FINAL"
sudo rm -rf $CONFIG_PATH $CONFIGURE_PATH $DEFSFILE $AUTOCONF_PATH
echo "start build compat file '$FINAL' for unifdef use"
/swgwork/royno/OFED/my_scripts/unifdef_tool/unifdef_installer.sh
if [ $? -ne 0 ];then
	echo "Script failed.."
	exit 1
fi
cp $COMPAT_FILE /tmp/$(date +%s)_$(basename $COMPAT_FILE)
/.autodirect/swgwork/royno/OFED/my_scripts/unifdef_tool/split_config_h.sh $COMPAT_FILE
/.autodirect/swgwork/royno/OFED/my_scripts/unifdef_tool/handle_config_h.sh $CONFIG_PATH
/.autodirect/swgwork/royno/OFED/my_scripts/unifdef_tool/handle_configure_ac.sh $CONFIGURE_PATH
/.autodirect/swgwork/royno/OFED/my_scripts/unifdef_tool/handle_autoconf_h.sh $AUTOCONF_FILE

echo "/*-----------------------*/" > $FINAL
echo "/* config.h defs section */" >> $FINAL
echo "/*-----------------------*/" >> $FINAL
cat $DEFSFILE >> $FINAL
echo "/*---------------------------*/" >> $FINAL
echo "/* configure.ac defs section */" >> $FINAL
echo "/*---------------------------*/" >> $FINAL
unifdef -f $DEFSFILE $CONFIGURE_PATH >> $FINAL
echo "/*-------------------------*/" >> $FINAL
echo "/* autoconf.h defs section */" >> $FINAL
echo "/*-------------------------*/" >> $FINAL
cat $AUTOCONF_PATH >> $FINAL

rm -rf $CONFIG_PATH $CONFIGURE_PATH $DEFSFILE $AUTOCONF_PATH
echo "'${FINAL}' created"

