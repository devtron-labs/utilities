# Creating a Cluster for Devtron Setup

## Prerequisites

- Make sure that the bastion/local machine has appropriate permissions, we recommend using a role/user with Admin permissions, but if you need minimum permissions required to create the cluster, you can refer https://eksctl.io/usage/minimum-iam-policies/
- Install eksctl Refer https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html
- Create 2 s3 buckets for storing cache and logs in the same region where you intend to create Devtron cluster ( Names can be something like s3://organization-devtron-ci-caching (versioning enabled), s3://organization-devtron-ci-logs )
- Create a customPolicy `devtron-cluster-IAM-policy` ( arn:aws:iam::XXXXXXXXXXXXXX:policy/devtron-cluster-IAM-policy ) and give S3FullAccess to the s3 buckets created in previous step and `ElasticLoadBalancingFullAccess` (Devtron creates a Loadbalancer for it's service)
- Create a key pair for your [Amazon EC2 instance](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/create-key-pairs.html).  
  If you prefer to use an existing key pair, update the sample data by modifying the value of `nodeGroups[*].ssh.publicKeyName` with the name of your existing key pair.


## Download the eksctl configs template and Modify

### Already have a VPC where the Devtron Cluster needs to be provisioned
```
wget https://raw.githubusercontent.com/devtron-labs/utilities/main/eksctl-configs/eksctl-devtron-prod-configs.yaml
```

### Let eksctl automatically create a new VPC and subnets
```
https://raw.githubusercontent.com/devtron-labs/utilities/main/eksctl-configs/ekstl-devtron-configs-create-new-vpc.yaml
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
