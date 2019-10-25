.PHONY: all 
all: docker-reg code-py-docker code-go-docker code-no-docker code-time-docker \
	hubTag-py-docker hubTag-go-docker hubTag-no-docker hubTag-time-docker \
	hubPush-py-docker hubPush-go-docker hubPush-no-docker hubPush-time-docker \
	login-docker tag-py-docker tag-go-docker tag-no-docker tag-time-docker \
	push-py-docker push-go-docker push-no-docker push-time-docker control minion \
	istio-setup istio-deploy helm-setup helm-add-istio helm-crd-istio helm-install-istio helm-istio-tele \
	istio-inject deployment service ingress egress \
	rules-prod rules-dev rules-canary rules-beta rules-retry rules-stress rules-current \
	tele-grafana tele-prometheus tele-kiali tele-jaeger \
	load-setup stress-tes

build-docker: code-py-docker code-go-docker code-no-docker code-time-docker

tag-dockerHub: hubTag-py-docker hubTag-go-docker hubTag-no-docker hubTag-time-docker
push-dockerHub: hubPush-py-docker hubPush-go-docker hubPush-no-docker hubPush-time-docker

tag-docker: tag-py-docker tag-go-docker tag-no-docker tag-time-docker
push-docker: push-py-docker push-go-docker push-no-docker push-time-docker

docker-reg :
	cd setup/registry && bash config.sh && cd ../../

code-py-docker:
	docker build -t usvc-py svc/py/code/
code-go-docker:
	docker build -t usvc-go svc/go/code/
code-no-docker:
	docker build -t usvc-no svc/no/code/
code-time-docker:
	docker build -t usvc-time svc/clock/code/

test-py-docker:
	docker run -e PORT=2000 -p 2000:2000 usvc-py:v1
test-go-docker:
	docker run -e PORT=2000 -p 2000:2000 usvc-go:v1
test-no-docker:
	docker run -e PORT=2000 -p 2000:2000 usvc-no:v1
test-time-docker:
	docker run -e PORT=2000 -p 2000:2000 usvc-time:v1

test-py-dockerHub:
	docker run -e PORT=2000 -p 2000:2000 ec2ainun/usvc-py:v1
test-go-dockerHub:
	docker run -e PORT=2000 -p 2000:2000 ec2ainun/usvc-go:v1
test-no-dockerHub:
	docker run -e PORT=2000 -p 2000:2000 ec2ainun/usvc-no:v1
test-time-dockerHub:
	docker run -e PORT=2000 -p 2000:2000 ec2ainun/usvc-time:v1

hubTag-py-docker:
	docker tag usvc-py ec2ainun/usvc-py:v1
hubTag-go-docker:
	docker tag usvc-go ec2ainun/usvc-go:v1
hubTag-no-docker:
	docker tag usvc-no ec2ainun/usvc-no:v1
hubTag-time-docker:
	docker tag usvc-time ec2ainun/usvc-time:v1

hubPush-py-docker:
	docker push ec2ainun/usvc-py:v1
hubPush-go-docker:
	docker push ec2ainun/usvc-go:v1
hubPush-no-docker:
	docker push ec2ainun/usvc-no:v1
hubPush-time-docker:
	docker push ec2ainun/usvc-time:v1

login-docker:
	docker login https://docker.algo.fit

tag-py-docker:
	docker tag usvc-py docker.algo.fit/ec2ainun/usvc-py:v1
tag-go-docker:
	docker tag usvc-go docker.algo.fit/ec2ainun/usvc-go:v1
tag-no-docker:
	docker tag usvc-no docker.algo.fit/ec2ainun/usvc-no:v1
tag-time-docker:
	docker tag usvc-time docker.algo.fit/ec2ainun/usvc-time:v1

push-py-docker:
	docker push docker.algo.fit/ec2ainun/usvc-py:v1
push-go-docker:
	docker push docker.algo.fit/ec2ainun/usvc-go:v1
push-no-docker:
	docker push docker.algo.fit/ec2ainun/usvc-no:v1
push-time-docker:
	docker push docker.algo.fit/ec2ainun/usvc-time:v1
	
control :
	cd setup/cluster && bash kubeadm-master.sh && cd ../../
minion :
	cd setup/cluster && bash kube.sh && cd ../../
istio-setup :
	cd setup/cluster && bash istio.sh
istio-deploy :
	cd setup/cluster && bash crd-istio.sh
	kubectl label namespace default istio-injection=enabled --overwrite

helm-setup:
	cd setup/cluster && bash helm.sh && cd ../../

helm-add-istio:
	helm repo add istio.io https://storage.googleapis.com/istio-release/releases/1.3.0/charts/
	helm repo list
helm-crd-istio:
	helm install --name istio-init --namespace istio-system istio.io/istio-init

helm-install-istio:
	helm install --name istio --namespace istio-system istio.io/istio
helm-istio-zipkin:
	helm install --name istio --namespace istio-system \
		--set kiali.enabled=true \
		--set grafana.enabled=true \
		--set prometheus.enabled=true \
		--set pilot.traceSampling=100.0 \
		--set servicegraph.enabled=true \
		--set tracing.provider=zipkin \
		--set global.tracer.zipkin.address=zipkin.istio-system:9411 \
		--set global.enableTracing=true \
		--set tracing.enabled=true istio.io/istio
helm-istio-jaeger:
	helm install --name istio --namespace istio-system \
		--set kiali.enabled=true \
		--set grafana.enabled=true \
		--set prometheus.enabled=true \
		--set pilot.traceSampling=100.0 \
		--set servicegraph.enabled=true \
		--set global.enableTracing=true \
		--set tracing.enabled=true istio.io/istio

reset:
	kubectl delete svc --all
	kubectl delete deploy --all
	kubectl delete VirtualService --all
	kubectl delete DestinationRule --all
	kubectl delete Gateway --all
	kubectl delete ServiceEntry --all
	kubectl delete ns istio-system
	helm del --purge istio-init
	helm del --purge istio

start : istio-inject deployment service ingress egress rules-current istio-tele

istio-inject :
	kubectl label namespace default istio-injection=enabled --overwrite

deployment :
	kubectl apply -f config-k8s/defDeployment/
service :
	kubectl apply -f config-k8s/defService/
ingress :
	kubectl apply -f config-k8s/defIngress/
egress :
	kubectl apply -f config-k8s/defEgress/

rules-prod :
	kubectl apply -f config-k8s/defRules/destinationRule-def.yaml
	kubectl apply -f config-k8s/defRules/prodRule-def.yaml
rules-dev :
	kubectl apply -f config-k8s/defRules/devRule-def.yaml
rules-canary :
	kubectl apply -f config-k8s/defRules/canaryRule-def.yaml
rules-beta :
	kubectl apply -f config-k8s/defRules/betaUserRule-def.yaml
rules-retry :
	kubectl apply -f config-k8s/defRules/retryRule-def.yaml
rules-stress :
	kubectl apply -f config-k8s/defRules/stressRule-def.yaml
rules-current :
	kubectl apply -f config-k8s/defRules/destinationRule-def.yaml
	kubectl apply -f config-k8s/defRules/currentRule-def.yaml

istio-tele: tele-grafana tele-prometheus tele-kiali tele-jaeger tele-tracing tele-zipkin
tele-grafana :
	kubectl apply -f config-k8s/defTelemetry/grafana/
tele-prometheus :
	kubectl apply -f config-k8s/defTelemetry/prometheus/
tele-kiali :
	kubectl apply -f config-k8s/defTelemetry/kiali/
tele-jaeger :
	kubectl apply -f config-k8s/defTelemetry/jaeger/
tele-tracing :
	kubectl apply -f config-k8s/defTelemetry/tracing/
tele-zipkin :
	kubectl apply -f config-k8s/defTelemetry/zipkin/

load-setup :
	bash setup/test/setup-artillery.sh
tes :
	artillery run setup/test/stressTes.yaml