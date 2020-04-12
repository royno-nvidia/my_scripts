#!/bin/bash

#---------------------USER MUTABLES---------------------------#
#PREMANENT_USER get username:gerrit_password, F.E "royno:123123"
#!!please notice!! this user and password are not secured so remember to erase it at the end of use. 
PERMANENT_USER="valentinef:17Click17"
#--------------------------------------------------------------------------------------------------#

#GIT_PATH gets full path to /.git directory you wan't to build from.
#this will be default path unless you use {-g | --git-repo} flag
#F.E "/swgwork/valentinef/rebase_5_1_backports/mlnx-ofa_kernel-4.0/.git"
GIT_PATH='/swgwork/valentinef/rebase_5_1_backports/mlnx-ofa_kernel-4.0/.git'
#----------------------------------------------------------------#
#IGNORE_WARNINGS get regex arguments, F.E: '"reg1","reg2","reg3"'#
IGNORE_WARNINGS=".*ibta_vol1_c12.*"
#----------------------------------------------------------------#

#---------------------SCRIPT VARIABLES---------------------------#
FULL_LIST=("linux-5.6,linux-5.5,linux-5.4,linux-5.3,linux-5.2,linux-5.0,linux-4.20,linux-4.19,linux-4.18,linux-4.17-rc1,linux-4.16,linux-4.15,linux-4.14.3,linux-4.13,linux-4.12-rc6,linux-4.11,linux-4.10-Without-VXLAN,linux-4.10-IRQ_POLL-OFF,linux-4.10,linux-4.9,linux-4.8-rc4,linux-4.7-rc7,linux-4.6.3,linux-4.5.5-300.fc24.x86_64,linux-4.5.1,linux-4.4.73-5-default,linux-4.4.21-69-default,linux-4.4.0-22-generic,linux-4.4,linux-4.3-rc6,linux-4.2.3-300.fc23.x86_64,linux-4.2-rc8,linux-4.1.12-37.5.1.el6uek.x86_64,linux-4.1,linux-4.0.4-301.fc22.x86_64,linux-4.0.1,linux-3.19.0,linux-3.18,linux-3.17.4-301.fc21.x86_64,linux-3.17.1,linux-3.16-rc7,linux-3.15.7-200.fc20.x86_64,linux-3.15,linux-3.14,linux-3.13.1,linux-3.12.49-11-xen,linux-3.12.49-11-default,linux-3.12.28-4-default,linux-3.10,linux-3.10.0-327.el7.x86_64,linux-3.10.0-514.el7.x86_64-ok,linux-3.10.0-229.el7.x86_64,linux-3.10.0-123.el7.x86_64,linux-3.10.0-657.el7.x86_64,linux-3.10.0-693.el7.x86_64,linux-3.10.0-862.el7.x86_64,linux-3.10.0-957.el7.x86_64")

KERNEL_LIST="
	'linux-5.6'\n'linux-5.5'\n'linux-5.4'\n'linux-5.3'\n'linux-5.2'\n'linux-5.0'\n'linux-4.20'\n'linux-4.19'\n'linux-4.18'\n'linux-4.17-rc1'\n'linux-4.16'\n'linux-4.15'\n'linux-4.14.3'\n'linux-4.13'\n'linux-4.12-rc6'\n'linux-4.11'\n'linux-4.10-Without-VXLAN'\n'linux-4.10-IRQ_POLL-OFF'\n'linux-4.10'\n'linux-4.9'\n'linux-4.8-rc4'\n'linux-4.7-rc7'\n'linux-4.6.3'\n'linux-4.5.5-300.fc24.x86_64'\n'linux-4.5.1'\n'linux-4.4.73-5-default'\n'linux-4.4.21-69-default'\n'linux-4.4.0-22-generic'\n'linux-4.4'\n'linux-4.3-rc6'\n'linux-4.2.3-300.fc23.x86_64'\n'linux-4.2-rc8'\n'linux-4.1.12-37.5.1.el6uek.x86_64'\n'linux-4.1'\n'linux-4.0.4-301.fc22.x86_64'\n'linux-4.0.1'\n'linux-3.19.0'\n'linux-3.18'\n'linux-3.17.4-301.fc21.x86_64'\n'linux-3.17.1'\n'linux-3.16-rc7'\n'linux-3.15.7-200.fc20.x86_64'\n'linux-3.15'\n'linux-3.14'\n'linux-3.13.1'\n'linux-3.12.49-11-xen'\n'linux-3.12.49-11-default'\n'linux-3.12.28-4-default'\n'linux-3.10'\n'linux-3.10.0-327.el7.x86_64'\n'linux-3.10.0-514.el7.x86_64-ok'\n'linux-3.10.0-229.el7.x86_64'\n'linux-3.10.0-123.el7.x86_64'\n'linux-3.10.0-657.el7.x86_64'\n'linux-3.10.0-693.el7.x86_64'\n'linux-3.10.0-862.el7.x86_64'\n'linux-3.10.0-957.el7.x86_64'
"

MODULE_LIST="
	'ib_core'\n''mlx5_mod'
"

KERNEL_ARR=("linux-5.6" "linux-5.5" "linux-5.4" "linux-5.3" "linux-5.2" "linux-5.0" "linux-4.20" "linux-4.19" "linux-4.18" "linux-4.17-rc1" "linux-4.16" "linux-4.15" "linux-4.14.3" "linux-4.13" "linux-4.12-rc6" "linux-4.11" "linux-4.10-Without-VXLAN" "linux-4.10-IRQ_POLL-OFF" "linux-4.10" "linux-4.9" "linux-4.8-rc4" "linux-4.7-rc7" "linux-4.6.3" "linux-4.5.5-300.fc24.x86_64" "linux-4.5.1" "linux-4.4.73-5-default" "linux-4.4.21-69-default" "linux-4.4.0-22-generic" "linux-4.4" "linux-4.3-rc6" "linux-4.2.3-300.fc23.x86_64" "linux-4.2-rc8" "linux-4.1.12-37.5.1.el6uek.x86_64" "linux-4.1" "linux-4.0.4-301.fc22.x86_64" "linux-4.0.1" "linux-3.19.0" "linux-3.18" "linux-3.17.4-301.fc21.x86_64" "linux-3.17.1" "linux-3.16-rc7" "linux-3.15.7-200.fc20.x86_64" "linux-3.15" "linux-3.14" "linux-3.13.1" "linux-3.12.49-11-xen" "linux-3.12.49-11-default" "linux-3.12.28-4-default" "linux-3.10" "linux-3.10.0-327.el7.x86_64" "linux-3.10.0-514.el7.x86_64-ok" "linux-3.10.0-229.el7.x86_64" "linux-3.10.0-123.el7.x86_64" "linux-3.10.0-657.el7.x86_64" "linux-3.10.0-693.el7.x86_64" "linux-3.10.0-862.el7.x86_64" "linux-3.10.0-957.el7.x86_64")

SCRIPT_NAME="run_job"
IB_CORE_FLAGS="--with-core-mod,--with-user_mad-mod,--with-user_access-mod,--with-addr_trans-mod,--with-memtrack"
MLX5_MOD_FLAGS="--with-memtrack,--with-core-mod,--with-user_mad-mod,--with-user_access-mod,--with-addr_trans-mod,--with-mlx5-mod"
JOB_PACKAGES=""
JOB_KERNELS=""
SELECTED_MODULES=""
SELECTED_KERNEL=""
IGNORE_REGEX=""
IS_IGNORE=0
IS_FULL=0
IS_CUSTOM=0
WITHOUT_ODP=0
DEBUG_MODE=0

#-------------------FUNCTIONS-----------------#

check_selected_kernel()
{
local arg=$1; shift 
for ker in "${KERNEL_ARR[@]}"
do
	if [ $ker = $arg ]; then
		echo 1
	fi
done
echo 0
}


custom_kernels()
{
local how_many=4
local ret_list=""
for ((index=0; index < ${#KERNEL_ARR[@]}; index++));
do
	if [ $index -eq 0  ]
       	then
	ret_list="${KERNEL_ARR[$index]}"
	else
	ret_list="$ret_list,${KERNEL_ARR[$index]}"
	fi
	if [ $SELECTED_KERNEL = ${KERNEL_ARR[$index]} ]; then
		index=$((index+1))		
		while [ $how_many -gt 0 ] && [ $index -lt ${#KERNEL_ARR[@]} ];
		do
			ret_list="$ret_list,${KERNEL_ARR[$index]}"
			index=$((index+1))
			how_many=$((how_many-1))
		done
		echo $ret_list	
	fi
done
}

#--------------------MAIN-------------------#
MY_BRANCH=$(cat ${GIT_PATH}/HEAD | sed -e 's/.*heads\///')
if [[ $MY_BRANCH == *"backport"* ]]; then
        echo "-E- your current branch is backport branch,"
        echo "please checkout another before running this script"
        exit 1
fi
while [ ! -z "$1" ]
do
	case "$1" in
		-n | --without-odp)
		WITHOUT_ODP=1
		;;
		-l | --module-list)
		echo "module list:"
		echo "------------"
		echo -e $MODULE_LIST
		exit 1	
		;;
		-k | --kernel-list)
		echo "kernel list:"
		echo "-----------------"
		echo -e $KERNEL_LIST
		exit 1	
		;;
		-f | --full-list)
		IS_FULL=1
		;;
		-d | --debug-mode)
		DEBUG_MODE=1
		;;
		-c | --custom)
		SELECTED_KERNEL="$2"
		ret=$(check_selected_kernel "${SELECTED_KERNEL}")
		if [ "$ret" = "0" ] 
		then I
			echmnent "-E- Unsupported kernek: $SELECTED_KERNEL" >&2
			echo "please check available kernels with -k,--kernel-list"
			exit 1
			
		fi	
		IS_CUSTOM=1
		shift
		;;
		-m | --module)
		SELECTED_MODULE="$2"
		case "$SELECTED_MODULE" in
			ib_core)
			JOB_PACKAGES=$IB_CORE_FLAGS
			;;
			mlx5_mod)
			JOB_PACKAGES=$MLX5_MOD_FLAGS
			;;
			*)
			echo "-E- Unsupported module: $SELECTED_MODULE" >&2
			exit 1
			;;
		esac
		shift
		;;
		-i | --ignore)
		if [ -z "${IGNORE_WARNINGS}" ]
		then
			IGNORE_WARNINGS="$2"
		else
			IGNORE_WARNINGS="${IGNORE_WARNINGS},$2"
		fi	
		shift
		;;
		-g | --git-repo)
		if [[ $2 =~ "/mlnx-ofa_kernel-4.0/.git" ]]; then
		GIT_PATH=$2
		else
		echo "given path with flag {-g | --git-repo} must end with /mlnx-ofa_kernel-4.0/.git" 
		exit 1
		fi
		shift
		;;
		-h | --help)
		echo "Usage: ${SCRIPT_NAME} [options]
			
	use this script to config your jenkins job.
	this job will build ofed over wanted kernels.

		-h, --help 		display this help message and exit.
		-m, --module 		config job for specific module check [default module is ib_core].
		-n, --without-odp	ignore odp feature at configure.
		-k, --kernel-list 	display availanle KERNELS and exit.
		-l, --module-list	display available MODULEs and exit.
		-c, --custom 		run job for all kernels higher then given kernel plus 3 kernels below. 
		-f, --full-list		run job for all available kernels [default].
		-i, --ignore		interactive ignore warning [argument sould be regex syntax, 
					for permanent ignore add inside script IGNORE_WARNINGS variable].
		-g, --git-repo		replace default path for git repository job will use as base code.
					this path must point t /mlnx-ofa_kernel-4.0/.git directory.
		-d, --debug-mode	activace 'set -x' will output all script log, still activate job.
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
if [[ $GIT_PATH =~ "/mlnx-ofa_kernel-4.0/.git"  ]]; then
echo "git repository build: ${GIT_PATH}"
else
echo "path at GIT_PATH variable must end with /mlnx-ofa_kernel-4.0/.git" 
exit 1
fi
[ $DEBUG_MODE -eq 1 ] && set -x #acivate 'set -x' if DEBUG_MODE is active
if [ -z "$SELECTED_MODULE" ]
then
	SELECTED_MODULE="ib_core [default]"
	JOB_PACKAGES=$IB_CORE_FLAGS
fi	
if [ $WITHOUT_ODP -eq 1 ]; then
	JOB_PACKAGES="$JOB_PACKAGES,--without-odp"
fi
if [ $IS_CUSTOM -eq 1 ]; then
		JOB_KERNELS="$JOB_KERNELS$(custom_kernels)"
fi
if [ $IS_FULL -eq 1 ] || [ $IS_CUSTOM -eq 0 ]; then
	JOB_KERNELS=$FULL_LIST
fi
echo "start docker build with configuration:" 
echo "module check: $SELECTED_MODULE"
if [ $WITHOUT_ODP -eq 1 ]; then
	echo "compile without ODP"
fi
echo "compile over kernels: $JOB_KERNELS"
if [ ! -z "$PERMANENT_USER" ]
then
curl -u ${PERMANENT_USER} "http://linux-int.lab.mtl.com:8080/job/MLNX_OFED/job/CI/job/ofed-5.1_backports/buildWithParameters?token=backports&GIT_REPOSITORY=${GIT_PATH}&KERNELS=${JOB_KERNELS}&PACKAGES=${JOB_PACKAGES}&WARNINGS_IGNORES=${IGNORE_WARNINGS}"
else 
curl -u $(whoami) "http://linux-int.lab.mtl.com:8080/job/MLNX_OFED/job/CI/job/ofed-5.1_backports/buildWithParameters?token=backports&GIT_REPOSITORY=${GIT_PATH}&KERNELS=${JOB_KERNELS}&PACKAGES=${JOB_PACKAGES}&WARNINGS_IGNORES=${IGNORE_WARNINGS}"
fi
echo "job is runnig, see results at link:"
echo "http://linux-int.lab.mtl.com:8080/job/MLNX_OFED/job/CI/job/ofed-5.1_backports/" 
