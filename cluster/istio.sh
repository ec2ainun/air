#!/bin/bash
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.3.0 sh -
cd istio-1.3.0

if [[ ! -d "$ISTIOCTL" ]]; then 
    export PATH=$PWD/bin:$PATH
    echo "export PATH=\"$(pwd)/bin\"" >> ~/.bashrc
fi
