#!/bin/bash
#-------------------SCRIPT VARIABLES-------------------#
BASE_BRANCH=""
TAG=""
configure_ofed_env_location=""
script_name="create_ofed_env"
clone_path=""
work_dir=""
local_branch="make_history_branch"

#----------------------FUNCTIONS-----------------------#
Validate_user_arguments()
{
	if [ -z "$work_dir" ];then
		echo "-E- --path must be given, Aborting"
		exit 1
	fi
	if [ ! -d "$work_dir" ];then
		echo "-E- --path ${work_dir} could not be found, Aborting"
		exit 1
	fi
	if [ -z "$BASE_BRANCH" ];then
		echo "-E- --base-branch must be given, Aborting"
		exit 1
	else
		cd "${work_dir}"
		if [ "$(git ls-remote --heads origin ${BASE_BRANCH} | wc -l)" -eq 0 ]; then
			echo "-E- base branch origin/${BASE_BRANCH} is missing, Aborting"
			exit 1
		fi
		if [ "$(git ls-remote --heads origin ${BASE_BRANCH}_history | wc -l)" -gt 0 ]; then
			echo "-E- backport branch origin/${BASE_BRANCH}_history already exist... Aborting"
			exit 1
		fi
		return
	fi
}

prepare_repo()
{
	git checkout origin/${BASE_BRANCH} -b "${local_branch}"
	rev=$(git rev-parse --verify --short HEAD)
	./ofed_scripts/ofed_patch.sh
	if [ ! -f backports_applied ];then
		echoerr "Failed in patches apply!, Aborting"
		exit 1
	fi
	git reset ${rev}
	rm -rf backports
}

modify_top_commit()
{
	git add -f backports_applied
	git add -u
	git commit --amend --no-edit
}

push_new_branch()
{
	sudo -u alaa  git push  ssh://l-gerrit.mtl.labs.mlnx:29418/mlnx_ofed/mlnx-ofa_kernel-4.0 "backport-${local_branch}:refs/heads/${BASE_BRANCH}_history"
	echo "New Branch pushed: ${BASE_BRANCH}_history"
}
#------------------------MAIN--------------------------#
while [ ! -z "$1" ]
do
	case "$1" in
		--base-branch)
		BASE_BRANCH="$2"
		shift
		;;
		--tag)
		TAG="$2"
		shift
		;;
		--path)
		work_dir="$2"
		shift
		;;
		-h | --help)
		echo "Usage: ./initial_new_backports_history_branch.sh --base-branch <BRANCH> --path <PATH>

	use this script to build OFED environment.
	important: need to source this script for full functionality.
	run this script as USER.

		-h, --help 		display this help message and exit.
		--base-branch		Valid mlnx_ofa branch - create history branch for it [Must]
		--path			Path to OFED repo [Must].
		--tag			Valid mlnx_ofa tag to checkout - create history branch from that location
					[OPTIONAL - defatult is top of branch]
"
		exit 1
		;;
		*)
		echo "-E- Unsupported option: $1" >&2
		echo "use -h flag to display help menu"
		exit 1
		;;
	esac
	shift
done

Validate_user_arguments
prepare_repo
modify_top_commit
push_new_branch
