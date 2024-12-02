## Usage for Azure Kubernetes Service (AKS)

Install terraform, git and azure-cli in your local system and clone git repository using
```
git clone https://github.com/devtron-labs/utilities.git
```
Now switch to terraform configs and initialize terraform so that it downloads the required plugin
```
cd utilities/terraform-configs/AKS
terraform init
```
Edit `variables.tf` file and changes the names and location of resources to be created.

If you want to have SSH access on your nodes for debugging purpose, add a public key for ssh access under `linux_profile` section or remove the linux_profile section if you don't want it.

Login to your azure account in local system using
```
az login
```
The above command will work if you are able to open browser window on same device or use the command given below for remote bastion
```
az login --use-device-code
```
Once you are authenticated, run `terraform apply` to start creating the cluster. It'll create an AKS cluster with 2 nodepools. 1 on-demand and 1 spot.
Your kubeconfig to access the cluster will be stored in a file named `config` in your current directory. To change the file name, change it in `outputs.tf` file.

Optionally, you can remove blob storage resource from main.tf and variables.tf if you don't want to use devtron with blob storage.
