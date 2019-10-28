#!/bin/bash

HOST_IFACE=$(ip route | grep "^default" | head -1 | awk '{ print $5 }')
IPADDR=$(ip addr | awk "/inet/ && /${HOST_IFACE}/{sub(/\/.*$/,\"\",\$2); print \$2}")

echo "MAAS Endpoint"
echo "http://${IPADDR}:30001/MAAS/accounts/login/"

echo "Airflow Endpoint"
echo "http://${IPADDR}:30004/admin/"

