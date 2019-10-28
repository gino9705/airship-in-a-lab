#!/bin/bash

set -x

export WORKSPACE=
export TARGET_SITE=
export USER_NAME=
export USER_PASSWORD=
export PROJECT_NAME=
export REGION_NAME=

# Images
KEYSTONE_ENDPOINT=${KEYSTONE_ENDPOINT:-"http://keystone.ucp.svc.cluster.local:80/v3"}
SHIPYARD_IMAGE=${SHIPYARD_IMAGE:-"quay.io/airshipit/shipyard:66da23cb20c545bf82e7d1aec321edf9ebc06cac"}

clean_configdocs(){
   # clean site YAMLs from Deckhand
   TOKEN=`sudo docker run --rm --net=host -e OS_AUTH_URL=${KEYSTONE_ENDPOINT} -e OS_PROJECT_DOMAIN_NAME=default -e OS_USER_DOMAIN_NAME=default -e OS_PROJECT_NAME=${PROJECT_NAME} -e OS_REGION_NAME=${REGION_NAME} -e OS_USERNAME=${USER_NAME} -e OS_PASSWORD=${USER_PASSWORD} -e OS_IDENTITY_API_VERSION=3 ${KEYSTONE_ENDPOINT} openstack token issue -f value -c id`

   curl -v -X DELETE -H "X-AUTH-TOKEN: $TOKEN" -H 'Content-Type: application/x-yaml' http://deckhand-int.ucp.svc.cluster.local:9000/api/v1.0/revisions
}

run_nginx(){
   # setup nginx for promenade joins (workaround)
   sudo docker kill prom-nginx
   sudo docker rm prom-nginx

   sudo docker run -d --name prom-nginx -v $(pwd)/configs/promenade-bundle:/usr/share/nginx/html -p 6880:80 nginx
}

create_configdocs(){
  sudo docker run -v ${WORKSPACE}:/target -e OS_AUTH_URL=${KEYSTONE_ENDPOINT} -e OS_PASSWORD=${USER_PASSWORD} -e 'OS_PROJECT_DOMAIN_NAME=default' -e OS_PROJECT_NAME=${PROJECT_NAME} -e OS_USERNAME=${USER_NAME} -e OS_USER_DOMAIN_NAME=default -e OS_IDENTITY_API_VERSION=3 --rm --net=host ${SHIPYARD_IMAGE} create configdocs ${TARGET_SITE} --replace --directory=/target/collected

  sleep 5
}

commit_configdocs(){
  sudo docker run -v ${WORKSPACE}:/target -e OS_AUTH_URL=${KEYSTONE_ENDPOINT} -e OS_PASSWORD=${USER_PASSWORD} -e OS_PROJECT_DOMAIN_NAME=default -e OS_PROJECT_NAME=${PROJECT_NAME} -e OS_USERNAME=${USER_NAME} -e OS_USER_DOMAIN_NAME=default -e OS_IDENTITY_API_VERSION=3 --rm --net=host ${SHIPYARD_IMAGE} commit configdocs

  sleep 5
}

deploy_site(){
  sudo docker run -e OS_AUTH_URL=${KEYSTONE_ENDPOINT} -e OS_PASSWORD=${USER_PASSWORD} -e OS_PROJECT_DOMAIN_NAME=default -e OS_PROJECT_NAME=${PROJECT_NAME} -e OS_USERNAME=${USER_NAME} -e OS_USER_DOMAIN_NAME=default -e OS_IDENTITY_API_VERSION=3 --rm --net=host ${SHIPYARD_IMAGE} create action deploy_site
}

#clean_configdocs
create_configdocs
commit_configdocs
#run_nginx
deploy_site

