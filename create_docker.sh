#!/bin/bash
#------------------SCRIPT VARIABLES---------------#
input_version=""
init_path="/tmp/output/"
#repo_path assigned the default repo
repo_path="/swgwork/valentinef/OFED_REBASE_AREA/rebase_5_2/master/mlnx-ofa_kernel-4.0"
script_name="create_docker"
container_name="$(whoami)"
kernel_list="
'linux-5.9-rc2'\n'linux-5.8'\n'linux-5.7'\n'linux-5.6'\n'linux-5.5'\n'linux-5.4'\n'linux-5.3'\n'linux-5.2'\n'linux-5.0'\n'linux-4.20'\n'linux-4.19'\n'linux-4.18'\n'linux-4.17-rc1'\n'linux-4.16'\n'linux-4.15'\n'linux-4.14.3'\n'linux-4.13'\n'linux-4.12-rc6'\n'linux-4.11'\n'linux-4.10-Without-VXLAN'\n'linux-4.10-IRQ_POLL-OFF'\n'linux-4.10'\n'linux-4.9'\n'linux-4.8-rc4'\n'linux-4.7-rc7'\n'linux-4.6.3'\n'linux-4.5.5-300.fc24.x86_64'\n'linux-4.5.1'\n'linux-4.4.73-5-default'\n'linux-4.4.21-69-default'\n'linux-4.4.0-22-generic'\n'linux-4.4'\n'linux-4.3-rc6'\n'linux-4.2.3-300.fc23.x86_64'\n'linux-4.2-rc8'\n'linux-4.1.12-37.5.1.el6uek.x86_64'\n'linux-4.1'\n'linux-4.0.4-301.fc22.x86_64'\n'linux-4.0.1'\n'linux-3.19.0'\n'linux-3.18'\n'linux-3.17.4-301.fc21.x86_64'\n'linux-3.17.1'\n'linux-3.16-rc7'\n'linux-3.15.7-200.fc20.x86_64'\n'linux-3.15'\n'linux-3.14'\n'linux-3.13.1'\n'linux-3.12'\n'linux-3.12.49-11-xen'\n'linux-3.12.49-11-default'\n'linux-3.10'\n'linux-3.12.28-4-default'\n'linux-3.10.0-327.el7.x86_64'\n'linux-3.10.0-514.el7.x86_64-ok'\n'linux-3.10.0-229.el7.x86_64'\n'linux-3.10.0-123.el7.x86_64'\n'linux-3.10.0-657.el7.x86_64'\n'linux-3.10.0-693.el7.x86_64'\n'linux-3.10.0-862.el7.x86_64'\n'linux-3.10.0-957.el7.x86_64'
"

#----------------------MAIN------------------------#
while [ ! -z "$1" ]
do
	if [[ $1 == "linux"* ]]; then
		input_version=$1
		shift
		continue
	fi
	case "$1" in
		-l | --list)
		echo " supported kernels:"
		echo "-------------------"
		echo -e $kernel_list
		exit 1
		;;
		-r | --repositoty)
		repo_path="$2"
		shift	
		;;
		-n | --name)
		container_name="$2"
		shift	
		;;
		-h | --help)
		echo "Usage: ${script_name} [options] linux-KERNEL_VERSION
			
	use this script to create docker.

		-h, --help 		display this help message and exit
		-l, --list		display list of supported kernel and exit
		-r, --repository	full path for your git repositoy
		-n, --name		create container with specific name [Default: user's name]
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
if [ -z "$repo_path" ]
then
	echo "-E- 'create_docker.sh' must have full path to repository [use {-r | --repository} flag]"
	exit 1
fi
if [ -z "$input_version" ]
then
	echo "-E- 'create_docker.sh' must have version [use: 'create_docker.sh -l' to see supported kernels]"
	exit 1
else
	echo "inside docker for kernel ${input_version}"
	echo ""
	echo "---------------------------------------------------------------------------------------------"
	echo "  use: 'source /output/init_docker.sh'  ['source output/init_docker.sh -h' for help]"
	echo "---------------------------------------------------------------------------------------------"
	echo "Usage: init_docker [options]
			
	use this script to config docker environment.
	important: need to source this script for full functionality.

		-h, --help 		display this help message and exit
		--without-odp		ignore odp feature at configure
		-m, --module 		config environment for specific module [default module is ib_core]
		-l, --module-list	display available MODULEs and exit
"
	sudo cp /swgwork/royno/OFED/my_scripts/init_docker.sh /tmp/output/
sudo docker run -it --rm --entrypoint=/bin/bash --tmpfs /build:rw,exec,nosuid,mode=755,size=20G --name=${container_name} --mount type=tmpfs,target=/tmp/ -v ${repo_path}/.git:/git-repo/:ro -v /tmp/output:/output -v /.autodirect/mswg2/work/kernel.org/x86_64/${input_version}/:/tmp/${input_version}/ harbor.mellanox.com/sw-linux-devops/cross_compile:latest 	

fi
