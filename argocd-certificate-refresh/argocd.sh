#!/bin/sh

kubectl get secret argocd-secret -n devtroncd -o yaml > argocd-secret.yaml
sed -i '6,7d' argocd-secret.yaml
kubectl delete secret argocd-secret -n devtroncd --ignore-not-found
kubectl apply -f argocd-secret.yaml
kubectl delete pods -n devtroncd -l app.kubernetes.io/name=argocd-server
sleep 15
kubectl delete pods -n devtroncd -l component=devtron