# Creating a Cluster for Devtron Setup

## Prerequisites

- Make sure that the bastion/local machine has appropriate permissions, we recommend using a role/user with Admin permissions, but if you need minimum permissions required to create the cluster, you can refer https://eksctl.io/usage/minimum-iam-policies/
- Install eksctl Refer https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html
- Create 2 s3 buckets for storing cache and logs in the same region where you intend to create Devtron cluster ( Names can be something like s3://organization-devtron-ci-caching, s3://organization-devtron-ci-logs )
- Create a customPolicy `devtron-cluster-IAM-policy` ( arn:aws:iam::XXXXXXXXXXXXXX:policy/devtron-cluster-IAM-policy ) and give S3FullAccess to the s3 buckets created in previous step.


## Download the eksctl configs template and Modify

```
wget https://raw.githubusercontent.com/devtron-labs/utilities/main/eksctl-configs/eksctl-devtron-prod-configs.yaml
```

Edit the fields prefilled with sample data

- vpc.id
- vpc.subnets.private and vpc.subnets.public
- vpc.clusterEndpoints.publicAccessCIDRs (Include the public IP addresses CIDR that you wish to whitelist for Kubernetes apiserver access, vpc cidr is already whitelisted if vpc.clusterEndpoints.privateAccess is set true) 
- nodeGroups.ssh.publicKeyName for both the nodegroups
- Replace AWS account ID in nodeGroups.iam.attachPolicyARNs ( arn:aws:iam::XXXXXXXXXXXXXX:policy/devtron-cluster-IAM-policy )

The eksctl template shared in the step above is a recommended configuration for devtron setup for Production usage, you can do any other changes according to your customizations if required or get in touch with Devtron Team on Discord https://discord.devtron.ai

## Creating Cluster

```
eksctl create cluster -f eksctl-devtron-prod-configs.yaml
```

### Generating and extracting Kubeconfig

Most versions of eksctl automatically generate the kubeconfig if the cluster creation completes without any errors, you can copy the kubeconfig using the following command
```
cat .kube/config
```

### Manually creating Kubeconfig for a Cluster
```
eksctl utils write-kubeconfig --cluster=<cluster-name>
```


