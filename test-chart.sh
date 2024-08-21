#!/bin/bash
CHART_NAME=$1

(sudo microk8s helm3 upgrade -i --atomic $CHART_NAME helm-chart-sources/$CHART_NAME --set workload=Deployment --set kubePrometheusStack.enabled=true || \\
                echo "$?" > /tmp/${CHART_NAME}.status ) &

set +x
PROC_ID=$!

while true; do
          sleep 20

          sudo microk8s kubectl get po
          
          if ( ! sudo kill -0 "$PROC_ID" >/dev/null 2>&1 ); then
              exit $(cat /tmp/${CHART_NAME}.status 2>/dev/null || echo 0)
          fi
done
