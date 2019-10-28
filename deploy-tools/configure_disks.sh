#!/bin/bash

set -x 

configure_disks() {
  echo -e "o\nn\np\n1\n\n\nw" | fdisk /dev/${1}  

  mkfs.xfs -L ${2} -f /dev/${1}1

  # need to figure out how to break this into more module
  mkdir -p /var/lib/ceph/${2}
  
  echo "/dev/${1}1 /var/lib/ceph/${2} xfs defaults 0 0" >> /etc/fstab
  mount -a
  df -lh | grep -i $2
}

configure_disks sdc journal
