docker-reg:
	cd setup/registry && bash config.sh && cd ../../
master-node:
	cd setup/cluster && bash kubeadm-master.sh && cd ../../
minion:
	cd setup/cluster && bash kube.sh && cd ../../
istio-setup:
	cd setup/cluster && bash istio.sh
istio-deploy:
	cd setup/cluster && bash crd-istio.sh
	kubectl label namespace default istio-injection=enabled --overwrite
