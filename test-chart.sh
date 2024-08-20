CHART_NAME=$1

sudo microk8s helm3 upgrade -i --atomic $CHART_NAME helm-chart-sources/$CHART_NAME --set workload=Deployment --set kubePrometheusStack.enabled=true

export STATUS=$(sudo microk8s kubectl get po | grep $CHART_NAME | awk '{print $3}')
if [ "$STATUS" == "" ]
then
  exit 1
fi

while [ $STATUS == "ContainerCreating" ]
do
  export STATUS=$(sudo microk8s kubectl get po | grep $CHART_NAME | awk '{print $3}')
  sleep 1
done

sudo microk8s kubectl get po

if [ $STATUS != "Running" ]
then
  exit 1
fi
