#!/bin/bash -e

backports_dir=$1; shift
mod=$1; shift

###########################################################################
paths_of_module__ib_core="drivers/infiniband/core \
			include/rdma/ib_ \
			block/blk-mq-rdma.c"
ignore_paths_of_module__ib_core=""

paths_of_module__mlx5_core="drivers/net/ethernet/mellanox/mlx5/core/ \
			include/linux/mlx5"
ignore_paths_of_module__mlx5_core="en_|ipoib|eswitch"

paths_of_module__mlx5_core_en="drivers/net/ethernet/mellanox/mlx5/core/en_"
ignore_paths_of_module__mlx5_core_en=""

paths_of_module__mlx5_core_switch="drivers/net/ethernet/mellanox/mlx5/core/eswitch"
ignore_paths_of_module__mlx5_core_switch=""

paths_of_module__mlx5_ib="drivers/infiniband/hw/mlx5/"
ignore_paths_of_module__mlx5_ib=""

paths_of_module__mlx5_core_IPoIB="drivers/net/ethernet/mellanox/mlx5/core/ipoib"
ignore_paths_of_module__mlx5_core_IPoIB=""

paths_of_module__mlx5_all="${paths_of_module__mlx5_core} \
			   ${paths_of_module__mlx5_core_en} \
			   ${paths_of_module__mlx5_core_switch} \
			   ${paths_of_module__mlx5_ib} \
			   ${paths_of_module__mlx5_core_IPoIB}"

paths_of_module__mlx4_core="drivers/net/ethernet/mellanox/mlx4/ \
			include/linux/mlx4/"
ignore_paths_of_module__mlx4_core="en_"

paths_of_module__mlx4_ib="drivers/infiniband/hw/mlx4/"
ignore_paths_of_module__mlx4_ib=""

paths_of_module__mlx4_en="drivers/net/ethernet/mellanox/mlx4/en_ \
			drivers/net/ethernet/mellanox/mlx4/mlx4_en.h"
ignore_paths_of_module__mlx4_en=""

paths_of_module__mlx4_all="${paths_of_module__mlx4_core} \
			   ${paths_of_module__mlx4_ib} \
			   ${paths_of_module__mlx4_en}"

paths_of_module__rdma_rxe="drivers/infiniband/sw/rxe/"
ignore_paths_of_module__rdma_rxe=""

paths_of_module__ib_srp="drivers/infiniband/ulp/srp/ \
			drivers/scsi/scsi_transport_srp.c \
			drivers/scsi/scsi_priv.h"
ignore_paths_of_module__ib_srp=""

paths_of_module__ib_iser="drivers/infiniband/ulp/iser/"
ignore_paths_of_module__ib_iser=""

paths_of_module__ib_isert="drivers/infiniband/ulp/isert/ \
			include/target/iscsi/"
ignore_paths_of_module__ib_isert=""

paths_of_module__ib_ipoib="drivers/infiniband/ulp/ipoib"
ignore_paths_of_module__ib_ipoib=""

paths_of_module__nvme="drivers/nvme/host/ \
		       drivers/nvme/target/ \
		       block/blk-mq-rdma.c \
		       include/linux/nvme \
		       include/linux/blk-mq-rdma.h"
ignore_paths_of_module__nvme=""

paths_of_module__mlxfw="drivers/net/ethernet/mellanox/mlxfw/"
ignore_paths_of_module__mlxfw=""

paths_of_module__rxe="drivers/infiniband/sw/rxe/"
ignore_paths_of_module__rxe=""

paths_of_module__eth_ipoib="drivers/net/eipoib/"
ignore_paths_of_module__eth_ipoib=""

###########################################################################
rel_paths=$(eval echo \$paths_of_module__${mod})
ignore_paths=$(eval echo \$ignore_paths_of_module__${mod})

if [ "X$rel_paths" == "X" ]; then
	echo "nothing defined in the script for '$mod'" >&2
	exit 1
fi

rel_patches=
for cur_path in $rel_paths
do
	for pp in $(grep -rl $cur_path $backports_dir)
	do
		if [ "X$ignore_paths" != "X" ]; then
			if (echo "$pp" | grep -qiE "$ignore_paths"); then
				continue
			fi
		fi
		if ! (echo -e "$rel_patches" | grep -wq $pp); then
			rel_patches="$pp\n$rel_patches"
		fi
	done
done

echo -e  "$rel_patches" | grep -v "^$" | sort
