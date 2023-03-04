#!/bin/bash

echo "AKS cluster name: $1"
echo "Resource group name: $2"
echo "Build path: $3"

namespace="framework"

az aks get-credentials --name $1 --resource-group $2

master=`kubectl get pods -n $namespace | grep "master"|awk '{print $1}'`

# Create namespace
kubectl create namespace $namespace --dry-run=client -o yaml | kubectl apply -f - 

# wait for the helm chart completely deployed
helm upgrade --install loadtest-config-chart $3/helm/loadtest_config_chart -f $3/helm/loadtest_config_chart/values.yaml -n $namespace --wait