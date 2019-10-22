# AInun Registry

## **TL;dr**
---
This Repo aim to showcase µsvc (microservice) setup that covering docker, private registry, kubeadm, helm, istio, grafana, kiali, and jaeger

visit [usvc.algo.fit](https://usvc.algo.fit/)
* each line invoke other svc:
    - first line: demonstrating load balancing between python, go, node svc (try it by invoke it again)
    - second line: demonstrating routing (20/80) for canary and production, or developement by invoke it using certain header
    - third line: demonstrating how to use docker private registry and routing for stress test
    - fourth line: demonstrating how to invoke engress svc or routing to our cluster for stress test

## **Telemetry**
---
How about telemetry? µsvc world is so complex, we can't do it blindly right in production?
* you can visit :
    - [grafana.usvc.algo.fit](http://grafana.usvc.algo.fit/d/LJ_uJAvmk/istio-service-dashboard?orgId=1&refresh=5s&from=now-5m&to=now) : for monitoring metrices in our µsvc
    ![can't load grafana gif](/explain/grafana.gif)
    - [kiali.usvc.algo.fit](http://kiali.usvc.algo.fit) : for observability our µsvc
    ![can't load kiali gif](/explain/kiali.gif)
    - [jaeger.usvc.algo.fit](http://jaeger.usvc.algo.fit) : for tracing our µsvc
    ![can't load jaeger png](/explain/jaeger.png)

## **Show-me-the-code-things**
---
everyting is in here, i will not opensourcing it if not work though. Bear with me, i will explain it here, but i also need T-shirt for hacktoberfest, see yaa till next commit

## LICENSE
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