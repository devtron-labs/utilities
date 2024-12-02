#!/bin/bash

echo "Installing helm.."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

echo "Installing Devtron"
helm repo add devtron https://helm.devtron.ai
helm install devtron devtron/devtron-operator --create-namespace --namespace devtroncd  --set installer.modules={cicd}
