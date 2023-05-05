## Script to generate cluster-admin tokens

Use the below command directly on a bastion/local machine where you have the kubeconfig present
### Quick Generate (Recommended)

If you're generating tokens to attach it to a Devtron cluster, create a `devtroncd` namespace in the cluster using the following command:
```bash
kubectl create namespace devtroncd
```
Run the following command to generate the cluster-admin tokens/kubeconfig
```bash
curl -O https://raw.githubusercontent.com/devtron-labs/utilities/main/kubeconfig-exporter/kubernetes_export_sa.sh && bash kubernetes_export_sa.sh cd-user devtroncd
```

### Custom Generate
If you want to make some changes to the default configurations, please follow the steps below to generate cluster-admin tokens:
1. If you're generating tokens to attach it to a Devtron cluster, create a `devtroncd` namespace in the cluster using the following command:
```bash
kubectl create namespace devtroncd
```
2. Clone the repository https://github.com/devtron-labs/utilities.git
```bash
git clone https://github.com/devtron-labs/utilities.git
```
3. Make sure you're inside `kubeconfig-exporter` folder and run the below command
```bash
bash kubernetes_export_sa.sh cd-user devtroncd
```