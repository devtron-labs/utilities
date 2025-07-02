# Devtron Cluster Setup Guide

This guide provides a standardized approach for provisioning a **dedicated Kubernetes cluster for Devtron**, following best practices for reliability, security, and cost-efficiency. Devtron should be deployed in an **isolated cluster**, separate from production workloads, to maintain a clean separation of responsibilities.

---

## Prerequisites (Applicable to All Cloud Providers)

Before provisioning the cluster, ensure the following general infrastructure requirements are met:

### 1. Isolated Kubernetes Cluster
- Devtron must run in its own Kubernetes cluster (not shared with app workloads).
- Supports any cluster: EKS, GKE, AKS, self-hosted, etc.

### 2. Node Group Configuration
Provision **two separate node groups**:

#### a. `devtron-workloads` (On-Demand Instances)
- Runs Devtron's core services and application workloads.

#### b. `ci-workloads` (Spot or Preemptible Instances)
- Runs CI pipeline workloads to reduce infrastructure cost.

Apply the following labels and taints to the CI node group:

```yaml
labels:
  purpose: ci

taints:
  - key: dedicated
    value: ci
    effect: NoSchedule
``` 

###  3. Object Storage Buckets

Create **three buckets** in your cloud provider’s object storage (e.g., S3, GCS, Azure Blob):

* For CI logs (devtron-ci-logs)
* For CI cache artifacts (devtron-ci-cache)
* For backups (devtron-backup)

Ensure node groups have access to:

* Read/write to the designated buckets (get/put/list permissions).
#### CI Cache and backups Retention (Recommended):

* Configure **lifecycle rules** or **retention policies** on the CI cache bucket and backups to:

  * Automatically **expire old object** (e.g., after 7–30 days)
  * Optimize storage cost


### 4. Persistent Storage & CSI Drivers

* Install appropriate **CSI drivers** (EBS for AWS, PD for GCP, Disk for Azure) to support dynamic PVC provisioning.
* Ensure PVC provisioning is allowed for all namespaces.

### 5. Load Balancer Support

* Node groups should have permission to provision cloud-native **LoadBalancers** for:
  * Devtron Dashboard

### 6. Optional: VPC Endpoints / Private Access

To reduce cost and enhance network performance:

* Configure VPC endpoints (e.g., for S3, container registry).
* Use private access configurations where possible.

---

## Access for Devtron Team (If Using Managed Deployment)

If Devtron Team is managing the cluster setup and lifecycle:

* Provide a **Kubernetes `cd-user` service account** with the required RBAC permissions for Devtron installation and management. For step-by-step instructions on generating a secure cluster-admin token and exporting kubeconfig for this service account, refer to the [kubeconfig-exporter documentation](https://github.com/devtron-labs/utilities/tree/main/kubeconfig-exporter#script-to-generate-cluster-admin-tokens).
* Share a **cluster-admin level token** or access credentials securely using [https://enclosed.devtron.ai/](https://enclosed.devtron.ai/).
* Devtron Team will manage installation, upgrades, monitoring, and integrations.

---

## Cloud-Specific Configuration: AWS (EKS)

The following section applies **only when using Amazon EKS** as your Kubernetes provider.

### AWS-Specific Requirements

#### 1. IAM Policies for Node Groups

Attach these **AWS-managed IAM policies** as required for your use case:

```yaml
attachPolicyARNs:
  - arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
  - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
  - arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
  - arn:aws:iam::aws:policy/AmazonEKSServicePolicy
  - arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
  # Add the following based on your requirements:
  # For full access (not recommended for production):
  - arn:aws:iam::aws:policy/AmazonS3FullAccess
  - arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess
  - arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess
  # For least privilege, use custom policies as described in Option 5 below:
  - arn:aws:iam::<your-account-id>:policy/devtron-cluster-IAM-policy 
```
**Optional (Recommended for Least Privilege):**
If you are following **[Option 5 (Optional: Custom IAM Policy for devtron-cluster-IAM-policy)](#5-optional-custom-iam-policy-for-devtron-cluster-iam-policy)**, you can attach only the required custom policies (S3, ECR, ELB) instead of full admin-level policies. This improves security posture by granting only the necessary permissions. See [Option 5 details below](#5-optional-custom-iam-policy-for-devtron-cluster-iam-policy) for how to create and use these policies.

#### 2. EBS CSI Driver

* Install and configure the **Amazon EBS CSI driver** for PVC support.

#### 3. S3 Bucket Access

* Provide full access to relevant buckets (logs, backups, CI cache).
* Minimum actions: `s3:GetObject`, `s3:PutObject`, `s3:ListBucket`.

#### 4. Optional: VPC Endpoints

Recommended for reducing NAT Gateway costs:

* S3
* ECR (API & DKR)
* EC2 (optional)

#### 5. Optional: Custom IAM Policy for devtron-cluster-IAM-policy 

You can create separate IAM policies for S3, ECR, and ELB access, and attach only what is needed for your use case. Below are example policies for each:

**a) S3 Access Only**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:*"] ,
      "Resource": [
        "arn:aws:s3:::<your-logs-bucket>",
        "arn:aws:s3:::<your-logs-bucket>/*",
        "arn:aws:s3:::<your-ci-cache-bucket>",
        "arn:aws:s3:::<your-ci-cache-bucket>/*",
        "arn:aws:s3:::<your-backup-bucket>",
        "arn:aws:s3:::<your-backup-bucket>/*"
      ]
    }
  ]
}
```

**b) ECR Access Only**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ecr:*"] ,
      "Resource": "arn:aws:ecr:<region>:<account-id>:repository/<your-ecr-repo>"
    }
  ]
}
```

**c) ELB Access Only**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["elasticloadbalancing:*"] ,
      "Resource": "*"
    }
  ]
}
```

> Replace placeholders (`<your-bucket-name>`, `<region>`, `<account-id>`, `<your-ecr-repo>`) with your actual AWS values.

You can combine these policies as needed, or keep them separate for more granular control.

---
## Support
For onboarding assistance, cluster validation, or enterprise SLAs, please contact the Devtron team via your assigned solutions engineers.