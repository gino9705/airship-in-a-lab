#!/bin/bash

change_endpoint(){
   ENDPOINT=`./osapi.sh openstack endpoint list | grep -i $1 | grep -iv heat-cfn | grep -i -m1 internal | awk -F "|" '{ print $8 }' | tr -d ' '`
   UUID=`./osapi.sh openstack endpoint list | grep -i $1 | grep -i -m1 public | awk -F "|" '{ print $2 }' | tr -d ' '`

   echo "### Endpoint: "$ENDPOINT
   echo "### UUID: "$UUID
   ./osapi.sh openstack endpoint set --url "${ENDPOINT}" ${UUID}
}

change_endpoint nova 
change_endpoint neutron
change_endpoint glance
change_endpoint heat
change_endpoint cinder
change_endpoint placement
kubectl get pods -n openstack | grep -i nova-compute | awk '{ print $1 }' | xargs -I {} kubectl delete pod -n openstack {}
#kubectl exec -it nova-placement-api-558b94c448-kbm9c -n openstack -- nova-status upgrade check
