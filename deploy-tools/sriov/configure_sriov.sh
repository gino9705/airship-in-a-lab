#!/bin/bash

set -x

function init_sriov()
{
  for var in "$@"
  do
    nic=${var%%:*}
    num_vfs=${var#*:}

    echo "Configuring $nic with $num_vfs VFs"
    if [[ $nic = $num_vfs ]]; then
      echo 0 > /sys/class/net/${nic}/device/sriov_numvfs
      NUM_VFS=$(cat /sys/class/net/${nic}/device/sriov_totalvfs)
      echo "${NUM_VFS}" > /sys/class/net/${nic}/device/sriov_numvfs
    else
      echo 0 > /sys/class/net/${nic}/device/sriov_numvfs
      echo "${num_vfs}" > /sys/class/net/${nic}/device/sriov_numvfs
    fi

    ip link set ${nic} up
    ip link show ${nic}
  done
}

function set_promisc()
{
  for var in "$@"
  do
    echo "Configuring promisc on ${var}"
    ip link set ${var} promisc on
    # get the bus that the port is on
    NIC_BUS=$(lshw -c network -businfo | awk '/${var}/ {print $1}')
    # get first port on the nic
    NIC_FIRST_PORT=$(lshw -c network -businfo | awk "/${NIC_BUS%%.*}/ { print \$2; exit }")
    echo $NIC_FIRST_PORT
    # enable promisc mode on the nic, by setting it for the 1st port
    ethtool --set-priv-flags ${NIC_FIRST_PORT} vf-true-promisc-support on
  done
}

init_sriov enp131s0f0:32 enp4s0f1:32
#set_promisc enp131s0f0 enp3s0f1
 
