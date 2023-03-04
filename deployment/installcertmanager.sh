#!/bin/bash

echo "Let's encrypt"

echo "AKS cluster name: $1"
echo "Resource group name: $2"

az aks get-credentials --name $1 --resource-group $2

# Create the namespace for cert-manager
kubectl create namespace cert-manager --dry-run=client -o yaml | kubectl apply -f - 

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml

# it should be enough to deploy cert-manager, but we need to wait for it to be ready
wait 10

cat << EOF | kubectl apply -f - 
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: xy@company.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencryptprivatekeysecret
    solvers:
     - http01:
        ingress:
         class: azure/application-gateway
EOF

#apiVersion: networking.k8s.io/v1
#kind: Ingress
#metadata:
# name: reportersslingress
# annotations:
#    kubernetes.io/ingress.class: azure/application-gateway
#    cert-manager.io/cluster-issuer: letsencrypt-prod
#    cert-manager.io/acme-challenge-type: http01
#spec:
# tls:
# - hosts:
#   - k6grafana.westeurope.cloudapp.azure.com
#   secretName: grafana-secret-name
# rules:
# - host: k6grafana.westeurope.cloudapp.azure.com
#   http:
#    paths:
#    - path: /
#      backend:
#       service: 
#        name: reporter
#        port:
#         number: 3000
#      pathType: Exact
