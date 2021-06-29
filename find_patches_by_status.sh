#!/bin/bash -x

######## VARIABLES ########
LOG="/tmp/log.txt"
FROM=""
TO=""
STATUS=""
OLD_IFS=$IFS
#$IFS='\n'
FORMAT_DIR=""
APPLY_DIR=""
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
		-s, --status		Status script looks for {accepted, ignore, NA, rejected, in_progress}.
		--format-patch		format-patch to given directory.
		-a, --try-apply		Get accurate status for patch, need to get path for ofed dir where patch need to be applied.
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
			FORMAT_DIR="$1"
			if [ -z "$FORMAT_DIR" ];then
				echo "-E- --format-patch missing path to dir, Aborting"
				exit 1
			fi
		;;
		-a | --try_apply)
			shift
			APPLY_DIR="$1"
			if [ -z "$APPLY_DIR" ];then
				echo "-E- -a|--try_apply missing path to dir, Aborting"
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

########FUNCTIONS##########


try_reverse_apply()
{
	local ofed_loc=$1;shift
        local ploc=$1; shift
	cwd="$(pwd)"	
	cd "$ofed_loc"
	#echo "*** git apply -R --check ${ploc}"
	git apply -R --check --exclude="metadata/*" --exclude="backports/*" "${ploc}" 2> /dev/null
	if [ $? -eq 0 ]; then
		OUT_STR="Code fully inside"
	else
		OUT_STR="Not fully inside -"
		git apply --check --exclude="metadata/*" ${ploc} 2> /dev/null
		if [ $? -eq 0 ]; then
			OUT_STR="${OUT_STR} Apply succeded"
		else
			OUT_STR="${OUT_STR} Apply failed"
		fi
	fi
	cd "${cwd}"
	echo "$OUT_STR"
}

###########################
if [ -z "$TO" ] || [ -z "$FROM" ]; then
	echo "-E- must get -f, -t arguments, aborting.."
	exit 1
fi
OUTPUTFILE="commits_status.csv"
echo "sep=;">$OUTPUTFILE
echo "Sha;Subject;Feature;Status;Note;Signed-off by;Patch name;" >>$OUTPUTFILE

git log --oneline --pretty='format:%h;%s' $FROM..$TO > $LOG
while read line; do
	sha=$(echo "$line" | cut -d";" -f1)
	sub=$(echo "$line" | cut -d";" -f2)
	feature="$(git grep "$sub" | grep -oE "feature=.*;" | cut -d";" -f1 | sed 's/feature=//' | head -1)"
	pname=""
	stat=""
	echo "---------------------------------------------------"
	echo "Working on: $sha $sub"
	echo "feature: $feature"
	if (git grep "subject=${sub}" metadata/ | grep -q "upstream_status=$STATUS;" ); then
		echo "Metadata: $(git grep "subject=$sub" metadata/)"
		if [ ! -z "$FORMAT_DIR" ]; then
			ret="$(git format-patch -1 "$sha" -o "$FORMAT_DIR")"
			pname="$(echo $ret | sed 's/.*\///')"
			echo "Format-patch for commit at: $ret"
			echo "pname: $pname"
			stat="$(try_reverse_apply "$APPLY_DIR" "$ret")"
			echo "stat = $stat"
		fi
		echo "$sha;$sub;$feature;$stat;;;$pname;" >> $OUTPUTFILE
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
