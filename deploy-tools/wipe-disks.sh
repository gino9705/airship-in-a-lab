#!/bin/bash

set -x

read -p "Do you want to wipe out the disksr? (y/n)" REPLY
if [ "$REPLY" = "n" ]; then
  exit 0
fi

function wipe_disks()
{
  for var in "$@"
  do
    echo "wiping disk ${var}"
    dd bs=512 count=1 if=/dev/urandom of=/dev/dd bs=512 count=1 if=/dev/urandom of=/dev/${var}
  done
}

wipe_disks sdd sde sdf sdg sdh sdi
