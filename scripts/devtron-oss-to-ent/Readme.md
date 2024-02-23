# Devtron Enterprise Installation (For evaluation/trials only)

## Pre-requisites:
1. Make sure that the open-source software (OSS) version of Devtron is installed and operational. Refer [install OSS Devtron](https://docs.devtron.ai/install). 
2. Ensure all needed modules are pre-installed in the OSS version before converting it to Enterprise stack. Updating Devtron using Helm or from GUI post enterprise conversion will convert your stack back to OSS. 
3. kubectl should be installed and configured to access the Devtron cluster from the terminal where the following script will be executed. 
4. Throughout the execution of this bash script, ensure appropriate permissions are granted to create files. The script is intended to generate five files for migration YAML and microservice YAML, which will be subsequently applied using kubectl.

## Creating ImagepullSecrets:
1. Ensure to export the username and token variables (issued by Devtron) before proceeding with the next steps.
```bash
export username=XXXXXXXXXXX
export token=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```
### Unrestricted Internet access or Firewall blocks
If the cluster has unrestricted internet access, continue to run the following script. Else, if internet access is restricted via a firewall, please ensure that the domain devtronent.azurecr.io is whitelisted in the firewall.

Run the below command to create the imagepull secret:
```bash
kubectl create secret docker-registry devtron-image-pull-enterprise\
    --namespace devtroncd \
    --docker-server=devtroninc.azurecr.io \
    --docker-username=$username \
    --docker-password=$token
```
### If Air-gapped Cluster 
If the cluster is air-gapped or if whitelisting is not possible, Refer [this document](https://docs.google.com/document/d/1JaLRniL0U6o54YpT3An2_6EsuuCk2CL9y0Qlira2pWc/edit?usp=sharing) for the air-gapped installations.


## Running the script to convert Devtron OSS to enterprise version
Run the following script to convert your cluster from OSS to enterprise:

```bash
curl https://raw.githubusercontent.com/devtron-labs/utilities/main/scripts/devtron-oss-to-ent/devtron-enterprise.sh && bash devtron-enterprise.sh 
```


>>> **PS:** The credentials provided for evaluation or trial purposes will expire once the evaluation or trial period concludes. Please make sure to revert your stack to the OSS version or purchase an enterprise subscription before the trial ends. Continuing to use Devtron enterprise beyond the evaluation period without a valid license may result in a licensing violation.

