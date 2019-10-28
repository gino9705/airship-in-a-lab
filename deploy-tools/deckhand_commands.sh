#!/bin/bash

set -x

# Images
KEYSTONE_IMAGE=${URL}/openstack/ocata/loci/mos/mos-keystone@sha256:1f5d2e8ea470f99e72ab09d46de81173f730878f3363ec9d0ae6d33a9fbcd117

USER_NAME=
USER_PASSWORD=
PROJECT_NAME=admin
REGION_NAME=RegionOne

TOKEN=`sudo docker run --rm --net=host -e OS_AUTH_URL=http://keystone-api.ucp.svc.cluster.local:80/v3 -e OS_PROJECT_DOMAIN_NAME=default -e OS_USER_DOMAIN_NAME=default -e OS_PROJECT_NAME=${PROJECT_NAME} -e OS_REGION_NAME=${REGION_NAME} -e OS_USERNAME=${USER_NAME} -e OS_PASSWORD=${USER_PASSWORD} -e OS_IDENTITY_API_VERSION=3 ${KEYSTONE_IMAGE} openstack token issue -f value -c id`

no_proxy=deckhand-int.ucp.svc.cluster.local curl -H "X-AUTH-TOKEN: $TOKEN" -H 'Content-Type: application/x-yaml' http://deckhand-int.ucp.svc.cluster.local:9000/api/v1.0/revisions/

