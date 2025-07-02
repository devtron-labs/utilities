
# Devtron Cluster Setup Guide

This guide provides a standardized approach for provisioning a **dedicated Kubernetes cluster for Devtron**, following best practices for reliability, security, and cost-efficiency. Devtron should be deployed in an **isolated cluster**, separate from production workloads, to maintain a clean separation of responsibilities.

---

## Prerequisites (Applicable to All Cloud Providers)

Before provisioning the cluster, ensure the following general infrastructure requirements are met:

### 1. Isolated Kubernetes Cluster
- Devtron must run in its own Kubernetes cluster (not shared with app workloads).
- Supports any CNCF-compliant cluster: EKS, GKE, AKS, self-hosted, etc.

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

If Devtron is managing the cluster setup and lifecycle:

* Provide a **Kubernetes `cd-user` service account** with required RBAC. checke the doc [here](https://github.com/devtron-labs/utilities/tree/main/kubeconfig-exporter#script-to-generate-cluster-admin-tokens)
* Share a **cluster-admin level token** or access credentials securely.
* Devtron Team will manage installation, upgrades, monitoring, and integrations.

---

## Cloud-Specific Configuration: AWS (EKS)

The following section applies **only when using Amazon EKS** as your Kubernetes provider.

### AWS-Specific Requirements

#### 1. IAM Policies for Node Groups

Attach these **AWS-managed IAM policies**:

```yaml
attachPolicyARNs:
  - arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy
  - arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy
  - arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess
  - arn:aws:iam::aws:policy/AmazonEKSClusterPolicy
  - arn:aws:iam::aws:policy/AmazonEKSServicePolicy
  - arn:aws:iam::aws:policy/AmazonS3FullAccess
  - arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
  - arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess
  - arn:aws:iam::<your-account-id>:policy/devtron-cluster-IAM-policy
```
**Optional (Recommended for Least Privilege):**
If you are following **Option 5 (Optional: Custom IAM Policy for devtron-cluster-IAM-policy)**, the `devtron-cluster-IAM-policy` should be used in place of full admin-level S3, ECR, and ELB policies. This improves security posture by granting only the necessary permissions.

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

Create a consolidated IAM policy (`devtron-cluster-IAM-policy`) to grant Devtron access to necessary AWS services:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:*"],
      "Resource": [
        "arn:aws:s3:::<your-bucket-name>",
        "arn:aws:s3:::<your-bucket-name>/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": ["ecr:*"],
      "Resource": "arn:aws:ecr:<region>:<account-id>:repository/<your-ecr-repo>"
    },
    {
      "Effect": "Allow",
      "Action": ["elasticloadbalancing:*"],
      "Resource": "*"
    }
  ]
}
```

> Replace `<your-bucket-name>`, `<region>`, `<account-id>`, and `<your-ecr-repo>` with actual values from your AWS environment.

---


## Support

For onboarding assistance, cluster validation, or enterprise SLAs, please contact the Devtron team via your assigned solutions engineers. 
