#!/bin/bash

set -e

# Ensure SELinux is Enforcing (See https://access.redhat.com/security/cve/cve-2019-5736)
setenforce 1

# Yum packages
yum install yum-utils device-mapper-persistent-data lvm2 -y
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum update -y && yum install -y containerd.io-1.2.10 \
    docker-ce-19.03.4 \
    docker-ce-cli-19.03.4

# Add Docker Daemon config, secure file
mkdir /etc/docker
cat > /etc/docker/daemon.json <<EOD
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOD
chmod 0400 /etc/docker/daemon.json

# Add service directory, enable Docker service
mkdir -p /etc/systemd/system/docker.service.d
systemctl daemon-reload
systemctl enable docker
systemctl restart docker