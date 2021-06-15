#!/bin/bash

######## VARIABLES ########
LOG="/tmp/t.txt"
FROM=""
TO=""
STATUS=""
OLD_IFS=$IFS
IFS='\n'
######### ARGS PARSER ########
while [ ! -z "$1" ]
do
	case "$1" in
		-h | --help)
		echo "Usage: find_patches_by_status.sh -s <status> -f <hash> -t <hash>

		Description: This script uses for finding all patches with specific status, should run inside OFED repo directory.
			     It should be run under MLNX_OFA project ditrctory.

		-h, --help 		display this help message and exit.
		-f, --from-hash		Start search hash.
		-t, --to-hash		End search hash.
		-s, --status		Status script looks for {accepted, ignore, NA, rejected, in_progress}
"
		exit 1
		;;
		-f | --from-hash)
			shift
			FROM=$1
		;;
		-t | --to-hash)
			shift
			TO=$1
		;;
		-s | --status)
			shift
			STATUS=$1
		;;
		*)
		echo "-E- Unsupported option: $1" >&2
		echo "use -h flag to display help menu"
		exit 1
		;;
	esac
	shift
done

######################
if [ -z "$TO" ] || [ -z "$FROM" ] || [ -z "$STATUS" ]; then
	echo "-E- must get -f, -t, -s arguments, aborting.."
	exit 1
fi
git log --oneline --pretty='format:%s' $FROM^..$TO > $LOG
while read sub; do
	if (git grep "$sub" metadata/ | grep -q "upstream_status=$STATUS" ); then
		echo "$sub"
	fi
done < $LOG
rm -rf $LOG
IFS=$OLD_IFS
exit 0
