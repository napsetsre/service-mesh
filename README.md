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
kustomize build . | oc apply -f-h
```