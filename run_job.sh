#!/bin/bash
##### SCRIPT VARIABLES #####
full_list=("linux-5.6-rc2,linux-5.5,linux-5.4,linux-5.3,linux-5.2,linux-5.0,linux-4.20,linux-4.19,linux-4.18,linux-4.17-rc1,linux-4.16,linux-4.15,linux-4.14.3,linux-4.13,linux-4.12-rc6,linux-4.11,linux-4.10-Without-VXLAN,linux-4.10-IRQ_POLL-OFF,linux-4.10,linux-4.9,linux-4.8-rc4,linux-4.7-rc7,linux-4.6.3,linux-4.5.5-300.fc24.x86_64,linux-4.5.1,linux-4.4.73-5-default,linux-4.4.21-69-default,linux-4.4.0-22-generic,linux-4.4,linux-4.3-rc6,linux-4.2.3-300.fc23.x86_64,linux-4.2-rc8,linux-4.1.12-37.5.1.el6uek.x86_64,linux-4.1,linux-4.0.4-301.fc22.x86_64,linux-4.0.1,linux-3.19.0,linux-3.18,linux-3.17.4-301.fc21.x86_64,linux-3.17.1,linux-3.16-rc7,linux-3.15.7-200.fc20.x86_64,linux-3.15,linux-3.14,linux-3.13.1,linux-3.12.49-11-xen,linux-3.12.49-11-default,linux-3.12.28-4-default,linux-3.10.0+10,linux-3.10.0+2,linux-3.10,linux-3.10.0-327.el7.x86_64,linux-3.10.0-514.el7.x86_64-ok,linux-3.10.0-229.el7.x86_64,linux-3.10.0-123.el7.x86_64,linux-3.10.0-657.el7.x86_64,linux-3.10.0-693.el7.x86_64,linux-3.10.0-862.el7.x86_64,linux-3.10.0-957.el7.x86_64")
short_list=("linux-5.6-rc2,linux-5.0,linux-4.16,linux-4.11,linux-4.9,linux-4.5.1,linux-4.2-rc8,linux-3.19.0,linux-3.15,linux-3.10,linux-3.10.0-123.el7.x86_64")
kernel_list="
	'linux-5.6-rc2'\n'linux-5.5'\n'linux-5.4'\n'linux-5.3'\n'linux-5.2'\n'linux-5.0'\n'linux-4.20'\n'linux-4.19'\n'linux-4.18'\n'linux-4.17-rc1'\n'linux-4.16'\n'linux-4.15'\n'linux-4.14.3'\n'linux-4.13'\n'linux-4.12-rc6'\n'linux-4.11'\n'linux-4.10-Without-VXLAN'\n'linux-4.10-IRQ_POLL-OFF'\n'linux-4.10'\n'linux-4.9'\n'linux-4.8-rc4'\n'linux-4.7-rc7'\n'linux-4.6.3'\n'linux-4.5.5-300.fc24.x86_64'\n'linux-4.5.1'\n'linux-4.4.73-5-default'\n'linux-4.4.21-69-default'\n'linux-4.4.0-22-generic'\n'linux-4.4'\n'linux-4.3-rc6'\n'linux-4.2.3-300.fc23.x86_64'\n'linux-4.2-rc8'\n'linux-4.1.12-37.5.1.el6uek.x86_64'\n'linux-4.1'\n'linux-4.0.4-301.fc22.x86_64'\n'linux-4.0.1'\n'linux-3.19.0'\n'linux-3.18'\n'linux-3.17.4-301.fc21.x86_64'\n'linux-3.17.1'\n'linux-3.16-rc7'\n'linux-3.15.7-200.fc20.x86_64'\n'linux-3.15'\n'linux-3.14'\n'linux-3.13.1'\n'linux-3.12.49-11-xen'\n'linux-3.12.49-11-default'\n'linux-3.12.28-4-default'\n'linux-3.10.0+10'\n'linux-3.10.0+2'\n'linux-3.10'\n'linux-3.10.0-327.el7.x86_64'\n'linux-3.10.0-514.el7.x86_64-ok'\n'linux-3.10.0-229.el7.x86_64'\n'linux-3.10.0-123.el7.x86_64'\n'linux-3.10.0-657.el7.x86_64'\n'linux-3.10.0-693.el7.x86_64'\n'linux-3.10.0-862.el7.x86_64'\n'linux-3.10.0-957.el7.x86_64'
"
module_list="
	'ib_core'\n'mlx5_core'\n'mlx5_mod'
"
kernel_arr=("linux-5.6-rc2" "linux-5.5" "linux-5.4" "linux-5.3" "linux-5.2" "linux-5.0" "linux-4.20" "linux-4.19" "linux-4.18" "linux-4.17-rc1" "linux-4.16" "linux-4.15" "linux-4.14.3" "linux-4.13" "linux-4.12-rc6" "linux-4.11" "linux-4.10-Without-VXLAN" "linux-4.10-IRQ_POLL-OFF" "linux-4.10" "linux-4.9" "linux-4.8-rc4" "linux-4.7-rc7" "linux-4.6.3" "linux-4.5.5-300.fc24.x86_64" "linux-4.5.1" "linux-4.4.73-5-default" "linux-4.4.21-69-default" "linux-4.4.0-22-generic" "linux-4.4" "linux-4.3-rc6" "linux-4.2.3-300.fc23.x86_64" "linux-4.2-rc8" "linux-4.1.12-37.5.1.el6uek.x86_64" "linux-4.1" "linux-4.0.4-301.fc22.x86_64" "linux-4.0.1" "linux-3.19.0" "linux-3.18" "linux-3.17.4-301.fc21.x86_64" "linux-3.17.1" "linux-3.16-rc7" "linux-3.15.7-200.fc20.x86_64" "linux-3.15" "linux-3.14" "linux-3.13.1" "linux-3.12.49-11-xen" "linux-3.12.49-11-default" "linux-3.12.28-4-default" "linux-3.10.0+10" "linux-3.10.0+2" "linux-3.10" "linux-3.10.0-327.el7.x86_64" "linux-3.10.0-514.el7.x86_64-ok" "linux-3.10.0-229.el7.x86_64" "linux-3.10.0-123.el7.x86_64" "linux-3.10.0-657.el7.x86_64" "linux-3.10.0-693.el7.x86_64" "linux-3.10.0-862.el7.x86_64" "linux-3.10.0-957.el7.x86_64")


script_name="run_job"
ib_core_flags="--with-core-mod,--with-user_mad-mod,--with-user_access-mod,--with-addr_trans-mod,--with-memtrack"
mlx5_core_flags="-with-memtrack,--with-core-mod,--with-user_mad-mod,--with-user_access-mod,--with-addr_trans-mod,--with-mlx5-core-only-mod"
mlx5_mod_flags="--with-memtrack --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod  --with-mlx5-mod"
job_packages=""
job_kernels=""
selected_module=""
selected_kernel=""
ignore_regex=""
is_ignore=0
is_full=0
is_short=0
is_custom=0
without_odp=0
debug_mode=0

##########FUNCTIONS##################

check_selected_kernel()
{
local arg=$1; shift 
for ker in "${kernel_arr[@]}"
do
	if [ $ker = $arg ]; then
		echo 1
	fi
done
echo 0
}


custom_kernels()
{
local how_many=3
local ret_list="$selected_kernel"
for ((index=0; index < ${#kernel_arr[@]}; index++));
do
	if [ $selected_kernel = ${kernel_arr[$index]} ]; then
		index=$((index+1))		
		while [ $how_many -gt 0 ] && [ $index -lt ${#kernel_arr[@]} ];
		do
			ret_list="$ret_list,${kernel_arr[$index]}"
			index=$((index+1))
			how_many=$((how_many-1))
		done
		echo $ret_list	
	fi
done
}

###########MAIN###############
myBranch=$(git rev-parse --abbrev-ref HEAD)
if [[ $myBranch == *"backport"* ]]; then
        echo "-E- your current branch is backport branch,"
        echo "please checkout another before running this script"
        exit 1
fi
while [ ! -z "$1" ]
do
	case "$1" in
		-n | --no-odp)
		without_odp=1
		;;
		-l | --module-list)
		echo "module list:"
		echo "------------"
		echo -e $module_list
		exit 1	
		;;
		-k | --kernel-list)
		echo "kernel list:"
		echo "-----------------"
		echo -e $kernel_list
		exit 1	
		;;
		-f | --full-list)
		is_full=1
		;;
		-s | --short-list)
		is_short=1
		;;
		-d | --debug-mode)
		debug_mode=1
		;;
		-c | --custom)
		selected_kernel="$2"
		ret=$(check_selected_kernel "${selected_kernel}")
		if [ "$ret" = "0" ] 
		then 
			echo "-E- Unsupported kernek: $selected_kernel" >&2
			echo "please check available kernels with -k,--kernel-list"
			exit 1
			
		fi	
		is_custom=1
		shift
		;;
		-m | --module)
		selected_module="$2"
		case "$selected_module" in
			ib_core)
			job_packages=$ib_core_flags
			;;
			mlx5_core)
			job_packages=$mlx5_core_flags
			;;
			mlx5_mod)
			job_packages=$mlx5_mod_flags
			;;
			*)
			echo "-E- Unsupported module: $selected_module" >&2
			exit 1
			;;
		esac
		shift
		;;
		-i | --ignore)
		is_ignore=1
		ignore_regex="$2"
		shift
		;;
		-h | --help)
		echo "Usage: ${script_name} [options]
			
	use this script to config your jenkins job.
	this job will build ofed over wanted kernels.

		-h, --help 		display this help message and exit
		-m, --module 		config job for specific module check [default module is ib_core]
		-n, --no-odp		ignore odp feature at configure
		-k, --kernel-list 	display availanle KERNELS and exit
		-l, --module-list	display available MODULEs and exit
		-c, --custom 		run check for given kernel plus 3 kernels below 
		-f, --full-list		run check for all available kernels [default]
		-s, --sort-list		run check for small list of kernels [can combine with custom list]
		-i, --ignore		ignore warning contains given argument [argument sould be regex syntax]
		-d, --debug-mode	print all script variables
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
if [ -z "$selected_module" ]
then
	selected_module="ib_core [default]"
	job_packages=$ib_core_flags
fi	
if [ $without_odp -eq 1 ]; then
	job_packages="$job_packages,--without-odp"
fi
if [ $is_ignore -eq 1 ]; then
	job_packages="$job_packages&WARNINGS_IGNORES=$ignore_regex"
fi

if [ $is_short -eq 1 ]; then
	job_kernels=$short_list
	if [ $is_custom -eq 1 ]; then
		job_kernels="$job_kernels,"
	fi	
fi
if [ $is_custom -eq 1 ]; then
		job_kernels="$job_kernels$(custom_kernels)"
fi
if [ $is_full -eq 1 ] ||  ([ $is_short -eq 0 ] && [ $is_custom -eq 0 ]); then
	job_kernels=$full_list
fi

if [ $debug_mode -eq 1 ]; then
echo "run_job debug mode:"
echo "module: $selected_module"
echo "kernel: $selected_kernel"
echo "is full: $is_full"
echo "is short: $is_short"
echo "is custom: $is_custom"
echo "is ignore: $is_ignore"
echo "regex to ignore: $ignore_regex"
echo "without odp: $without_odp"
echo "http://linux-int.lab.mtl.com:8080/job/MLNX_OFED/job/CI/job/ofed-5.1_backports/buildWithParameters?token=backports&KERNELS=${job_kernels}&PACKAGES=${job_packages}"
echo "**************************"
else
echo "start docker build with configuration:" 
echo "module check: $selected_module"
if [ $without_odp -eq 1 ]; then
	echo "compile without ODP"
fi
echo "compile over kernels: $job_kernels"
curl -u valentinef:17Click17 "http://linux-int.lab.mtl.com:8080/job/MLNX_OFED/job/CI/job/ofed-5.1_backports/buildWithParameters?token=backports&KERNELS=${job_kernels}&PACKAGES=${job_packages}"
echo "job is runnig, see results at link:"
echo "http://linux-int.lab.mtl.com:8080/job/MLNX_OFED/job/CI/job/ofed-5.1_backports/" 
fi
