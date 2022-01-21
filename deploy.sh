#!/bin/bash


kustomize build . | oc apply -f-
sleep 5
oc patch deployment/productpage-v1 -n bookinfo -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%s`'"}}}}}'
oc patch deployment/details-v1 -n bookinfo -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%s`'"}}}}}'
oc patch deployment/details-v2 -n bookinfo -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%s`'"}}}}}'
oc patch deployment/reviews-v1 -n bookinfo -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%s`'"}}}}}'
oc patch deployment/reviews-v2 -n bookinfo -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%s`'"}}}}}'
oc patch deployment/reviews-v3 -n bookinfo -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%s`'"}}}}}'
oc patch deployment/ratings-v1 -n bookinfo -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%s`'"}}}}}'
oc patch deployment/ratings-v2 -n bookinfo -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%s`'"}}}}}'
oc patch deployment/ratings-v2-mysql -n bookinfo -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%s`'"}}}}}'
oc patch deployment/ratings-v2-mysql-vm -n bookinfo -p '{"spec":{"template":{"metadata":{"annotations":{"kubectl.kubernetes.io/restartedAt": "'`date +%s`'"}}}}}'
