#!/bin/bash

set -e

# Ensure SELinux is Enforcing (See https://access.redhat.com/security/cve/cve-2019-5736)
setenforce 1

# Busybox
curl -Lo /usr/bin/busybox https://busybox.net/downloads/binaries/1.31.0-i686-uclibc/busybox
chmod a+x /usr/bin/busybox
busybox --install

# Yum packages
yum install yum-utils device-mapper-persistent-data lvm2 -y -q
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum update -y -q && yum install -y -q containerd.io-1.2.10 \
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

# K8s components
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Required system setting
sysctl net.bridge.bridge-nf-call-iptables=1

yum install -y -q kubelet-1.15.11-0 kubeadm-1.15.11-0 kubectl-1.15.11-0 --disableexcludes=kubernetes

# Enable Kubelet, which by default will be in a CrashBootLoop
systemctl enable --now kubelet

# Kubeadm can't run with swapfile on, default for Vagrant
swapoff -a

# Ensure images can be pulled from Google
kubeadm config images pull

case "$1" in
"master")
  # Initialize KubeAdm setup
  kubeadm init
  export KUBECONFIG=/etc/kubernetes/admin.conf
  kubectl apply -f https://cloud.weave.works/k8s/net?k8s-version=1.15.11
  mkdir -p /home/vagrant/token
  chown vagrant. /home/vagrant/token
  echo $(kubeadm token list | tail -1 | awk '{print $1}') >> /home/vagrant/token/index.html
  chmod 0440 /home/vagrant/token/index.html
  mkdir -p /home/vagrant/config
  chown vagrant. /home/vagrant/config
  cat $KUBECONFIG >> /home/vagrant/config/index.html
  chmod 0440 /home/vagrant/config/index.html
  mkdir -p /home/vagrant/hash
  chown vagrant. /home/vagrant/hash
  openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | awk '{print $2}' >> /home/vagrant/hash/index.html
  nohup httpd -p 8080 -h /home/vagrant
  ;;
"worker")
  kubeadm join master:6443 --token $(curl http://master:8080/token/) --discovery-token-ca-cert-hash sha256:$(curl http://master:8080/hash/)
  curl http://master:8080/config/ > ~/.kubeconf
  chmod a+r ~/.kubeconf
  export KUBECONFIG=~/.kubeconf
  ;;
esac
