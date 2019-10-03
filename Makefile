docker-registry:
	cd registry && bash config.sh && cd ..
master-node:
	cd cluster && bash kubeadm-master.sh && cd ..
istio-setup:
	cd cluster && bash istio.sh
istio-deploy:
	cd cluster && bash crd-istio.sh
	kubectl label namespace default istio-injection=enabled --overwrite
