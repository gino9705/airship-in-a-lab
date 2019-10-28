#!/bin/bash

set -x

add_admin_user()
{
  useradd -d /home/${1} -m ${1}
  sudo echo "${1} ALL = (root) NOPASSWD:ALL" > /etc/sudoers.d/${1}
  chmod 0440 /etc/sudoers.d/${1}
  usermod -s /bin/bash ${1}
  passwd ${1}
}

add_admin_user ccpadmin
