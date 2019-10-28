p=http://{proxy.dns}:8888;
n=localhost,127.0.0.1,127.0.0.0/8,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,$(hostname -i),$ADDITIONAL_NO_PROXY,deckhand-int.ucp.svc.cluster.local,172.29.198.75;

export http_proxy=$p 
export https_proxy=$p 
export HTTP_PROXY=$p 
export HTTPS_PROXY=$p 
export no_proxy=$n 
export NO_PROXY=$n $@

echo $@
