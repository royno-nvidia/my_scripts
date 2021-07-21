#!/bin/bash
#----------------SCRIPT VARIABLES--------------------#
input_version=$(ls -a /tmp/ | grep linux | sed -e 's/linux-//')
ib_core_flags="--with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod --with-memtrack --with-mdev-mod"
mlx5_mod_flags="--with-memtrack --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod  --with-mlx5-mod --with-mdev-mod"
ib_ipoib_flags="--with-memtrack --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod  --with-mlx5-mod --with-ipoib-mod --with-mdev-mod"
mlxfw_flags="--with-memtrack --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod  --with-mlx5-mod --with-mlxfw-mod --with-mdev-mod"
fpga_flags="--with-memtrack --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod  --with-mlx5-mod --with-innova-flex"
ipsec_flags="--with-memtrack --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod  --with-mlx5-mod --with-innova-flex --with-innova-ipsec"
all_flags="--with-memtrack --with-core-mod --with-user_mad-mod --with-user_access-mod --with-addr_trans-mod --with-mlx5-mod --with-ipoib-mod --with-mlxfw-mod --with-srp-mod --with-iser-mod --with-isert-mod --with-nvmf_host-mod --with-nvmf_target-mod --with-gds --with-mdev-mod --with-nfsrdma-mod --with-mlxdevm-mod --with-mlx5-ipsec"
my_flags=""
script_name="init_docker"
selected_module=""
without_odp=0
build_dir="do_build3"
module_list="
'ib_core'\n'mlx5_mod'\n'ib_ipoib'\n'mlxfw'\n'rxe'\nfpga\nfpga_with_ipsec\n'all'\n'custom'\n
"
#--------------------------MAIN-----------------------#
MY_BRANCH=$(cat /git-repo/HEAD | sed -e 's/.*heads\///')
if [[ $MY_BRANCH == "backport"* ]]; then
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
			fpga)
			my_flags=$fpga_flags
			;;
			fpga_with_ipsec)
			my_flags=$ipsec_flags
			;;
			all)
			my_flags=$all_flags
			;;
			custom)
			my_flags=$(echo $3 | sed 's/--package=//g')
			shift
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
					[custom example: -m custom "--package=--with-core-mod --package=--with-user_mad-mod --package=--with-user_access-mod --package=--with-addr_trans-mod --package=--with-memtrack"]
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
echo "compile flags: $my_flags"
echo "start docker build"
major=$(echo $input_version | sed -e 's/linux-//g' | cut -d"." -f1)
minor=$(echo $input_version | sed -e 's/linux-//g' | sed -e 's/-.*//g' |cut -d"." -f2)
build_dir="$(ls -1 | grep do_)"
/builder/${build_dir} --git /git-repo/ --rev HEAD --kver ${input_version} --ksrc /tmp/linux-${input_version}/ --package="${my_flags}" --check-warnings
cd /build/mlnx_ofed/
echo "installing vim"
yum -yq install vim
yum -yq install ctags
ctags -R .
git config --global user.email "aaa@gmail.com"
git add -u
git commit -s -m "Temp commit"
echo "inside $(pwd)"
echo "finished!"
echo "---------"
