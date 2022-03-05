#!/bin/bash


# Apply changes
kustomize build . | oc apply -f-
#sleep 5
# Redeploy
# Deployment resources need to restarted after any redeployment.
NAMESPACE="bookinfo"

oc patch deploymentconfig/productpage-v1 \
      -n $NAMESPACE -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%s`'"}}}}}'
oc patch deploymentconfig/details-v1 \
      -n $NAMESPACE -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%s`'"}}}}}'
oc patch deploymentconfig/reviews-v1 \
      -n $NAMESPACE -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%s`'"}}}}}'
oc patch deploymentconfig/reviews-v2 \
      -n $NAMESPACE -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%s`'"}}}}}'
oc patch deploymentconfig/reviews-v3 \
      -n $NAMESPACE -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%s`'"}}}}}'


