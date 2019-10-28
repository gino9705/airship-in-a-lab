#!/bin/bash

set -x

LAST_STEP_NAME=${LAST_STEP_NAME:-'deploy'}
WORKSPACE=${WORKSPACE:-'/root/deploy'}
TARGET_SITE=${TARGET_SITE:-'dev'}

# Repositories
PEGLEG_REPO=${PEGLEG_REPO:-'https://git.openstack.org/openstack/airship-pegleg.git'}
PEGLEG_REFSPEC=${PEGLEG_REFSPEC:-''}
SHIPYARD_REPO=${SHIPYARD_REPO:-'https://git.openstack.org/openstack/airship-shipyard.git'}
SHIPYARD_REFSPEC=${SHIPYARD_REFSPEC:-''}

# Images
PEGLEG_IMAGE=${PEGLEG_IMAGE:-'quay.io/airshipit/pegleg:1ada48cc360ec52c7ab28b96c28a0c7df8bcee40'}
PROMENADE_IMAGE=${PROMENADE_IMAGE:-'quay.io/airshipit/promenade:latest'}

# Command shortcuts
PEGLEG=${WORKSPACE}/airship-pegleg/tools/pegleg.sh


if [[ ${LAST_STEP_NAME} == "collect" ]]; then
  STEP_BREAKPOINT=10
elif [[ ${LAST_STEP_NAME} == "genesis" ]]; then
  STEP_BREAKPOINT=20
elif [[ ${LAST_STEP_NAME} == "deploy" ]]; then
  STEP_BREAKPOINT=30
elif [[ ${LAST_STEP_NAME} == "setup" ]]; then
  STEP_BREAKPOINT=40
else
  STEP_BREAKPOINT=20
fi

function clean_env() {
  ${WORKSPACE}/airship-in-a-lab/deploy-tools/cleanup.sh
  ${WORKSPACE}/airship-in-a-lab/deploy-tools/wipe-disks.sh
}

function setup_proxy() {
  # if proxy setting is empty. Set up the squid proxy server. 
  if [[ -z "$PROXY" ]]
  then
    HOST_IFACE=$(ip route | grep "^default" | head -1 | awk '{ print $5 }')
    IPADDR=$(ip addr | awk "/inet/ && /${HOST_IFACE}/{sub(/\/.*$/,\"\",\$2); print \$2}")

    PROXY=http://${IPADDR}:3128
    RESTART=0

    apt-get install squid3

    if [[ -z $(grep "acl all src 0.0.0.0/0" /etc/squid/squid.conf) ]]
    then
      RESTART=1
      echo "acl all src 0.0.0.0/0" >> /etc/squid/squid.conf
    fi

    if [[ -z $(grep "http_access allow all" /etc/squid/squid.conf) ]]
    then
      RESTART=1
      echo "http_access allow all" >> /etc/squid/squid.conf
    fi

    if [[ $(grep "http_access deny all" /etc/squid/squid.conf) ]]
    then
      RESTART=1
      sed -i 's/.*http_access deny all.*/#This line is removed by the deploy script./' /etc/squid/squid.conf
    fi

    # taking a while to restart; therefore adding a checker 
    if ! [[ $RESTART = 0 ]]
    then
      systemctl restart squid
      sleep 10
    fi
  fi

  export http_proxy=$PROXY 
  export https_proxy=$PROXY
  export HTTP_PROXY=$PROXY 
  export HTTPS_PROXY=$PROXY
  export no_proxy=$NOPROXY
  export NO_PROXY=$NOPROXY

  # set up the proxy setting for Docker daemon
  mkdir -p /etc/systemd/system/docker.service.d

cat <<EOF > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=${PROXY}"
EOF

cat <<EOF > /etc/systemd/system/docker.service.d/https-proxy.conf
[Service]
Environment="HTTPS_PROXY=${PROXY}"
EOF
}

function setup_workspace() {
  # Setup workspace directories
  mkdir -p ${WORKSPACE}/collected
  mkdir -p ${WORKSPACE}/genesis

  # Open permissions for output from Promenade
  chmod -R 777 ${WORKSPACE}/collected
  chmod -R 777 ${WORKSPACE}/genesis
}

function get_repo() {
  # Setup a repository in the workspace
  #
  # $1 = name of directory the repo will clone to
  # $2 = repository url
  # $3 = refspec of repo pull
  cd ${WORKSPACE}
  if [ ! -d "$1" ] ; then
    git clone $2
    if [ -n "$3" ] ; then
      cd $1
      git pull $2 $3
      cd ..
    fi
  fi
}

function setup_repos() {
  # Get pegleg for the script only. Image is separately referenced.
  get_repo pegleg ${PEGLEG_REPO} ${PEGLEG_REFSPEC}
  
  # Get Shipyard for use after genesis
  get_repo shipyard ${SHIPYARD_REPO} ${SHIPYARD_REFSPEC}
}


function install_dependencies() {

apt-key add - <<"ENDKEY"
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBFWln24BEADrBl5p99uKh8+rpvqJ48u4eTtjeXAWbslJotmC/CakbNSqOb9o
ddfzRvGVeJVERt/Q/mlvEqgnyTQy+e6oEYN2Y2kqXceUhXagThnqCoxcEJ3+KM4R
mYdoe/BJ/J/6rHOjq7Omk24z2qB3RU1uAv57iY5VGw5p45uZB4C4pNNsBJXoCvPn
TGAs/7IrekFZDDgVraPx/hdiwopQ8NltSfZCyu/jPpWFK28TR8yfVlzYFwibj5WK
dHM7ZTqlA1tHIG+agyPf3Rae0jPMsHR6q+arXVwMccyOi+ULU0z8mHUJ3iEMIrpT
X+80KaN/ZjibfsBOCjcfiJSB/acn4nxQQgNZigna32velafhQivsNREFeJpzENiG
HOoyC6qVeOgKrRiKxzymj0FIMLru/iFF5pSWcBQB7PYlt8J0G80lAcPr6VCiN+4c
NKv03SdvA69dCOj79PuO9IIvQsJXsSq96HB+TeEmmL+xSdpGtGdCJHHM1fDeCqkZ
hT+RtBGQL2SEdWjxbF43oQopocT8cHvyX6Zaltn0svoGs+wX3Z/H6/8P5anog43U
65c0A+64Jj00rNDr8j31izhtQMRo892kGeQAaaxg4Pz6HnS7hRC+cOMHUU4HA7iM
zHrouAdYeTZeZEQOA7SxtCME9ZnGwe2grxPXh/U/80WJGkzLFNcTKdv+rwARAQAB
tDdEb2NrZXIgUmVsZWFzZSBUb29sIChyZWxlYXNlZG9ja2VyKSA8ZG9ja2VyQGRv
Y2tlci5jb20+iQI4BBMBAgAiBQJVpZ9uAhsvBgsJCAcDAgYVCAIJCgsEFgIDAQIe
AQIXgAAKCRD3YiFXLFJgnbRfEAC9Uai7Rv20QIDlDogRzd+Vebg4ahyoUdj0CH+n
Ak40RIoq6G26u1e+sdgjpCa8jF6vrx+smpgd1HeJdmpahUX0XN3X9f9qU9oj9A4I
1WDalRWJh+tP5WNv2ySy6AwcP9QnjuBMRTnTK27pk1sEMg9oJHK5p+ts8hlSC4Sl
uyMKH5NMVy9c+A9yqq9NF6M6d6/ehKfBFFLG9BX+XLBATvf1ZemGVHQusCQebTGv
0C0V9yqtdPdRWVIEhHxyNHATaVYOafTj/EF0lDxLl6zDT6trRV5n9F1VCEh4Aal8
L5MxVPcIZVO7NHT2EkQgn8CvWjV3oKl2GopZF8V4XdJRl90U/WDv/6cmfI08GkzD
YBHhS8ULWRFwGKobsSTyIvnbk4NtKdnTGyTJCQ8+6i52s+C54PiNgfj2ieNn6oOR
7d+bNCcG1CdOYY+ZXVOcsjl73UYvtJrO0Rl/NpYERkZ5d/tzw4jZ6FCXgggA/Zxc
jk6Y1ZvIm8Mt8wLRFH9Nww+FVsCtaCXJLP8DlJLASMD9rl5QS9Ku3u7ZNrr5HWXP
HXITX660jglyshch6CWeiUATqjIAzkEQom/kEnOrvJAtkypRJ59vYQOedZ1sFVEL
MXg2UCkD/FwojfnVtjzYaTCeGwFQeqzHmM241iuOmBYPeyTY5veF49aBJA1gEJOQ
TvBR8Q==
=Fm3p
-----END PGP PUBLIC KEY BLOCK-----
ENDKEY

  echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ceph-common=10.2.10-0ubuntu0.16.04.1 docker-engine=1.13.1-0~ubuntu-xenial socat=1.7.3.1-1 
}

function run_pegleg_collect() {
  cd ${WORKSPACE}
  # Runs pegleg collect to get the documents combined
  IMAGE=${PEGLEG_IMAGE} ${PEGLEG} site -p /workspace/deployment_files collect ${TARGET_SITE} -s /workspace/collected
}

function generate_certs() {
  # Only generate certificate file if it doesn't exist
  if [ ! -f ${WORKSPACE}/deployment_files/site/${TARGET_SITE}/secrets/certificates/certificates.yaml ]; then
    docker run --rm -t \
        -e http_proxy=$PROXY \
        -e https_proxy=$PROXY \
        -w /target \
        -e PROMENADE_DEBUG=false \
        -v ${WORKSPACE}/collected:/target \
        ${PROMENADE_IMAGE} \
            promenade \
                generate-certs \
                    -o /target \
                    $(ls ${WORKSPACE}/collected)
  fi
}

function lint_design() {
  # After the certificates are in the deployment files run a pegleg lint
  IMAGE=${PEGLEG_IMAGE} ${PEGLEG} lint -p /workspace/deployment_files
}

function generate_genesis() {
  # Copy the collected yamls into the target for the certs
  cp "${WORKSPACE}/collected"/*.yaml ${WORKSPACE}/genesis

  # Generate the genesis scripts
  docker run --rm -t \
      -e http_proxy=$PROXY \
      -e https_proxy=$PROXY \
      -w /target \
      -e PROMENADE_DEBUG=false \
      -v ${WORKSPACE}/genesis:/target \
      ${PROMENADE_IMAGE} \
          promenade \
              build-all \
                  -o /target \
                  --validators \
                  $(ls ${WORKSPACE}/genesis)
}

function run_genesis() {
  # Runs the genesis script that was generated
  ${WORKSPACE}/genesis/genesis.sh
}

function validate_genesis() {
  # Vaidates the genesis deployment
  ${WORKSPACE}/genesis/validate-genesis.sh
}

function genesis_complete() {
  # Setup kubeconfig
  if [ ! -d "$HOME/.kube" ] ; then
    mkdir ~/.kube
  fi
  cp /etc/kubernetes/admin/kubeconfig.yaml $HOME/.kube/config
  chown $(id -u):$(id -g) $HOME/.kube/config
}

function execute_deploy_site() {
  cd ${WORKSPACE}/airship-shipyard/tools/

  ./run_shipyard.sh create configdocs design --filename=/home/shipyard/host/aic-clcp-manifests.yaml
  #./run_shipyard.sh create configdocs secrets --filename=/home/shipyard/host/certificates.yaml --append
  #./run_shipyard.sh commit configdocs

  ## set variables used in execute_shipyard_action.sh
  #export max_shipyard_count=${max_shipyard_count:-60}
  #export shipyard_query_time=${shipyard_query_time:-90}

  ## monitor the execution of deploy_site
  #bash execute_shipyard_action.sh 'deploy_site'
}

function clean() {
  # Perform any cleanup of temporary or unused artifacts
  set +x
  echo "To remove files generated during this script's execution, delete ${WORKSPACE}."
  set -x
}

function error() {
  # Processes errors
  set +x
  echo "Error when $1."
  set -x
  exit 1
}

trap clean EXIT


# 1. Destroying the existing environment 
clean_env || error "Unable to destroy environment"

# 2. Common steps for all breakpoints specified
setup_proxy || error "setting up the proxy"
setup_workspace || error "setting up workspace directories"
setup_repos || error "setting up Git repos"
install_dependencies || error "installing dependencies"

# 3. collect
if [[ ${STEP_BREAKPOINT} -ge 10 ]]; then
  run_pegleg_collect || error "running pegleg collect"
fi

# 4. genesis
if [[ ${STEP_BREAKPOINT} -ge 20 ]]; then
  generate_certs || error "setting up certs with Promenade"
  #lint_design || error "linting the design"
  generate_genesis || error "generating genesis"
  run_genesis || error "running genesis"
  validate_genesis || error "validating genesis"
  genesis_complete || error "printing out some info about next steps"
fi

## 5. deploy
#if [[ ${STEP_BREAKPOINT} -ge 30 ]]; then
#  execute_deploy_site || error "executing deploy_site from the /site directory"
#fi
#
## 6. setup
#if [[ ${STEP_BREAKPOINT} -ge 40 ]]; then
#  execute_setup_site|| error "setting up the site"
#fi

