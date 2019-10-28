#!/bin/bash

armada apply --target-manifest full-site /etc/genesis/armada/assets/manifest.yaml

#export ARMADA_IMAGE=quay.io/airshipit/armada
#docker run -t -v ~/.kube:/armada/.kube -v ${WORKSPACE}/site:/target --net=host \${ARMADA_IMAGE} apply /target/your-yaml.yaml"

