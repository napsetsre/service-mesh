# service-mesh
How to install Red Hat OpenShift Service Mesh on Red Hat OpenShift version 4.8. To
install the Red Hat OpenShift Service Mesh Operator, you must first install the Elasticsearch, Jaeger, and Kaili
Operators in the service mesh control plane project. 

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
6. Install the `service-mesh` demo.
```shell
kustomize build https://github.com/napsetsre/openshift-service-mesh#main | oc apply -f-
```

## Deployment vs DeploymentConfig
### Deployment
If you use Deployment resources along with automatic sidecar injection, you will need to update the pod template in the Deployment by adding or modifying an annotation. Run the following command to redeploy the pods each time you make a change to the Deployment:
```shell
oc patch deployment/<deployment> -n <namespace> -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date -r seconds`'"}}}}}'
```

### DeploymentConfig
When using a DeploymentConfig be aware that DestinationRule resources will not render correctly in Kiali.

> https://github.com/kiali/kiali/issues/4210


## Traffic Routing
You can think of virtual services as how you route your traffic to a given destination, and then you use destination rules to configure what happens to traffic for that destination. 

* **Virtual service** lets you configure how requests are routed to a service.
* 
* **Destination Rule** are rules applied to traffic after they have been routed to a destination by a **Virtual Service**.