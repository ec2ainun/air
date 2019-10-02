docker-registry:
	cd registry && bash config.sh && cd ..
master-node:
	cd cluster && bash kubeadm-master.sh && cd ..
istio-setup:
	cd cluster && bash istio.sh
istio-deploy:
	for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done
	kubectl apply -f install/kubernetes/istio-demo.yaml
	kubectl label namespace default istio-injection=enabled --overwrite