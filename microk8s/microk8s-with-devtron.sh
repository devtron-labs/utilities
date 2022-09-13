#!/bin/bash
#Installing microk8s over ubuntu 18
sudo snap install microk8s --classic --channel=1.22 && sudo usermod -a -G microk8s $USER && sudo chown -f -R $USER ~/.kube && newgrp microk8s && microk8s enable dns storage helm3 ingress && \
echo "alias kubectl='microk8s kubectl '" >> .bashrc && \
echo "alias helm='microk8s helm3 '" >> .bashrc && \
source .bashrc && \
kubectl create ns devtroncd && \

#Installing Devtron
helm repo add devtron https://helm.devtron.ai && \
helm install devtron devtron/devtron-operator --create-namespace --namespace devtroncd  --set installer.modules={cicd} --set components.devtron.service.type=ClusterIP --set components.devtron.ingress.enabled=true --set components.devtron.ingress.className=public --set components.devtron.ingress.host="devtron.example.com"
