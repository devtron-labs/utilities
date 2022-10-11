current_version=$(helm ls -n devtroncd -o json | grep -Po '"chart":.*?[^\\]"' | awk -F'[:]' '{print $2}' | awk -F'[-"]' '{print $4}')
legacy_version=$(echo "$current_version 0.22.38" | awk '{print ($1 < $2)}')
kubectl get deploy inception -n devtroncd
if [ $(echo $?) -eq 1 ]
then
echo "Found Devtron without CICD - Upgrading to latest version"
kubectl create ns argo
kubectl create ns devtron-ci
kubectl create ns devtron-cd
helm repo update
if [ $legacy_version -eq 1 ]
then
helm upgrade $RELEASE_NAME devtron/devtron-operator -n devtroncd -f https://raw.githubusercontent.com/devtron-labs/devtron/main/charts/devtron/values.yaml --reuse-values --set installer.arch="legacy"
else
helm upgrade $RELEASE_NAME devtron/devtron-operator -n devtroncd -f https://raw.githubusercontent.com/devtron-labs/devtron/main/charts/devtron/values.yaml --reuse-values
fi
else
echo "Found Devtron with CICD - Upgrading to latest version. Please ignore any errors you observe during upgrade"
sleep 3
kubectl -n devtroncd label all --all "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl -n devtroncd annotate all --all "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl -n devtroncd label secret --all "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl -n devtroncd annotate secret --all "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl -n devtroncd label cm --all "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl -n devtroncd annotate cm --all "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl -n devtroncd label sa --all "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl -n devtroncd annotate sa --all "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl -n devtroncd label role --all "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl -n devtroncd annotate role --all "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl -n devtroncd label rolebinding --all "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl -n devtroncd annotate rolebinding --all "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrole argocd-application-controller "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrole argocd-application-controller "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrolebinding argocd-application-controller "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrolebinding argocd-application-controller "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrole argocd-server "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrole argocd-server "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrolebinding argocd-server "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrolebinding argocd-server "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrole devtron-kubernetes-external-secrets "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrole devtron-kubernetes-external-secrets "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrolebinding devtron-kubernetes-external-secrets "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrolebinding devtron-kubernetes-external-secrets "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrole devtron-grafana-clusterrole "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrole devtron-grafana-clusterrole "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrolebinding devtron-grafana-clusterrole "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrolebinding devtron-grafana-clusterrole "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrole nats-server "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrole nats-server "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrolebinding nats-server "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrolebinding nats-server "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrole argo-rollouts-aggregate-to-admin "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrole argo-rollouts-aggregate-to-admin "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrolebinding argo-rollouts-aggregate-to-admin "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrolebinding argo-rollouts-aggregate-to-admin "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrole argo-rollouts-aggregate-to-edit "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrole argo-rollouts-aggregate-to-edit "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrolebinding argo-rollouts-aggregate-to-edit "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrolebinding argo-rollouts-aggregate-to-edit "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrole argo-aggregate-to-view "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrole argo-aggregate-to-view "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrolebinding argo-aggregate-to-view "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrolebinding argo-aggregate-to-view "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrole argo-cluster-role "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrole argo-cluster-role "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrolebinding argo-cluster-role "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrolebinding argo-cluster-role "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrole argo-rollouts-aggregate-to-view "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrole argo-rollouts-aggregate-to-view "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrolebinding argo-rollouts-aggregate-to-view "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrolebinding argo-rollouts-aggregate-to-view "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrole argo-rollouts-clusterrole "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrole argo-rollouts-clusterrole "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrolebinding argo-rollouts-clusterrole "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrolebinding argo-rollouts-clusterrole "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrole workflow-cluster-role "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrole workflow-cluster-role "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrolebinding workflow-cluster-role "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrolebinding workflow-cluster-role "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrole argo-ui-cluster-role "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrole argo-ui-cluster-role "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrolebinding argo-ui-cluster-role "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrolebinding argo-ui-cluster-role "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label sa argo -n argo "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate sa argo -n argo "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label role argo-role -n argo "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate role argo-role -n argo "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label rolebinding argo-binding -n argo "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate rolebinding argo-binding -n argo "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label cm workflow-controller-configmap -n argo "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate cm workflow-controller-configmap -n argo "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label deploy workflow-controller -n argo "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate deploy workflow-controller -n argo "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl -n devtron-cd label secret --all "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl -n devtron-cd annotate secret --all "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl -n devtron-ci label secret --all "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl -n devtron-ci annotate secret --all "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label ns argo "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate ns argo "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label ns devtron-ci "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate ns devtron-ci "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label ns devtron-cd "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate ns devtron-cd "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label crd workflows.argoproj.io "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate crd workflows.argoproj.io "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label crd workflowtemplates.argoproj.io "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate crd workflowtemplates.argoproj.io "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrole argo-aggregate-to-admin "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrole argo-aggregate-to-admin "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrole argo-aggregate-to-edit "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrole argo-aggregate-to-edit "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrole argo-binding "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrole argo-binding "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrolebinding argo-aggregate-to-admin "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrolebinding argo-aggregate-to-admin "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrolebinding argo-aggregate-to-edit "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrolebinding argo-aggregate-to-edit "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrolebinding argo-binding "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrolebinding argo-binding "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl -n devtroncd label PodSecurityPolicy --all "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl -n devtroncd annotate --all PodSecurityPolicy "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl -n devtroncd label pvc --all "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl -n devtroncd annotate pvc --all "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrole devtron-grafana-clusterrole "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrole devtron-grafana-clusterrole "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label clusterrolebinding devtron-grafana-clusterrolebinding "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate clusterrolebinding devtron-grafana-clusterrolebinding "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label crd applications.argoproj.io "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate crd applications.argoproj.io "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label crd applicationsets.argoproj.io "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate crd applicationsets.argoproj.io "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label crd argocdextensions.argoproj.io "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate crd argocdextensions.argoproj.io "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl label crd appprojects.argoproj.io "app.kubernetes.io/managed-by=Helm" --overwrite
kubectl annotate crd appprojects.argoproj.io "meta.helm.sh/release-name=$RELEASE_NAME" "meta.helm.sh/release-namespace=devtroncd" --overwrite
kubectl delete sts argocd-application-controller -n devtroncd
kubectl delete deploy argocd-redis argocd-repo-server argocd-server -n devtroncd
provider=$(kubectl -n devtroncd get cm devtron-cm -o jsonpath='{.data.BLOB_STORAGE_PROVIDER}')
helm repo update
if [ "$provider" = "MINIO" ]
then
echo "Found Blob Storage Provider as Minio"
minioAccessKey=$(kubectl -n devtroncd get secret devtron-minio -o jsonpath='{.data.accesskey}' | base64 -d)
minioSecretKey=$(kubectl -n devtroncd get secret devtron-minio -o jsonpath='{.data.secretkey}' | base64 -d)
if [ $legacy_version -eq 1 ]
then
helm upgrade $RELEASE_NAME devtron/devtron-operator -n devtroncd -f https://raw.githubusercontent.com/devtron-labs/devtron/main/charts/devtron/values.yaml --reuse-values --set configs.BLOB_STORAGE_PROVIDER="S3" --set configs.BLOB_STORAGE_S3_ENDPOINT="http://devtron-minio.devtroncd:9000" --set-string configs.BLOB_STORAGE_S3_ENDPOINT_INSECURE="true" --set secrets.BLOB_STORAGE_S3_ACCESS_KEY=$minioAccessKey --set secrets.BLOB_STORAGE_S3_SECRET_KEY=$minioSecretKey --set configs.DEFAULT_BUILD_LOGS_BUCKET="devtron-ci-log" --set configs.DEFAULT_CACHE_BUCKET="devtron-ci-cache" --set installer.modules={cicd} --set argo-cd.enabled=true --set security.enabled=true --set security.clair.enabled=true --set monitoring.grafana.enabled=true --set notifier.enabled=true --set installer.arch="legacy"
else
helm upgrade $RELEASE_NAME devtron/devtron-operator -n devtroncd -f https://raw.githubusercontent.com/devtron-labs/devtron/main/charts/devtron/values.yaml --reuse-values --set configs.BLOB_STORAGE_PROVIDER="S3" --set configs.BLOB_STORAGE_S3_ENDPOINT="http://devtron-minio.devtroncd:9000" --set-string configs.BLOB_STORAGE_S3_ENDPOINT_INSECURE="true" --set secrets.BLOB_STORAGE_S3_ACCESS_KEY=$minioAccessKey --set secrets.BLOB_STORAGE_S3_SECRET_KEY=$minioSecretKey --set configs.DEFAULT_BUILD_LOGS_BUCKET="devtron-ci-log" --set configs.DEFAULT_CACHE_BUCKET="devtron-ci-cache" --set installer.modules={cicd} --set argo-cd.enabled=true --set security.enabled=true --set security.clair.enabled=true --set monitoring.grafana.enabled=true --set notifier.enabled=true
fi
else
echo "Blob Storage Provider - $provider"
if [ $legacy_version -eq 1 ]
then
helm upgrade $RELEASE_NAME devtron/devtron-operator -n devtroncd -f https://raw.githubusercontent.com/devtron-labs/devtron/main/charts/devtron/values.yaml --reuse-values --set installer.modules={cicd} --set configs.BLOB_STORAGE_PROVIDER=$provider --set argo-cd.enabled=true --set security.enabled=true --set security.clair.enabled=true --set monitoring.grafana.enabled=true --set notifier.enabled=true --set installer.arch="legacy"
else
helm upgrade $RELEASE_NAME devtron/devtron-operator -n devtroncd -f https://raw.githubusercontent.com/devtron-labs/devtron/main/charts/devtron/values.yaml --reuse-values --set installer.modules={cicd} --set configs.BLOB_STORAGE_PROVIDER=$provider --set argo-cd.enabled=true --set security.enabled=true --set security.clair.enabled=true --set monitoring.grafana.enabled=true --set notifier.enabled=true
fi
fi
fi
