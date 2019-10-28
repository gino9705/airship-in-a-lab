#!/bin/sh

set -x

OS_USERNAME=admin
OS_PASSWORD=password
OS_PROJECT_NAME=${OS_PROJECT_NAME:-"admin"}
OS_REGION_NAME=${OS_REGION_NAME:-"RegionOne"}
KEYSTONE_ENDPOINT=${KEYSTONE_ENDPOINT:-"http://keystone.openstack.svc.cluster.local:80/v3"}
HEAT_DOCKER_IMAGE=${HEAT_DOCKER_IMAGE:-"docker.io/openstackhelm/heat:ocata"}

docker run --user 0 --net=host -it -v $(pwd):/target \
--dns-search=svc.cluster.local \
-e OS_USERNAME=${OS_USERNAME} \
-e OS_PASSWORD=${OS_PASSWORD} \
-e OS_PROJECT_NAME=${OS_PROJECT_NAME} \
-e OS_REGION_NAME=${OS_REGION_NAME} \
-e OS_USER_DOMAIN_NAME=default \
-e OS_PROJECT_DOMAIN_NAME=default \
-e OS_AUTH_URL=${KEYSTONE_ENDPOINT} \
-e OS_IDENTITY_API_VERSION=3 \
-e OS_ENDPOINT_TYPE=internal \
-u root \
${HEAT_DOCKER_IMAGE} \
$@
