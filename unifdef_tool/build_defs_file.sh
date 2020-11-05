#!/bin/bash

dir=$1; shift

if [ ! -d "${dir}" ]; then
	echo "-E- path to ofa-kernel dir is not given" >&2
	exit 1
fi
echo ${dir}
defsfile=/tmp/defs_file.h
cd ${dir}
echo "Processing compat/config.h ..."
/bin/cp -f compat/config.h  ${defsfile}
sed -i 's/\/\*\s*\(#undef .*\) \*\//\1/g' ${defsfile}
sed -i '/\/\*/d' ${defsfile}
sed -i '/\*\//d' ${defsfile}
sed -i '/#ifndef LINUX_BACKPORT/d' ${defsfile}
sed -i '/#define LINUX_BACKPORT/d' ${defsfile}
sed -i '/#endif/d' ${defsfile}

echo "Processing compat.config ..."
/bin/cp -f compat.config compat.config.tmp
sed -i  -e 's/export/#define/'  -e 's/=y/ 1/' compat.config.tmp
cat compat.config.tmp >> ${defsfile}
rm -f compat.config.tmp

echo "Looking for CONFIG_COMPAT_ macros that are used but not enabled ..."
for ii in $(grep -rh "CONFIG_COMPAT_" ${dir}/{include,drivers} | sed -r -e 's/.*(CONFIG_COMPAT_[a-zA-Z_0-9]*).*/\1/g')
do
	if !(grep -qw "${ii}" compat.config); then
		if !(grep -qw "${ii}" ${defsfile}); then

			echo "#undef ${ii}" >> ${defsfile}
		fi
	fi
done

echo
echo "defs file ready at: ${defsfile}"
