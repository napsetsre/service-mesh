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
6. Clone the service mesh project using the following command:
```bash
git clone https://github.com/napsetsre/service-mesh.git
```
7. Ensure that `Curl` installed on your system.

## Install
Install the `service-mesh`.
```shell
kustomize build . | oc apply -f-
```

## Restart(Mac)
If your deployment uses automatic sidecar injection, you can update the pod template in the deployment by adding or modifying an annotation. Run the following command to redeploy the pods:
```shell
oc patch deployment/<deployment> -n <namespace> -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date -r seconds`'"}}}}}'
```

### Traffic Routing
You can think of virtual services as how you route your traffic to a given destination, and then you use destination rules to configure what happens to traffic for that destination. 

* **Virtual service** lets you configure how requests are routed to a service.
* 
* **Destination Rule** are rules applied to traffic after they have been routed to a destination by a **Virtual Service**.