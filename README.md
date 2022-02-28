# Service Mesh
The page discusses Red Hat OpenShift Service Mesh on Red Hat OpenShift. To install the Red Hat OpenShift Service Mesh Operator, you must first install the Elasticsearch, Jaeger, and Kaili Operators. For the sake of discussion we will be deploying the upstream Istio `bookinfo` reference application to test drive our demo.

## Table Of Contents
- [Assumptions](#assumptions)
- [Environment Variables](#environment-variables)
- [Components](#components)
- [Demo](#demo)
- [References](#references)

## Assumptions
1. Access to the `oc command`
2. Access to a user with cluster-admin permissions
3. Access to OpenShift Container Platform 
4. Red Hat Service Mesh Operator installed
5. Enable auto-completion using the following command:
```bash
source <(oc completion bash)
```

### Heads Up
In this demo we are going to use OpenShift DeploymentConfig and ImageStream resources. Note you could also use the Kubernetes native resources such as deployments.

__Deployment__

If you use Deployment resources along with automatic sidecar injection, you will need to update the pod template in the Deployment by adding or modifying an annotation. Run the following command to redeploy the pods each time you make a change to the Deployment:
```shell
oc patch deployment/<deployment> -n <namespace> -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date -r seconds`'"}}}}}'
```

__DeploymentConfig__

When using a DeploymentConfig be aware that DestinationRule resources will not render correctly in Kiali.

> https://github.com/kiali/kiali/issues/4210

### Service Mesh Components

#### [Istio](https://istio.io/)
Istio is the core implementation of the service mesh architecture for the Kubernetes platform.
Istio creates a control plane that centralizes service mesh capabilities and a data plane that
creates the structure of the mesh.

The data plane controls communications between services by injecting sidecar containers that
capture traffic between microservices.

#### [Maistra](https://maistra.io/)
Maistra is an open-source project based on Istio that adapts Istio features to the edge cases
of deployment in OpenShift Container Platform. Maistra also adds extended features to Istio,
such as simplified multitenancy, explicit sidecar injection, and the use of OpenShift routes
instead of Kubernetes ingress.

#### [Jaeger](https://www.jaegertracing.io/)
Jaeger is an open source traceability server that centralizes and displays traces associated
with a single request. A trace contains information about all services that a request reached.
Maistra is responsible for sending the traces to Jaeger and Jaeger is responsible for
displaying traces. Microservices in the mesh are responsible for generating request headers
needed for other components to generate and aggregate traces.

#### [ElasticSearch](https://www.elastic.co/elasticsearch/)
ElasticSearch is an open source, distributed, JSON-based search and analytics engine.
Jaeger uses ElasticSearch for storing and indexing the tracing data. ElasticSearch is an
optional component for Red Hat OpenShift Service Mesh.

#### [Kiali](https://kiali.io/)
Kiali provides service mesh observability. Kiali discovers microservices in the service mesh
and their interactions and visually represents them. It also captures information about
communication and services, such as the protocols used, service versions, and failure
statistics.

#### [Prometheus](https://prometheus.io/)
Prometheus is used by OpenShift Service Mesh to store telemetry information from services.
Kiali depends on Prometheus to obtain metrics, health status, and mesh topology.

#### [Grafana](https://grafana.com/)
Optionally, Grafana can be used to analyze service mesh metrics. Grafana provides mesh
administrators with advanced query and metrics analysis.

#### [3scale](https://www.3scale.net/)
The 3scale Istio adapter is an optional component that integrates OpenShift Service Mesh
with Red Hat 3scale API Management solutions. The default OpenShift Service Mesh
installation does not include this component.

## Demo
We are going to use the Bookinfo application to install both a data plane and control plane.

### Data Plane Project
Bookinfo application consists of the following services:

* `productpage` service that calls the reviews and ratings microservices to populate the page.
* `details` service contains detailed book information.
* `reviews` service contains book reviews and calls the `ratings` service. 
* `ratings` service contains book ranking information that accompanies a book review.

There are three versions of the `ratings` service:
* **v1** does not call the ratings Service.
* **v2** calls the ratings service and displays each rating as one to five black stars.
* **v3** calls the ratings service and displays each rating as one to five red stars.

Data Plane resources:

Resources
* __Namespace__
* __VirtualService__ 
* __DestinationRule__
* __Service__
* __ServiceAccount__
* __DeploymentConfig__
* __ImageStream__

Install the Data Plane.
```shell
kustomize build https://github.com/napsetsre/openshift-service-mesh#main | oc apply -f-
```

### Control Plane Project
`book-istio-system` is the control plane project acting as the central controller for the service mesh.

Resources
* __ServiceMeshControlPlane__
* __ServiceMeshMember__
* __ServiceMeshMemberRoll__

Verify the control plane installation status using the following command:
```bash
oc get smcp -n bookinfo-istio-system -w
```

## Verify Deployment

1. List the running `Pods` using the following command:
```bash
oc get pods -n bookinfo
```

2. List the `Tools` routes using the following command:
```bash
oc get route -n bookinfo-istio-system
```

3. Export the `Gateway` URL using the following command:
```bash
export GATEWAY_URL=$(oc -n bookinfo-istio-system get route istio-ingressgateway -o jsonpath='{.spec.host}')
```

4. On the http://${GATEWAY_URL}/productpage of the Bookinfo application, refresh the browser.
```bash
echo http://${GATEWAY_URL}/productpage
```

## Traffic Management
Traffic routing lets you control the flow of traffic between service versions.

### Request Routing
Shift the routing weights between the different versions of the reviews service and redeploy after each change.

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
spec:
  hosts:
    - reviews
  http:
    - route:
        - destination:
            host: reviews
            subset: v1
          weight: 100
        - destination:
            host: reviews
            subset: v2
          weight: 0
        - destination:
            host: reviews
            subset: v3
          weight: 0
```
Expected Results
* Route 100% traffic to **reviews-v1** service to see (Zero Stars) in the browser.
* Route 100% traffic to **reviews-v2** service to see (Black Stars) in the browser.
* Route 100% traffic to **reviews-v3** service to see (Red Stars) in the browser.

### Load Balancing
Supported load balancing policy requests are Random, Weighted, and Least

* **Random** type requests are forwarded at random to instances in the pool. 
* **Weighted** type requests are forwarded in the pool according to a specific percentage. 
* **Least** type requests are forwarded to the instances with the least number of requests.


### Header Based Routing
We can change the route configuration so that all traffic from a specific user is routed to a specific service version. 
In this case, all traffic from a user named Bill will be routed to the service reviews:v2 and traffic from user named Fred w
ill be routed to the service reviews:v1. This example is enabled by the fact that the productpage service adds a 
custom end-user header to all downstream HTTP requests to the reviews service.

Expect to see BLACK star ratings
* On the /productpage of the Bookinfo application, log in as user Bill and refresh the browser.

Expect to see RED star ratings
* On the /productpage of the Bookinfo application, log in as user Fred and refresh the browser. 

Log in as another user (pick any name you wish). Refresh the browser; notice the stars are gone! This is because 
traffic is routed to reviews:v1 for all users except Bill and Fred.


Send some traffic using the following command:
```bash
for i in {1..20}; do sleep 0.25; curl -I http://${GATEWAY_URL}/productpage; done
```

### Cleanup
When you are finished you can remove the resources that we installed.

Remove both the `bookinfo` and `book-istio-system` projects using the following command:
```bash
kustomize build https://github.com/napsetsre/openshift-service-mesh#main | oc delete -f-
```

## References
- [Subscription](https://docs.openshift.com/container-platform/4.8/rest_api/operatorhub_apis/subscription-operators-coreos-com-v1alpha1.html)
- [Red Hat OpenShift Command Line Tools](https://docs.openshift.com/container-platform/4.8/cli_reference/openshift_cli/getting-started-cli.html#cli-about-cli_cli-developer-commands)
- [Red Hat Service Mesh](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.8/html-single/service_mesh/index)
- [Unable To Delete Project](https://access.redhat.com/solutions/4165791)


