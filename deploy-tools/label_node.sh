#!/bin/bash

label_osh()
{
   kubectl label node $1 ceph-mds=enabled
   kubectl label node $1 ceph-mgr=enabled
   kubectl label node $1 ceph-rgw=enabled
   kubectl label node $1 openstack-control-plane=enabled
   kubectl label node $1 openstack-l3-agent=enabled
   kubectl label node $1 openvswitch=enabled
   kubectl label node $1 openstack-nova-compute=enabled
   kubectl label node $1 openstack-libvirt=kernel
   kubectl label node $1 sriov=enabled
}

label_infra()
{
   kubectl label node $1 ceph-mds=enabled
   kubectl label node $1 ceph-mgr=enabled
   kubectl label node $1 ceph-rgw=enabled
   kubectl label node $1 openstack-control-plane=enabled
   kubectl label node $1 node-exporter=enabled
}

label_k8s()
{
   kubectl label node $1 calico-etcd=enabled
   kubectl label node $1 kube-dns=enabled
   kubectl label node $1 kube-ingress=enabled
   kubectl label node $1 kubernetes-etcd=enabled
}

label_ucp()
{
   kubectl label node $1 ceph-mds=enabled
   kubectl label node $1 ceph-mgr=enabled
   kubectl label node $1 ceph-rgw=enabled
   kubectl label node $1 ceph-mon=enabled
   kubectl label node $1 ceph-osd=enabled
   kubectl label node $1 maas-control-plane=enabled
   kubectl label node $1 ucp-control-plane=enabled
}

label_all()
{
   kubectl label node $1 ceph-mds=enabled
   kubectl label node $1 ceph-mgr=enabled
   kubectl label node $1 ceph-mon=enabled
   kubectl label node $1 ceph-osd=enabled
   kubectl label node $1 ceph-rgw=enabled
   kubectl label node $1 calico-etcd=enabled
   kubectl label node $1 kube-dns=enabled
   kubectl label node $1 kube-ingress=enabled
   kubectl label node $1 kubernetes-etcd=enabled
   kubectl label node $1 maas-control-plane=enabled
   kubectl label node $1 node-exporter=enabled
   kubectl label node $1 openstack-control-plane=enabled
   kubectl label node $1 openstack-l3-agent=enabled
   kubectl label node $1 openstack-libvirt=kernel
   kubectl label node $1 openstack-nova-compute=enabled
   kubectl label node $1 openvswitch=enabled
   kubectl label node $1 sriov=enabled
   kubectl label node $1 ucp-control-plane=enabled
}

label_control()
{
   kubectl label node $1 ceph-mds=enabled
   kubectl label node $1 ceph-mgr=enabled
   kubectl label node $1 ceph-mon=enabled
   kubectl label node $1 ceph-osd=enabled
   kubectl label node $1 ceph-rgw=enabled
   kubectl label node $1 calico-etcd=enabled
   kubectl label node $1 kube-dns=enabled
   kubectl label node $1 kube-ingress=enabled
   kubectl label node $1 kubernetes-etcd=enabled
   kubectl label node $1 maas-control-plane=enabled
   kubectl label node $1 node-exporter=enabled
   kubectl label node $1 openstack-control-plane=enabled
   kubectl label node $1 openstack-l3-agent=enabled
   kubectl label node $1 openvswitch=enabled
   kubectl label node $1 ucp-control-plane=enabled
}


label_compute()
{
   kubectl label node $1 node-exporter=enabled
   kubectl label node $1 openstack-libvirt=kernel
   kubectl label node $1 openstack-nova-compute=enabled
   kubectl label node $1 openvswitch=enabled
   kubectl label node $1 sriov=enabled
}

label_control control 
label_compute worker

