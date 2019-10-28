#!/bin/bash

set -x

function set_proxy_env()
{
   p=http://{proxy.dns}:8888;
   export http_proxy=$p 
   export https_proxy=$p 
   export HTTP_PROXY=$p 
   export HTTPS_PROXY=$p 
}

function create_project()
{
  ./osapi.sh openstack project create david --domain default
  ./osapi.sh openstack role add --project david --user admin admin
}

function set_project_resource_limit()
{

  export OS_PROJECT_NAME=david
  project_id=$(./osapi.sh openstack quota show | grep "project" | grep -v "id" | awk -F "|" '{ print $3 }' | tr -d '[:space:]')
  echo $project_id

  ./osapi.sh openstack quota set --cores -1 ${project_id}
  ./osapi.sh openstack quota set --ram -1 ${project_id}
  ./osapi.sh openstack quota set --instances -1 ${project_id}
}

function configure_security_group()
{
  export OS_PROJECT_NAME=david

  ./osapi.sh openstack security group create david
  ./osapi.sh openstack security group rule create david --protocol tcp --dst-port 1:65535 --remote-ip 0.0.0.0/0
  ./osapi.sh openstack security group rule create david --protocol udp --dst-port 1:65535 --remote-ip 0.0.0.0/0
  ./osapi.sh openstack security group rule create --proto icmp david
}

function create_keypair()
{
  export OS_PROJECT_NAME=david

  mkdir -p ./files
  ./osapi.sh openstack keypair create heat-vm-key > ./files/id_rsa
  chmod 600 ./files/id_rsa
}

function create_image()
{
   export OS_PROJECT_NAME=david

   #wget http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img -O ./images/cirros-0.4.0-x86_64-disk.img
   #./osapi.sh glance image-create --name "Cirros0.3.5" --disk-format qcow2 --container-format bare --min-disk 20 --file /target/images/cirros-0.4.0-x86_64-disk.img --progress

   ./osapi.sh glance image-create --name "ubuntu1604" --disk-format qcow2 --container-format bare --min-disk 20 --file /target/images/xenial-server-cloudimg-amd64-disk1.img --progress
}

function execute_heat_stack()
{
   export OS_PROJECT_NAME=david

   ./osapi.sh openstack stack create -t /target/heat_templates/$1 $2
}

set_proxy_env
create_project
set_project_resource_limit
configure_security_group
create_keypair
create_image
#execute_heat_stack heat_sriovnet.yaml sriovnet
#execute_heat_stack heat_sriovvm.yaml sriovvm1
#execute_heat_stack heat_providernet.yaml providernet
execute_heat_stack heat_basic_vm.yaml basic_vm 
