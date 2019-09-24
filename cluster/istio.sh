#!/bin/bash
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.3.0 sh -
cd istio-1.3.0
echo "export PATH=$PATH:$PWD/bin" >> ~/.bashrc
source ~/.bashrc
istioctl verify-install
