#!/bin/bash

ETCD_VER=v3.2.14
GOOGLE_URL=https://storage.googleapis.com/etcd
GITHUB_URL=https://github.com/coreos/etcd/releases/download
DOWNLOAD_URL=${GOOGLE_URL}

rm -f /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
rm -rf /tmp/etcd-download-test && mkdir -p /tmp/etcd-download-test
curl -L ${DOWNLOAD_URL}/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz
tar xzvf /tmp/etcd-${ETCD_VER}-linux-amd64.tar.gz -C /tmp/etcd-download-test --strip-components=1

chmod +x /tmp/etcd-download-test/etcd
cp /tmp/etcd-download-test/etcd /usr/local/bin/etcd

chmod +x /tmp/etcd-download-test/etcdctl
cp /tmp/etcd-download-test/etcdctl /usr/local/bin/etcdctl

