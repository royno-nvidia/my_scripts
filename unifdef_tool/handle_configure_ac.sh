#!/bin/bash

OLD_CONFIGURE=$1; shift

if [ ! -f "${OLD_CONFIGURE}" ]; then
	echo "-E- File entered not exist" >&2
	exit 1
fi
echo "Processing $OLD_CONFIGURE ..."
sed -i ':x /\\$/ { N; s/\\\n//g ; bx }'  $OLD_CONFIGURE
sed -i '1,4d' $OLD_CONFIGURE

