#!/bin/bash

set -x

export TARGET_SITE='mtn21'
export LAST_STEP_NAME='genesis'
export WORKSPACE='/root/js424h/deploy'
export PROXY='http://{proxy.dns}:8888'
export NOPROXY='localhost,127.0.0.1,127.0.0.0/8,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12'

rm -rf ${WORKSPACE}/deployment_files
mkdir -p ${WORKSPACE}/deployment_files
cp -r ${WORKSPACE}/../aic-clcp-manifests/{global,type} ${WORKSPACE}/deployment_files
cp -r ${WORKSPACE}/../aic-clcp-lab-manifests/site ${WORKSPACE}/deployment_files
cp -r ${WORKSPACE}/../aic-clcp-security-manifests/site/${TARGET_SITE}/secrets ${WORKSPACE}/deployment_files/site/${TARGET_SITE}

${WORKSPACE}/airship-in-a-lab/deploy-scripts/common/airship-deploy.sh

