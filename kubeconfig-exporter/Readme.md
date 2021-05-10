## Script to generate Cluster cluster-admin tokens

Use the below command directly on a bastion/local machine where you have the kubeconfig present
```bash
curl -O https://raw.githubusercontent.com/devtron-labs/utilities/main/kubeconfig-exporter/kubernetes_export_sa.sh && bash kubernetes_export_sa.sh cd-user devtroncd https://raw.githubusercontent.com/devtron-labs/utilities/main/kubeconfig-exporter/clusterrole.yaml
```

If you've cloned the repository, mmake sure you're inside kubeconfig-exporter folder and run the below command
```bash
bash kubernetes_export_sa.sh cd-user devtroncd clusterrole.yaml
```

PS: If you need to changed the cd-user to anything else, please make sure to edit the same in the clusterrole.yaml file too before running the script.