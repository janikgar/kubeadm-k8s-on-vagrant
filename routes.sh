#!/bin/bash

set -e

SUBNET=$(ip r | grep -v default | grep eth0 | cut -f1 -d' ')

MASTER_PORTS=("6443" "22" "8080" "2379:2380" "10250:10252")
WORKER_PORTS=("10250" "30000:32767")

case "$1" in
"master")
    PORTS=$MASTER_PORTS
    ;;
"worker")
    PORTS=$WORKER_PORTS
    ;;
*)
    echo "Usage: ./routes.sh {master,worker}"
    exit 1
esac

for port in "${MASTER_PORTS[@]}"
do
    iptables -A INPUT -s "$SUBNET" -p tcp --dport "$port" -j ACCEPT
done
# iptables -A INPUT -j DROP