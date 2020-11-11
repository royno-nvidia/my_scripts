#!/bin/bash

OLD_CONFIG=$1; shift
defsfile=/tmp/defs_file.h

if [ ! -f "${OLD_CONFIG}" ]; then
	echo "-E- File entered not exist" >&2
	exit 1
fi
echo "Processing $OLD_CONFIG ..."
/bin/cp -f $OLD_CONFIG  ${defsfile}
sed -i 's/\/\*\s*\(#undef .*\) \*\//\1/g' ${defsfile}
sed -i '/\/\*/d' ${defsfile}
sed -i '/\*\//d' ${defsfile}
sed -i '/#endif/d' ${defsfile}
sed -i '/^\s*$/d' ${defsfile}

echo "New defs file ready at: '${defsfile}'"
