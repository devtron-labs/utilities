# Creating a Cluster for Devtron Setup

## Prerequisites

- Make sure that the bastion/local machine has appropriate permissions, we recommend using a role/user with Admin permissions, but if you need minimum permissions required to create the cluster, you can refer https://eksctl.io/usage/minimum-iam-policies/
- Install eksctl Refer https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html
- Create 2 s3 buckets for storing cache and logs in the same region where you intend to create Devtron cluster ( Names can be something like s3://organization-devtron-ci-caching (versioning enabled), s3://organization-devtron-ci-logs )
- Create a customPolicy `devtron-cluster-IAM-policy` ( arn:aws:iam::XXXXXXXXXXXXXX:policy/devtron-cluster-IAM-policy ) and give S3FullAccess to the s3 buckets created in previous step and `ElasticLoadBalancingFullAccess` (Devtron creates a Loadbalancer for it's service)

## Clone the repo.
```
git clone https://github.com/devtron-labs/utilities.git
```
## Prerequisites before run the provision script.

- Make sure bastion have aws configured with required permission to provision EKS.
- Make sure bastion have python installed.
- Install `pyyaml` python module by running `pip3 install pyyaml`

## First go inside eksctl-configs folder and run script by `python3 provision-eks.py`

- This script will going to install `helm`, `kubectl`, `eksctl` if these are already installed it will ignore.
- Script will take inputs from users like `cluster-name`, `region`,`eks-version`, `arn of devtron-cluster-IAM-policy` , `key pair name`
- Next it will take input `Do you want to use your existing vpc or not` and value of it either `yes` or `no`. 
- Here if you provide `no` then it will create eks cluster with new vpc.
- Here if you provide `yes` as input it will take input `vpc-id` , `total number of private subnets` 
- Take input `subnet name` and its `subnet id` for private subnets. 
- Next input `total number of public subnets`.
- Next input `subnet name` and its `subnet id` after that it will provision eks with existing vpc and subnets which are provided.


### Manually creating Kubeconfig for a Cluster

Most versions of eksctl automatically generate the kubeconfig if the cluster creation completes without any errors, you can copy the kubeconfig using the following command

```
cat .kube/config
```

If no kubeconfig is generated, you can generate it using the command below.

```
eksctl utils write-kubeconfig --cluster <cluster-name> --region <region>
```

### Generating token based Kubeconfig

Ensure that you have kubeconfig already set and are able to access the cluster. Generate the cluster-admin token based kube-config. Please ensure that you have `kubectl` and `jq` installed on the bastion that you’re running the commands on.

```
curl -O https://raw.githubusercontent.com/devtron-labs/utilities/main/kubeconfig-exporter/kubernetes_kubeconfig_sa.sh && bash kubernetes_kubeconfig_sa.sh cd-user devtroncd https://raw.githubusercontent.com/devtron-labs/utilities/main/kubeconfig-exporter/clusterrole.yaml
```
