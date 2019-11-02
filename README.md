# AInun Registry

## **TL;dr**

This repo aim to showcase µsvc (microservice) setup that covering docker, private registry, kubeadm, helm, istio, grafana, kiali, and tracing(jaeger/zipkin)

Visit [usvc.algo.fit](https://usvc.algo.fit/)
* **Note** : i'll only keep the service up till october ends.
* **Demo** : below an example if you are coming here in the future, after october ends.
    ![can't load current gif](/explain/current.gif)
* Each line invoke each other svc:
    - **First line**: Demonstrating load balancing between python, go, node svc (try it by invoking it again).
    - **Second line**: Demonstrating routing (20/80) for canary and production, or developement by invoke it using certain header.
    - **Third line**: Demonstrating the use of docker private registry and routing for stress test.
    - **Fourth line**: Demonstrating how to invoke engress svc or routing to our cluster for stress test.


## **Telemetry**

How about telemetry? µsvc world kind of complex, we can't do it blindly right in production?
* you can visit :

    - **[grafana.usvc.algo.fit](http://grafana.usvc.algo.fit/d/LJ_uJAvmk/istio-service-dashboard?orgId=1&refresh=5s&from=now-5m&to=now)** : for monitoring metrices in our µsvc
    ---
    ![can't load grafana gif](/explain/grafana.gif)
    ---

    - **[kiali.usvc.algo.fit](http://kiali.usvc.algo.fit)** : for observability our µsvc use ec2ainun/QWERTY8jm for username/password
    ---
    ![can't load kiali gif](/explain/kiali.gif)
    ---

    - **[jaeger.usvc.algo.fit](http://jaeger.usvc.algo.fit)** : for tracing our µsvc
    ---
    ![can't load jaeger gif](/explain/jaeger.gif)
    ---
    

## **Show-Me-the-Code-Things**

I'll try to explain things shortly, so everyone can validate it quickly. (tested on ubuntu 18.04).

First of all, install make, i tend to use it to encapsulate complex things. for simplicity, i'll use ubuntu platform throughout validating this repo and new cluster to get our hands dirty.
```sh
    apt install make
```

### **Cluster**

```sh
    make control
```
* **Note** : it will setup kubeadm master node and weave-net CNI, and provide you command to join into cluster.
```sh
    make minion
```
* **Note** : it will setup minion node.
```sh
    kubeadm join your.master.node.ip:6443 --token gt3egh.9ckgp4ng7t8oi5yl \
    --discovery-token-ca-cert-hash sha256:31b62525baa0f5dc4102c8443dd1072202b8f51d0621057b506a1d5bceec398f 
```
* **Note** : execute that kind of command in minion node to join cluster that managed by master node.

### **Docker**

In k8s, it's expect an image that already been built.

```sh
    make build-docker
```
* **Note** : all the svc code, located in svc folder, use that commnad to built from scratch.

If you want to validate quickly, i already have an image in docker hub, and i used it throughout k8s, use one of the following command and test it out on port 2000.

```sh
    make test-py-dockerHub
```
* **Note** : it's python svc, it can be found, in svc/py/code.
```sh
    make test-go-dockerHub
```
* **Note** : it's golang svc, it can be found, in svc/go/code.
```sh
    make test-no-dockerHub
```
* **Note** :  it's node svc, it can be found, in svc/no/code.
```sh
    make test-time-dockerHub
```
* **Note** :  it's time svc, it can be found, in svc/time/code.

How about docker private registry? there is helm chart out there tho, but you can follow [this](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-private-docker-registry-on-ubuntu-18-04) tutorial. in my defense, i use following command to setup my own:

```sh
    make docker-reg
```
* **Note** :  it's use docker.algo.fit as repo registry.
### **Helm**

In short, it's kind of templating value for k8s object definition yaml.

```sh
    make helm-setup
```
* **Note** : it's assume that you haven't install helm and tiller on your cluster.

### **Istio**

In short, it's kind of control that manage traffic flow between service.

```sh
    make helm-add-istio
```
* **Note** : add istio definition yaml from helm chart repository.
```sh
    make helm-crd-istio
```
* **Note** : add custom resource definition that istio needs.

Use one of the following to apply and install istio into the cluster :

```sh
    make helm-install-istio
```
* **Note** : basic installation.
```sh
    make helm-istio-zipkin
```
* **Note** : enabling kiali, grafana, prometheus, and zipkin tracing.
```sh
    make helm-istio-jaeger
```
* **Note** : enabling kiali, grafana, prometheus, and jaeger tracing.

### **Applying-things**

```sh
    make start
```
* **Note** : applying deployment, service, ingress, egress, and routing rules.

```sh
    make load-setup
```
* **Note** : setup for stress test, and bring cool graphics in our telemetry system.

```sh
    make tes
```
* **Note** : executing a stress test, 50 user in second, that hit https://usvc.algo.fit with x-dev-user header with "stressTest" value for 600 seconds using artillery.

```sh
    make reset
```
* **Note** : reset everything.

a Quick experimental with different istio telemetry

```sh
    make helm-crd-istio
    make helm-istio-jaeger
    make tes
    make reset
```
* **Note** : this only work after installing helm, already have an istio repo in helm, artillery, and k8s cluster.

## **DEMO**

**Gateway(istio) -> VirtualService(istio) -> DestinationRule(istio) -> Service(k8s) -> Deployment(Pods)**

In short way, every request will use above track.

Are you still remember about istio that controlling traffic? you can see all the rules in config-k8s/defRules/. for the sake of demo, the service currently using a rules in currentRule-def.yaml and destination rules in destinationRule-def.yaml.

Take an example we invoke https://usvc.algo.fit/ :
* Aside from DNS service in use, A traffic will be redirected into IP address that our server use.
* After that, istio-ingressgateway will taking care of that traffic, and route it into a **front-gateway (Gateway)**.
* **route-front (VirtualService)** will listen and check, hosts and gateways traffic from **front-gateway (Gateway)** into **rand-front-svc (Service-ClusterIP)** to match certain condition.
* **rand-front-dest (DestinationRule)** will also listen and check, a host **rand-front-svc (Service-ClusterIP)** and subset from **route-front (VirtualService)**, into **front-deployment (Deployment)** that specifies different label-selector.
* And then a client **front-deployment (Deployment)** invoke **middleware-svc (Service-ClusterIP)**, and before that a **route-middle (VirtualService)** will listen and check, a hosts **middleware-svc (Service-ClusterIP)** and match certain header, in this case **'x-dev-user: betaUser'**. 
    * if it's valid, it will pass it into **middleware-dest (DestinationRule)** that also listen and check, a host **middleware-svc (Service-ClusterIP)** and subset from **route-middle(VirtualService)** into **middle-deployment (Deployment)** that specifies different label-selector in this case **'env: dev'**.
    * else, it will also pass it into **middleware-dest (DestinationRule)** that also listen and check a host **middleware-svc (Service-ClusterIP)** and subset from **route-middle  (VirtualService)** into **middle-deployment (Deployment)** that specifies different label-selector in this case **'env: canary' will get 20%** from overall traffic and **'env: prod' will get 80%** from overall traffic.
* Then a client **middle-deployment (Deployment)** invoke **core-svc (Service-ClusterIP)**, and before that a **route-core (VirtualService)** will listen and check a hosts **core-svc  (Service-ClusterIP)** and match certain header, in this case **'x-dev-user: stressTest'** and **'x-dev-user: betaUser'**. 
    * if it's not valid, it will pass it into **core-dest (DestinationRule)** that also listen and check, host **core-svc (Service-ClusterIP)** and subset from **route-core (VirtualService)**, into **core-deployment (Deployment)** that specifies different label-selector in this case **'env: prod'**.
    * else, it will also pass it into **core-dest (DestinationRule)** that also listen and check, host **core-svc (Service-ClusterIP)** and subset from **route-core (VirtualService)**, into **core-deployment (Deployment)** that specifies different label-selector in this case **'env: test'**.
* Then **core-deployment (Deployment)**
    * if it's match label **'env: prod'**, it will invoke http://worldtimeapi.org/api/timezone/Asia/Jakarta/ to get current time.
    * if it's match label **'env: test'**, it will invoke **clock-svc (Service-ClusterIP)** and pass it into **clock-deployment (Deployment)** to return current time.

## **CONFUSE?**
That's **GREAT!**, it's also mean you are trying to understand, let's just try learn by doing.

* Below an example **without** kind of header, it will giving back a 20% into canary and 80% into prod from overall traffic from middle-deployment respond and egress traffic from worldtimeapi.org which is invoked by core-deployment :
![can't load current gif](/explain/current.gif)
---
* Below an example with **'x-dev-user: betaUser'**, it will always routing to dev middle-deployment and giving back current time from core-deployment that invoked clock-svc service and return clock-deployment result :
![can't load betaUser gif](/explain/betaUser.gif)
---
* Below an example with **'x-dev-user: stressTest'**, it will giving back 20% into canary and 80% into prod from overall traffic from middle-deployment respond and also giving back current time from core-deployment that invoked clock-svc service and return clock-deployment result:
![can't load stressTest gif](/explain/stressTest.gif)
---
* How to trace a request? :
![can't load tracing gif](/explain/tracing.gif)
---

## **CREDIT**
Inspired from [Sandeep Dinesh](https://github.com/thesandlord)'s Amazing Talk about istio.


## **LICENSE**

[MIT](/LICENSE) License
```
Copyright (c) 2019 Moch. Ainun Najib

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```


## **Stargazers over time**

[![Stargazers over time](https://starchart.cc/ec2ainun/air.svg)](https://starchart.cc/ec2ainun/air)
