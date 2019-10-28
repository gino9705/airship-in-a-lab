#!/bin/bash

sudo echo "deb http://linux.dell.com/repo/community/ubuntu $(cat /etc/apt/sources.list | grep '^deb' | head -1 | cut -d' ' -f3) openmanage" | sudo tee -a /etc/apt/sources.list.d/linux.dell.com.sources.list
if [ -n "$PROXY" ]; then
   export KEYSERVER_PROXY="--keyserver-options http-proxy=$PROXY"
   sudo sh -c "echo 'Acquire::http::Proxy \"$PROXY\";
   Acquire::https::Proxy \"$PROXY\";' > /etc/apt/apt.conf.d/20-proxy"
fi
sudo gpg --keyserver pool.sks-keyservers.net $KEYSERVER_PROXY --recv-key 1285491434D8786F
sudo gpg -a --export 1285491434D8786F | sudo apt-key add -
sudo apt update
sudo apt -y install srvadmin-all
