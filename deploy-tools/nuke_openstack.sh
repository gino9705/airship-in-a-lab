#!/bin/bash

set -x

read -p "Do you want to wipe out the OpenStack environment? (y/n)" REPLY
if [ "$REPLY" = "n" ]; then
  exit 0
fi

kubectl delete namespace openstack

kubectl delete configmap -n kube-system clcp-cinder.v1
kubectl delete configmap -n kube-system clcp-cinder-rabbitmq.v1
kubectl delete configmap -n kube-system clcp-glance.v1
kubectl delete configmap -n kube-system clcp-glance-rabbitmq.v1
kubectl delete configmap -n kube-system clcp-heat.v1
kubectl delete configmap -n kube-system clcp-heat-rabbitmq.v1
kubectl delete configmap -n kube-system clcp-horizon.v1
kubectl delete configmap -n kube-system clcp-keystone.v1
kubectl delete configmap -n kube-system clcp-keystone-rabbitmq.v1
kubectl delete configmap -n kube-system clcp-libvirt.v1
kubectl delete configmap -n kube-system clcp-neutron.v1
kubectl delete configmap -n kube-system clcp-neutron-rabbitmq.v1
kubectl delete configmap -n kube-system clcp-nova.v1
kubectl delete configmap -n kube-system clcp-nova-rabbitmq.v1
kubectl delete configmap -n kube-system clcp-openstack-ceph-config.v1
kubectl delete configmap -n kube-system clcp-openstack-ingress-controller.v1
kubectl delete configmap -n kube-system clcp-openstack-mariadb.v1
kubectl delete configmap -n kube-system clcp-openstack-memcached.v1
kubectl delete configmap -n kube-system clcp-openvswitch.v1
kubectl delete configmap -n kube-system clcp-osh-helm-toolkit.v1
kubectl delete configmap -n kube-system clcp-radosgw.v1

kubectl get clusterroles | egrep -i openstack | awk '{ print $1 }' | xargs -I {} kubectl delete clusterroles -n openstack {}

kubectl get clusterrolebindings | egrep -i openstack | awk '{ print $1 }' | xargs -I {} kubectl delete clusterrolebindings -n openstack {}

kubectl get serviceaccounts --all-namespaces | egrep -i ^openstack | awk '{ print $2 }' | xargs -I {} kubectl delete serviceaccounts -n openstack {}

kubectl get configmaps --all-namespaces | egrep -i ^openstack | awk '{ print $2 }' | xargs -I {} kubectl delete configmaps -n openstack {}

kubectl get role --all-namespaces | egrep -i ^openstack | awk '{ print $2 }' | xargs -I {} kubectl delete role -n openstack {}

kubectl get rolebindings --all-namespaces | egrep -i ^openstack | awk '{ print $2 }' | xargs -I {} kubectl delete rolebindings -n openstack {}

#pod
#service
#deployment
#replicaset
#job
#cronjob
#statefulset
