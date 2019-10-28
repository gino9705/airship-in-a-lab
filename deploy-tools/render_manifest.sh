#!/bin/bash

set -x

set_env_var()
{
   export WORKSPACE=/root/js424h/deploy
   export TARGET_SITE=mtn15b.2
   export PEGLEG_IMAGE=quay.io/airshipit/pegleg:1ada48cc360ec52c7ab28b96c28a0c7df8bcee40
   export PEGLEG=${WORKSPACE}/airship-pegleg/tools/pegleg.sh
   export PROXY=http://{proxy.dns}:8888
}

function setproxy()
{ 
   n=localhost,127.0.0.1,127.0.0.0/8,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,$(hostname -i),$ADDITIONAL_NO_PROXY,deckhand-int.ucp.svc.cluster.local,172.29.198.75;
   
   export http_proxy=$PROXY 
   export https_proxy=$PROXY
   export HTTP_PROXY=$PROXY
   export HTTPS_PROXY=$PROXY
   export no_proxy=$n 
   export NO_PROXY=$n
}

get_pegleg()
{
   cd ${WORKSPACE}
   git clone https://git.openstack.org/openstack/airship-pegleg.git
}

prep_env()
{
   if [[ ${TARGET_SITE} == "dev" ]]; then
      rm -rf ${WORKSPACE}/deployment_files
      cp -R ./airship-in-a-lab/example-deploy-files ./deployment_files
   else
      rm -rf ${WORKSPACE}/deployment_files
      mkdir -p ${WORKSPACE}/deployment_files
      cp -r ${WORKSPACE}/../aic-clcp-manifests/{global,type} ${WORKSPACE}/deployment_files
      cp -r ${WORKSPACE}/../aic-clcp-lab-manifests/site ${WORKSPACE}/deployment_files
      cp -r ${WORKSPACE}/../aic-clcp-security-manifests/site/${TARGET_SITE}/secrets ${WORKSPACE}/deployment_files/site/${TARGET_SITE}
   fi
}

render_manifest()
{
   IMAGE=${PEGLEG_IMAGE} ${PEGLEG} site -p ./deployment_files render ${TARGET_SITE} -o ./manifest.yaml 
   mv /etc/genesis/armada/assets/manifest.yaml /etc/genesis/armada/assets/$(date +%Y%m%d%H%M%S)_manifest.yaml
   mv ./manifest.yaml /etc/genesis/armada/assets/manifest.yaml
}

set_env_var
setproxy
get_pegleg
prep_env
render_manifest

