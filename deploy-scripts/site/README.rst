
Airship Dev Site Installation Guide
==========================================================

* Create work space directory

   mkdir -p $HOME/deploy; cd $HOME/deploy

* Clone the deployment script

   git clone https://github.com/gino9705/airship-in-a-lab.git

* Modify the following script

   vi ./airship-in-a-lab/deploy-scripts/site/dev.sh
    export PROXY='{proxy_server}:8888’

* Modify the following YAML file
   vi ./airship-in-a-lab/example-deploy-files/site/dev/networks/common-addresses.yaml


   ip_autodetection_method: 'interface=enp0s8’

   upstream_servers:
         - {dns_server}
       upstream_servers_joined: {dns_server}

    genesis:
       hostname: ws1
       # K8s Network IP Address
       ip: 192.168.56.101

    proxy:
       http: http://{proxy_server}:3128
       https: http://{proxy_server}:3128

   ntp:
       servers_joined: {ntp_servers}

     storage:
       ceph:
         public_cidr: {storage_network}/24
         cluster_cidr: {storage_network}/24

* Modify the following YAML file
   vi ./airship-in-a-lab/example-deploy-files/site/dev/pki/pki-catalog.yaml
   %s/ws1/{host_name}/g
   %s/192.168.56.101/{ksn_network_ip_address}/g

* Modify the following YAML file
   vi ./airship-in-a-lab/example-deploy-files/site/dev/software/manifests/bootstrap.yaml

* Modify the following YAML file
   vi ./airship-in-a-lab/example-deploy-files/site/dev/software/manifests/full-site.yaml

* Modify the following YAML file
   vi ./airship-in-a-lab/example-deploy-files/global/v1.0/software/config/versions.yaml
   %s/127.0.0.1:3128/{proxy_dns}:{port}/g

* Run the following script
   bash ./airship-in-a-lab/deploy-scripts/site/dev.sh
