#!/bin/bash

OLD_CONFIG=$1; shift
DEFSFILE=/tmp/defs_file.h

if [ ! -f "${OLD_CONFIG}" ]; then
	echo "-E- File entered not exist" >&2
	exit 1
fi
echo "Processing $OLD_CONFIG ..."
/bin/cp -f $OLD_CONFIG  ${DEFSFILE}
sed -i 's/\/\*\s*\(#undef .*\) \*\//\1/g' ${DEFSFILE}
sed -i '/\/\*/d' ${DEFSFILE}
sed -i '/\*\//d' ${DEFSFILE}
sed -i '/#endif/d' ${DEFSFILE}
sed -i '/^\s*$/d' ${DEFSFILE}

