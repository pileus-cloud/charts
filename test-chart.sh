#!/bin/bash -e
CHART_NAME=$1

helm3() {
   sudo microk8s helm3 upgrade -i --atomic $CHART_NAME helm-chart-sources/$CHART_NAME --set workload=Deployment --set kubePrometheusStack.enabled=true
}

(helm3 &)

while true; do
   pgrep microk8s.helm3
   echo
   sudo microk8s kubectl get po
   sleep 15
   echo
done

