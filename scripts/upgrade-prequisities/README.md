# Devtron Upgrade Process Documentation

This document outlines the step-by-step process to Pre-Requisites required before upgrading Devtron to <version>.

## Overview of the Process

The upgrade process consists of three sequential Kubernetes jobs:

1. **devtron-pre-upgrade**: Prepares the environment for the upgrade
2. **devtron-upgrade-init**: Scales down the Devtron and starts the migration process.
3. **devtron-upgrade**: Performs the actual database migration and restores the system

## Prerequisites

- Ensure that you have deployed the Devtron-Backup-Chart and atleast one backup is pushed successfully.
- Adminsistrative access to the Cluster on which Devtron is running with `kubectl` configured
- PVC Creation is not blocked by any Policy, if it is then exclude `devtroncd` namespace from it.

## Step 1: Apply the Pre-Upgrade Job

The pre-upgrade job creates necessary resources and prepares for the database backup.

```bash
# Apply the devtron-pre-upgrade job
kubectl apply -f devtron-pre-upgrade.yaml
```

This job will:
1. Create a ConfigMap named `devtron-postgres-upgrade` in the `devtroncd` namespace.
2. Determine the StorageClass and size of the existing PostgreSQL PVC
3. Create a new PVC named `devtron-db-upgrade-pvc` with additional storage (+5Gi).
4. Automatically apply the upgrade-init job

To monitor the progress of this job:

```bash
kubectl logs -f job/devtron-pre-upgrade -n devtroncd
```

Wait for this job to complete successfully before proceeding.

## Step 2: Monitor the Upgrade-Init Job

The upgrade-init job is automatically triggered by the pre-upgrade job. This job:
1. Scales down all Devtron components to ensure database consistency
2. Terminates active database connections
3. Starts the Postgres migration Process.

To monitor the progress of this job:

```bash
kubectl logs -f job/devtron-upgrade-init -n devtroncd
```

The job will indicate when the "First Checkpoint" is reached. Ensure this job completes successfully before proceeding to the next step.


The value should be "true" if the Upgrade-Init Job was successful.

### Troubleshooting



## Step 3: Apply the Upgrade Job

Once the backup is confirmed, apply the final upgrade job:

```bash
kubectl apply -f devtron-upgrade.yaml
```

This job will:
1. Verify if the Upgrade-Init Job was successful
2. Extract any nodeSelectors or tolerations from the existing PostgreSQL deployment
3. Remove the PostgreSQL 11 components
4. Install PostgreSQL 14 with the same configuration
5. Migrate the Data.
6. Scale up all Devtron components

To monitor the progress of this job:

```bash
kubectl logs -f job/devtron-upgrade -n devtroncd
```

## Verifying the Upgrade

After the upgrade job completes, verify the PostgreSQL migration:

```bash
# Check if all pods are running
kubectl get pods -n devtroncd

# Verify PostgreSQL version (should now be 14)
kubectl get configmap devtron-postgres-upgrade -n devtroncd -o jsonpath="{.data.POSTGRES_MIGRATED}"
```

The value of `POSTGRES_MIGRATED` should be "14" if the migration was successful.

## Potential Issues and Troubleshooting

### Job Failure

1. If the devtron-upgrade-init or the devtron-upgrade job fails, check the logs of job and ConfigMap for error messages:

```bash
kubectl get configmap devtron-postgres-upgrade -n devtroncd -o yaml
```

Look for any entries with "ERROR" in the keys.

2. To reapply the devtron-upgrade-init job, delete the pvc named `devtron-db-upgrade-pvc`, re-create it with the same configurations and then reapply the devtron-upgrade-init job.

3. If the devtron-upgrade-init job is in pending state then check for the PVC named `devtron-db-upgrade-pvc` ensure that the PVC is successfully created.

## Next Steps

Once the database migration is complete, you can proceed with upgrading the Devtron application through the UI as mentioned in the final message of the upgrade job.