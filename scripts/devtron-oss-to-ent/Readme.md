# Devtron Enterprise Installation (For evaluation/trials only)

This guide provides instructions for installing Devtron Enterprise edition or upgrading from the open-source (OSS) version to the Enterprise version using Helm.

## Pre-requisites for Client:
1. Helm installed on your cluster
2. Access to a Kubernetes cluster
3. If the cluster has restrictions on internet access please ensure that the domain ```*.azurecr.io``` is whitelisted in the firewall.
4. Username, token,registry and `ent-values.yaml` or `ent-bom.yaml` file (for upgrade) provided by the Devtron Team

## Setting up credentials and yaml file:

Before proceeding with the installation or upgrade, export the username and token variables and create the values.yaml or ent-bom.yaml:

```bash
export username=XXXXXXXXXXX
export registry=XXXXXXXXXXX
```

Create Values file
    ```
    vi ent-bom.yaml
    ```
Create service-account for image-pull-secret
    ```
    vi sa-image-pull.json
    ```
## Fresh Installation of Devtron Enterprise

1. Add the Devtron Helm repository:
   ```bash
    kubectl create ns devtroncd
    helm repo add devtron https://helm.devtron.ai
    helm repo update devtron
   ```
   
2. Create ImagePullSecrets in devtroncd namespace:
   ```bash
    kubectl create secret docker-registry devtron-image-pull-enterprise --namespace devtroncd --docker-server=$registry --docker-username=$username --docker-password="$(cat sa-image-pull.json)"
   ```

3. Install Devtron using Helm:
   ```bash
   helm install devtron devtron/devtron-operator -f ent-bom.yaml --namespace devtroncd --set installer.modules={cicd} --set argo-cd.enabled=true --set security.enabled=true  --set notifier.enabled=true  --set security.trivy.enabled=true --set monitoring.grafana.enabled=true --set components.dashboard.registry=$registry --set components.devtron.registry=$registry --set components.kubelink.registry=$registry --set components.gitsensor.registry=$registry --set security.imageScanner.registry=$registry --set devtronEnterprise.casbin.registry=$registry --set devtronEnterprise.scoop.registry=$registry
   ```

## Upgrading Existing OSS Devtron to Enterprise

*Run the First two commands only if you are on a version lower than 0.7.x*

1. Set the release name & create the ent-bom.yaml:
   ```bash
   export RELEASE_NAME=devtron
   ```

2. Update labels and annotations:
   ```bash
   kubectl -n devtron-ci label sa --all "app.kubernetes.io/managed-by=Helm" --overwrite
   kubectl -n devtron-ci annotate sa --all "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
   kubectl -n devtron-cd label sa --all "app.kubernetes.io/managed-by=Helm" --overwrite
   kubectl -n devtron-cd annotate sa --all "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
   ```

3. Create ImagePullSecrets in devtroncd namespace:
   ```bash
    kubectl create secret docker-registry devtron-image-pull-enterprise --namespace devtroncd --docker-server=$registry --docker-username=$username --docker-password="$(cat sa-image-pull.json)"
   ```

4. Upgrade the Devtron stack:
   ```bash
   helm upgrade -n devtroncd devtron devtron/devtron-operator --reuse-values -f ent-bom.yaml --set components.dashboard.registry=$registry --set components.devtron.registry=$registry --set components.kubelink.registry=$registry --set components.gitsensor.registry=$registry --set security.imageScanner.registry=$registry --set devtronEnterprise.casbin.registry=$registry --set devtronEnterprise.scoop.registry=$registry
   ```

## Note:
- Ensure you have the `ent-values.yaml` file (for fresh installation) or `ent-bom.yaml` file (for upgrade) provided by the Devtron Team before proceeding with the installation or upgrade.
- The credentials provided for evaluation or trial purposes will expire once the evaluation or trial period concludes. Please make sure to revert your stack to the OSS version or purchase an enterprise subscription before the trial ends.
- Continuing to use Devtron Enterprise beyond the evaluation period without a valid license may result in a licensing violation.

For any issues or additional support, please contact the Devtron support team. :)
