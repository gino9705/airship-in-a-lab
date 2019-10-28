#!/bin/bash

function get_nic_info()
{
  for var in "$@"
  do
    printf "NIC ${var} Vendoer ID is"
    cat /sys/class/net/${var}/device/vendor
    printf "NIC ${var} Device ID is"
    cat /sys/class/net/${var}/device/device
  done
}

get_vendor_id enp131s0f0 enp3s0f1
