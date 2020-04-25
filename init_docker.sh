#!/bin/bash
#----------------SCRIPT VARIABLES--------------------#
input_version=$(ls -a /tmp/ | grep linux | sed -e 's/linux-//')
ib_core_flags="--with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod --with-memtrack"
mlx5_mod_flags="--with-memtrack --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod  --with-mlx5-mod"
ib_ipoib_flags="--with-memtrack --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod  --with-mlx5-mod --with-ipoib-mod"
mlxfw_flags="--with-memtrack --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod  --with-mlx5-mod --with-mlxfw-mod"
rxe_flags="--with-memtrack --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod  --with-rxe-mod"
fpga_flags="--with-memtrack --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod  --with-mlx5-mod --with-innova-flex"
ipsec_flags="--with-memtrack --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod  --with-mlx5-mod --with-innova-flex --with-innova-ipsec"
my_flags=""
script_name="init_docker"
selected_module=""
without_odp=0
module_list="
'ib_core'\n'mlx5_mod'\n'ib_ipoib'\n'mlxfw'\n'rxe'\nfpga\nfpgaWithIspec\n
"
#--------------------------MAIN-----------------------#
MY_BRANCH=$(cat /git-repo/HEAD | sed -e 's/.*heads\///')
if [[ $MY_BRANCH == *"backport"* ]]; then
        echo "-E- your current branch is backport branch,"
        echo "please checkout another before running this script"
        exit 1
fi
while [ ! -z "$1" ]
do
	case "$1" in
		--without-odp)
		without_odp=1
		;;
		-l | --module-list)
		echo "module list:"
		echo "------------"
		echo -e $module_list
		return 1	
		;;
		-m | --module)
		selected_module="$2"
		case "$selected_module" in
			ib_core)
			my_flags=$ib_core_flags
			;;
			mlx5_mod)
			my_flags=$mlx5_mod_flags
			;;
			ib_ipoib)
			my_flags=$ib_ipoib_flags
			;;
			mlxfw)
			my_flags=$mlxfw_flags
			;;
			rxe)
			my_flags=$rxe_flags
			;;
			fpga)
			my_flags=$fpga_flags
			;;
			fpgaWithipsec)
			my_flags=$ipsec_flags
			;;
			*)
			echo "-E- Unsupported module: $selected_module" >&2
			return 1
			;;
		esac
		shift
		;;
		-h | --help)
		echo "Usage: ${script_name} [options]
			
	use this script to config docker environment.
	important: need to source this script for full functionality.

		-h, --help 		display this help message and exit
		--without-odp		ignore odp feature at configure
		-m, --module 		config environment for specific module [default module is ib_core]
		-l, --module-list	display available MODULEs and exit
"
		return 1
		;;
		*)
		echo "-E- Unsupported option: $1" >&2
		echo "use -h flag to display help menu" 
		return 1
		;;
	esac
	shift
done
if [ -z "$selected_module" ]
then
	my_flags=$ib_core_flags
fi	
if [ $without_odp -eq 1 ]; then
	my_flags="$my_flags --without-odp"
fi
echo "start docker build"
/builder/do_build --git /git-repo/ --rev HEAD --kver ${input_version} --ksrc /tmp/linux-${input_version}/ --packages="${my_flags}" 
cd /build/mlnx_ofed/
echo "installing vim"
yum -yq install vim
git config --global user.email "aaa@gmail.com" 
git add -u
git commit -s -m "Temp commit"
echo "inside $(pwd)"
echo "finished!"
echo "---------"
