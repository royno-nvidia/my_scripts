#!/bin/bash

NEW_CONFIG_H="new_config.h"
INPUT_FILE=$1
FILE_TO_STRIP=$2
FINAL="striped.c"
FOR_SED="xx00"
FOR_UNIFDEF="xx01"
TEMP="temp.txt"
				
#################################

echo "Script start.."
if ! command -v unifdef &> /dev/null
then
	echo "unifdef tool is missing.. installing"
	sudo yum -y install unifdef
fi
echo "Spliting file"
csplit -q $INPUT_FILE '/unifdef split here/'
cat $FOR_UNIFDEF | sed -e 's/\\//g' > $TEMP
echo "Rearange input file"
cat $FOR_SED | grep -E "(define|undef).+HAVE" | sed -e 's/\/\* //g' \
	| sed -e 's/\*\///g' | sed -e 's/\\//g' > $NEW_CONFIG_H

echo "----------------------------------------------"
echo "New configure file made inside: '$NEW_CONFIG_H'"
echo "----------------------------------------------"

unifdef -f $NEW_CONFIG_H -b -o $FINAL $FILE_TO_STRIP 
echo "----------------------------------------------"
echo "File without configs: '$FINAL'"
echo "----------------------------------------------"

vim $FINAL
