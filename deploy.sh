#!/bin/bash


# Apply changes
kustomize build . | oc apply -f-
sleep 5
# Redeploy
#DEPLOYMENTS=( productpage-v1 details-v1 details-v2 reviews-v2 reviews-v3 ratings-v1 ratings-v2 ratings-v2-mysql ratings-v2-mysql-vm mongodb-v1 )
#NAMESPACE="bookinfo"
#for deployment in "${DEPLOYMENTS[@]}"
#do
#   oc patch deploymentconfig/${deployment} \
#      -n $NAMESPACE -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%s`'"}}}}}'
#done

