# service-mesh
The page discusses how to install Red Hat OpenShift Service Mesh on Red Hat OpenShift version 4.8. To
install the Red Hat OpenShift Service Mesh Operator, you must first install the Elasticsearch, Jaeger, and Kaili
Operators accessible to the service mesh control plane project. For the sake of our discussion we will be deploying the 
upstream bookinfo reference application to test drive our deployment.


## Table Of Contents
- [Assumptions](#assumptions)
- [Environment Variables](#environment-variables)

## Assumptions
1. Access to the `oc command`
2. Access to a user with cluster-admin permissions
3. Access to OpenShift Container Platform 
4. Red Hat Service Mesh Operator installed
5. Enable auto-completion using the following command:
```bash
source <(oc completion bash)
```
6. Install the demo.
```shell
kustomize build https://github.com/napsetsre/openshift-service-mesh#main | oc apply -f-
```

### Heads Up
In this demo we are going to use OpenShift DeploymentConfig and ImageStream resources. Note you could also use the Kubernetes native resources.

__Deployment__

If you use Deployment resources along with automatic sidecar injection, you will need to update the pod template in the Deployment by adding or modifying an annotation. Run the following command to redeploy the pods each time you make a change to the Deployment:
```shell
oc patch deployment/<deployment> -n <namespace> -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date -r seconds`'"}}}}}'
```

__DeploymentConfig__

When using a DeploymentConfig be aware that DestinationRule resources will not render correctly in Kiali.

> https://github.com/kiali/kiali/issues/4210

## Projects
### Control Plane Project
`book-istio-system` is our control plane project acting as the central controller for the service mesh.

Resources
* ServiceMeshControlPlane
* ServiceMeshMember
* ServiceMeshMemberRoll

Verify the control plane installation status using the following command:
```bash
oc get smcp -n bookinfo-istio-system -w
```

### Data Plane Project

Our `Data Plane` project is named `bookinfo`.



1. Destination rules configure what happens to traffic after virtual service routing rules are evaluated. Apply
   `DestinationRule` to expose v1 destinations using the following command:
```bash
oc apply -n bookinfo -f ./install/destination-rule-all.yaml
```

2. Think of virtual services as how traffic is routed to a given destination. Each virtual service consists of a set
   of routing rules that are evaluated in order. So to route all traffic to subset, `v1`, only use the following command:
```bash
oc apply -n bookinfo -f ./install/virtual-service-all-v1.yaml
```

3. Deploy the service using the following commands:
```bash
oc apply -n bookinfo -f ./install/bookinfo.yaml
```

4. Deploy the `Gateway` configuration using the following command:
```bash
oc apply -n bookinfo -f ./install/bookinfo-gateway.yaml
```

## Verify Deployment

1. List the running `Pods` using the following command:
```bash
oc get pods -n bookinfo
```

2. List the `Tools` routes using the following command:
```bash
oc get route -n istio-system
```

3. Export the `Gateway` URL using the following command:
```bash
export GATEWAY_URL=$(oc -n istio-system get route istio-ingressgateway -o jsonpath='{.spec.host}')
```

4. On the http://${GATEWAY_URL}/productpage of the Bookinfo application, refresh the browser.
```bash
echo http://${GATEWAY_URL}/productpage
```

You should see that the traffic is routed to the v1 services.

> An extremely entertaining play by Shakespeare. The slapstick humour is refreshing!
> - Reviewer1


> Absolutely fun and entertaining. The play lacks thematic depth when compared to other plays by Shakespeare.
> - Reviewer2

6. Send some traffic using the following command:
```bash
for i in {1..20}; do sleep 0.25; curl -I http://${GATEWAY_URL}/productpage; done
```

## Walk-Through
1. Execute the walk-through using the following command:
```bash
sh ./install/walk-through.sh
```

## Quick-Start
1. Execute the quick-start using the following command:
```bash
sh ./install/quick-start.sh
```

## Cleanup
When you are finished you can remove the resources that we installed.
> CAUTION: Removing any shared ElasticSearch, Kiali, Jeager, or Service Mesh subscriptions!

1. Remove `Bookinfo` project using the following command:
```bash
source ./cleanup.sh
```

## References
- [Subscription](https://docs.openshift.com/container-platform/4.6/rest_api/operatorhub_apis/subscription-operators-coreos-com-v1alpha1.html)
- [Red Hat OpenShift Command Line Tools](https://docs.openshift.com/container-platform/4.6/cli_reference/openshift_cli/getting-started-cli.html#cli-about-cli_cli-developer-commands)
- [Red Hat Service Mesh](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.6/html-single/service_mesh/index)
- [Istio Release 1.6.14](https://istio.io/latest/news/releases/1.6.x/announcing-1.6.14/)
- [Unable To Delete Project](https://access.redhat.com/solutions/4165791)


