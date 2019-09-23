#!/bin/bash
wget https://gist.githubusercontent.com/ec2ainun/6ed0d54afe2d76bad2e038dbb3fb21b1/raw/91852c38301a4e509de68cb57237e2362bba66e8/docker18.sh
bash docker18.sh
sudo swapoff -a

apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl