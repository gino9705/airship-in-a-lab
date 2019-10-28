#!/bin/bash

export LAST_STEP_NAME='genesis'
export WORKSPACE='/root/deploy'
export TARGET_SITE='dev'
export PROXY=''
export NOPROXY='localhost,127.0.0.1,127.0.0.0/8,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12'

export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_DOMAIN_NAME=default
export OS_PROJECT_NAME=
export OS_USERNAME=
export OS_PASSWORD=
export OS_AUTH_URL=http://keystone.ucp.svc.cluster.local:80/v3

rm -rf ${WORKSPACE}/deployment_files
cp -R ${WORKSPACE}/airship-in-a-lab/example-deploy-files ${WORKSPACE}/deployment_files 
${WORKSPACE}/airship-in-a-lab/deploy-scripts/common/airship-deploy.sh

