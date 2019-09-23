#!/bin/bash
bash kube.sh
kubeadm init --kubernetes-version $(kubeadm version -o short)

export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"