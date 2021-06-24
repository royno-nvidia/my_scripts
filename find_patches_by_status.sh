#!/bin/bash

######## VARIABLES ########
LOG="/tmp/log.txt"
FROM=""
TO=""
STATUS=""
OLD_IFS=$IFS
IFS='\n'
FORMAT_DIR=""
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
		--format-patch		format-patch to given directory
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
		--format-patch)
			shift
			FORMAT_DIR=$1
			if [ -z "$FORMAT_DIR" ];then
				echo "-E- --format-patch missing path to dir, Aborting"
				exit 1
			fi
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
if [ -z "$TO" ] || [ -z "$FROM" ]; then
	echo "-E- must get -f, -t arguments, aborting.."
	exit 1
fi
OUTPUTFILE="/tmp/commit_status_${FROM}_${TO}.csv"
echo "sep=;">$OUTPUTFILE
echo "Sha;Subject;Feature;Status;Note;Signed-off by;Patch name;" >>$OUTPUTFILE

git log --oneline --pretty='format:%h;%s' $FROM..$TO > $LOG
while read line; do
	sha=$(echo "$line" | cut -d";" -f1)
	sub=$(echo "$line" | cut -d";" -f2)
	feature="$(git grep "$sub" | grep -oE "feature=.*;" | cut -d";" -f1 | sed 's/feature=//' | head -1)"
	pname=""
	echo "---------------------------------------------------"
	echo "Working on: $sha $sub"
	echo "feature: $feature"
	if (git grep "subject=${sub}" metadata/ | grep -q "upstream_status=$STATUS;" ); then
		echo "Metadata: $(git grep "subject=$sub" metadata/)"
		if [ ! -z "$FORMAT_DIR" ]; then
			ret=$(git format-patch -1 "$sha" -o "$FORMAT_DIR")
			pname=$(echo $ret | sed 's/.*\///')
			echo "Format-patch for commit at: $ret"
			echo "pname: $pname"
		fi
		echo "$sha;$sub;$feature;;;;$pname;" >> $OUTPUTFILE
	fi
	echo "---------------------------------------------------"
done < $LOG
rm -rf $LOG
IFS=$OLD_IFS
echo
echo "Script finished.."
echo "Please see results in '$OUTPUTFILE'"
if [ ! -z "$FORMAT_DIR" ]; then
	echo "Format patches wait at: '$FORMAT_DIR'"
fi
exit 0
