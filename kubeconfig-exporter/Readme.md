## Script to generate cluster-admin tokens

Use the below command directly on a bastion/local machine where you have the kubeconfig present
### Quick Generate (Recommended)
```bash
curl -O https://raw.githubusercontent.com/devtron-labs/utilities/main/kubeconfig-exporter/kubernetes_export_sa.sh && bash kubernetes_export_sa.sh cd-user devtroncd https://raw.githubusercontent.com/devtron-labs/utilities/main/kubeconfig-exporter/clusterrole.yaml
```

### Custom Generate
If you want to make some changes to the default configurations, please follow the steps below to generate cluster-admin tokens:
1. Clone the repository https://github.com/devtron-labs/utilities.git
```bash
git clone https://github.com/devtron-labs/utilities.git
```
2. Make sure you're inside `kubeconfig-exporter` folder and run the below command
```bash
bash kubernetes_export_sa.sh cd-user devtroncd clusterrole.yaml
```

> **PS**: If you need to changed the cd-user to anything else, please make sure to edit the same in the `clusterrole.yaml` file too before running the script.