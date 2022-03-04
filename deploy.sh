#!/bin/bash


# Apply changes
kustomize build . | oc apply -f-
sleep 5
# Redeploy
# Deployment resources need to restarted after any redeployment.
DEPLOYMENTS=( productpage-v1 details-v1  reviews-v2 reviews-v3 ratings-v1 )
NAMESPACE="bookinfo"
for deployment in "${DEPLOYMENTS[@]}"
do
   oc patch deploymentconfig/${deployment} \
      -n $NAMESPACE -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%s`'"}}}}}'
done

