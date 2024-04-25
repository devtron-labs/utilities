#!/bin/bash

# PRIVATE
git_sensor=devtroninc.azurecr.io/git-sensor:a9640c46-535-22179
kubelink=devtroninc.azurecr.io/kubelink:036bf511-310-22185
casbin=devtroninc.azurecr.io/casbin:4e6c4bf2-dba5b278-462-21695
ci_runner=quay.io/devtron/ci-runner:158160d5-515-21995
dashboard=devtroninc.azurecr.io/dashboard:ae14bce0-6-22129
devtron=devtroninc.azurecr.io/devtron:25936ba1-4-22063

# PUBLIC
app_sync_job=quay.io/devtron/chart-sync:d0dcc590-132-21155
image_scanner=ghcr.io/devtron-labs/image-scanner:c0416bc2-112-21706
lens=ghcr.io/devtron-labs/lens:70577aaa-19-21169
kubewatch=ghcr.io/devtron-labs/kubewatch:50d4d32d-370-21699


POSTGRES_PASSWORD=$(kubectl -n devtroncd get secret postgresql-postgresql -o jsonpath='{.data.postgresql-password}' | base64 -d)

echo -e "\033[93mPOSTGRES_PASSWORD-:$POSTGRES_PASSWORD\033[0m"


echo "=======ADDING CHANGES TO DEVTRON_CONFIGMAP========"

kubectl patch configmap devtron-cm -n devtroncd --patch '{"data": {"CASBIN_CLIENT_URL": "casbin-service.devtroncd:9000"}}'
kubectl patch configmap devtron-cm -n devtroncd --patch '{"data": {"DEVTRON_INSTALLATION_TYPE": "enterprise"}}'
kubectl patch configmap devtron-custom-cm -n devtroncd --patch "{\"data\": {\"DEFAULT_CI_IMAGE\": \"$ci_runner\"}}"
kubectl patch configmap devtron-custom-cm -n devtroncd --patch "{\"data\": {\"APP_SYNC_IMAGE\": \"$app_sync_job\"}}"
kubectl patch configmap devtron-cm -n devtroncd --patch "{\"data\": {\"IS_INTERNAL_USE\": \"true\"}}"
kubectl patch configmap dashboard-cm -n devtroncd --patch "{\"data\": {\"HIDE_GITOPS_OR_HELM_OPTION\": \"false\"}}"
kubectl patch configmap dashboard-cm -n devtroncd --patch "{\"data\": {\"HIDE_DISCORD\": \"true\"}}"
kubectl patch configmap devtron-custom-cm -n devtroncd --patch "{\"data\": {\"CLONING_MODE\": \"FULL\"}}"

echo "=========================================="

echo -e "adding imagepull secret to deployment devtron \n "
kubectl patch deployment devtron -n devtroncd -p '{"spec": {"template": {"spec": {"imagePullSecrets": [{"name": "devtron-image-pull-enterprise"}]}}}}'

echo "adding imagepull secret to deployment dashboard "
kubectl patch deployment dashboard -n devtroncd -p '{"spec": {"template": {"spec": {"imagePullSecrets": [{"name": "devtron-image-pull-enterprise"}]}}}}'


echo -e "adding imagepull secret to sts git-sensor \n "
kubectl patch sts git-sensor -n devtroncd -p '{"spec": {"template": {"spec": {"imagePullSecrets": [{"name": "devtron-image-pull-enterprise"}]}}}}'

echo "adding imagepull secret to deployment kubelink "
kubectl patch deployment kubelink -n devtroncd -p '{"spec": {"template": {"spec": {"imagePullSecrets": [{"name": "devtron-image-pull-enterprise"}]}}}}'


echo "========ADDING CASBIN MICROSERVICE AND IMAGEPULL SECRET==============="

cat << EOF > casbin-add.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: casbin
    release: casbin
  name: casbin
  namespace: devtroncd
spec:
  minReadySeconds: 60
  replicas: 1
  revisionHistoryLimit: 3
  selector:
    matchLabels:
      app: casbin
      release: casbin
  template:
    metadata:
      labels:
        app: casbin
        release: casbin
    spec:
      containers:
        - env:
            - name: DEVTRON_APP_NAME
              value: casbin
            - name: POD_NAME
              valueFrom:
                fieldRef:
                  fieldPath: metadata.name
          envFrom:
            - configMapRef:
                name: casbin-cm
          image: devtroninc.azurecr.io/casbin:a3ec2dbe-f6ae2c72-462-20683
          imagePullPolicy: IfNotPresent
          livenessProbe:
            failureThreshold: 3
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 20
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 5
          name: casbin
          ports:
            - containerPort: 8080
              name: http
              protocol: TCP
            - containerPort: 9000
              name: app
              protocol: TCP
          readinessProbe:
            failureThreshold: 3
            httpGet:
              path: /health
              port: 8080
            initialDelaySeconds: 20
            periodSeconds: 10
            successThreshold: 1
            timeoutSeconds: 5
          resources:
            limits:
              cpu: 0.5m
              memory: 500Mi
            requests:
              cpu: 0.5m
              memory: 301Mi
          volumeMounts: []
      imagePullSecrets:
        - name: devtron-image-pull-enterprise
      restartPolicy: Always
      serviceAccountName: default
      terminationGracePeriodSeconds: 30
      volumes: []
---
apiVersion: v1
data:
  PG_PASSWORD: $POSTGRES_PASSWORD
  PG_ADDR: postgresql-postgresql.devtroncd
  PG_DATABASE: casbin
  PG_PORT: "5432"
  PG_USER: postgres
kind: ConfigMap
metadata:
  name: casbin-cm
  namespace: devtroncd
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: casbin
    release: casbin
  name: casbin-service
  namespace: devtroncd
spec:
  internalTrafficPolicy: Cluster
  ipFamilies:
    - IPv4
  ipFamilyPolicy: SingleStack
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: http
    - name: app
      port: 9000
      protocol: TCP
      targetPort: app
  selector:
    app: casbin
    release: casbin
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
EOF

kubectl apply -f casbin-add.yaml


echo "===========CASBIN ADDED SUCESSFULLY==================="



kubectl set image deploy/devtron -n devtroncd devtron=$devtron
kubectl set image deploy/dashboard -n devtroncd dashboard=$dashboard
kubectl set image deploy/kubewatch -n devtroncd kubewatch=$kubewatch
kubectl set image deploy/kubelink -n devtroncd kubelink=$kubelink
kubectl set image deploy/lens -n devtroncd lens=$lens
kubectl set image sts/git-sensor -n devtroncd git-sensor=$git_sensor
kubectl set image cronjob/app-sync-cronjob -n devtroncd chart-sync=$app_sync_job
if [ "$(kubectl get deploy -n devtroncd -l app=image-scanner | wc -l)" -gt 0 ]; then   kubectl set image deploy/image-scanner -n devtroncd image-scanner=$image_scanner ; fi
kubectl set image deploy/casbin -n devtroncd casbin=$casbin 




migrator=quay.io/devtron/migrator:v4.16.2

devtron_migration_enabled=true
casbin_migration_enabled=true
lens_migration_enabled=true
git_sensor_migration_enabled=true



echo "============Starting migration==================="

cat << 'EOF' > devtron-migration.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: postgresql-migrate-devtron-$RANDOM
  namespace: devtroncd
spec:
  activeDeadlineSeconds: 1500
  backoffLimit: 20
  suspend: false
  template:
    spec:
      imagePullSecrets:
         - name: devtron-image-pull-enterprise
      containers:
      - command:
        - /bin/sh
        - -c
        - 'if [ "$MIGRATE_TO_VERSION" -eq 0 ]; then migrate -path "$SCRIPT_LOCATION"
               -database postgres://"$DB_USER_NAME":"$DB_PASSWORD"@"$DB_HOST":"$DB_PORT"/"$DB_NAME"?sslmode=disable
               up;  else   echo "$MIGRATE_TO_VERSION"; migrate -path "$SCRIPT_LOCATION"  -database
               postgres://"$DB_USER_NAME":"$DB_PASSWORD"@"$DB_HOST":"$DB_PORT"/"$DB_NAME"?sslmode=disable
               goto "$MIGRATE_TO_VERSION";    fi '
        env:
        - name: SCRIPT_LOCATION
          value: /shared/sql/
        - name: DB_TYPE
          value: postgres
        - name: DB_USER_NAME
          value: postgres
        - name: DB_HOST
          value: postgresql-postgresql.devtroncd
        - name: DB_PORT
          value: "5432"
        - name: DB_NAME
          value: orchestrator
        - name: MIGRATE_TO_VERSION
          value: "0"
        envFrom:
        - secretRef:
            name: postgresql-migrator
        image: $migrator
        imagePullPolicy: IfNotPresent
        name: postgresql-migrate-devtron
        resources: {}
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 1000
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /shared
          name: shared-volume
      dnsPolicy: ClusterFirst
      initContainers:
      - command:
        - /bin/sh
        - -c
        - cp -r /scripts/. /shared/
        image: $devtron
        imagePullPolicy: IfNotPresent
        name: init-devtron
        resources: {}
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 1000
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /shared
          name: shared-volume
      restartPolicy: OnFailure
      schedulerName: default-scheduler
      securityContext:
        fsGroup: 1000
        runAsGroup: 1000
        runAsUser: 1000
      terminationGracePeriodSeconds: 30
      volumes:
      - emptyDir: {}
        name: shared-volume
EOF
cat << 'EOF' > casbin-migration.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: postgresql-migrate-casbin-$RANDOM
  namespace: devtroncd
spec:
  activeDeadlineSeconds: 1500
  backoffLimit: 20
  template:
    spec:
      imagePullSecrets:
         - name: devtron-image-pull-enterprise
      containers:
      - command:
        - sh
        - -c
        - kubectl rollout restart deployment/devtron -n devtroncd && kubectl rollout
          restart deployment/kubelink -n devtroncd
        image: quay.io/devtron/kubectl:latest
        imagePullPolicy: Always
        name: devtron-rollout
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      initContainers:
      - command:
        - /bin/sh
        - -c
        - cp -r /scripts/. /shared/
        image: $devtron
        imagePullPolicy: IfNotPresent
        name: init-devtron
        resources: {}
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 1000
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /shared
          name: shared-volume
      - command:
        - /bin/sh
        - -c
        - 'if [ $(MIGRATE_TO_VERSION) -eq "0" ]; then migrate -path $(SCRIPT_LOCATION)
          -database postgres://$(DB_USER_NAME):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable
          up;  else   echo $(MIGRATE_TO_VERSION); migrate -path $(SCRIPT_LOCATION)  -database
          postgres://$(DB_USER_NAME):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable
          goto $(MIGRATE_TO_VERSION);    fi '
        env:
        - name: SCRIPT_LOCATION
          value: /shared/casbin/
        - name: DB_TYPE
          value: postgres
        - name: DB_USER_NAME
          value: postgres
        - name: DB_HOST
          value: postgresql-postgresql.devtroncd
        - name: DB_PORT
          value: "5432"
        - name: DB_NAME
          value: casbin
        - name: MIGRATE_TO_VERSION
          value: "0"
        envFrom:
        - secretRef:
            name: postgresql-migrator
        image: $migrator
        imagePullPolicy: IfNotPresent
        name: postgresql-migrate-casbin
        resources: {}
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 1000
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /shared
          name: shared-volume
      restartPolicy: OnFailure
      schedulerName: default-scheduler
      securityContext:
        fsGroup: 1000
        runAsGroup: 1000
        runAsUser: 1000
      serviceAccount: devtron
      serviceAccountName: devtron
      terminationGracePeriodSeconds: 30
      volumes:
      - emptyDir: {}
        name: shared-volume
EOF
cat << 'EOF' > git-sensor-migration.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: postgresql-migrate-gitsensor-$RANDOM
  namespace: devtroncd
spec:
  activeDeadlineSeconds: 1500
  backoffLimit: 20
  completionMode: NonIndexed
  completions: 1
  suspend: false
  template:
    spec:
      imagePullSecrets:
         - name: devtron-image-pull-enterprise
      containers:
      - command:
        - /bin/sh
        - -c
        - 'if [ $(MIGRATE_TO_VERSION) -eq "0" ]; then migrate -path $(SCRIPT_LOCATION)
          -database postgres://$(DB_USER_NAME):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable
          up;  else   echo $(MIGRATE_TO_VERSION); migrate -path $(SCRIPT_LOCATION)  -database
          postgres://$(DB_USER_NAME):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable
          goto $(MIGRATE_TO_VERSION);    fi '
        env:
        - name: SCRIPT_LOCATION
          value: /shared/sql/
        - name: DB_TYPE
          value: postgres
        - name: DB_USER_NAME
          value: postgres
        - name: DB_HOST
          value: postgresql-postgresql.devtroncd
        - name: DB_PORT
          value: "5432"
        - name: DB_NAME
          value: git_sensor
        - name: MIGRATE_TO_VERSION
          value: "0"
        envFrom:
        - secretRef:
            name: postgresql-migrator
        image: $migrator
        imagePullPolicy: IfNotPresent
        name: postgresql-migrate-git-sensor
        resources: {}
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 1000
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /shared
          name: shared-volume
      dnsPolicy: ClusterFirst
      initContainers:
      - command:
        - /bin/sh
        - -c
        - cp -r sql /shared/
        image: $git_sensor
        imagePullPolicy: IfNotPresent
        name: init-git-sensor
        resources: {}
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 1000
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /shared
          name: shared-volume
      restartPolicy: OnFailure
      schedulerName: default-scheduler
      securityContext:
        fsGroup: 1000
        runAsGroup: 1000
        runAsUser: 1000
      terminationGracePeriodSeconds: 30
      volumes:
      - emptyDir: {}
        name: shared-volume
EOF
cat << 'EOF' > lens-migration.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: postgresql-migrate-lens-$RANDOM
  namespace: devtroncd
spec:
  activeDeadlineSeconds: 1500
  backoffLimit: 20
  suspend: false
  template:
    spec:
      containers:
      - command:
        - /bin/sh
        - -c
        - 'echo \$(MIGRATE_TO_VERSION); 
          if [ \$(MIGRATE_TO_VERSION) -eq "0" ]; 
          then 
            migrate -path \$(SCRIPT_LOCATION) -database postgres://$(DB_USER_NAME):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable up;  
          else   
             migrate -path \$(SCRIPT_LOCATION)  -database postgres://$(DB_USER_NAME):$(DB_PASSWORD)@$(DB_HOST):$(DB_PORT)/$(DB_NAME)?sslmode=disable goto $(MIGRATE_TO_VERSION);    
          fi '
        env:
        - name: SCRIPT_LOCATION
          value: /shared/sql/
        - name: DB_TYPE
          value: postgres
        - name: DB_USER_NAME
          value: postgres
        - name: DB_HOST
          value: postgresql-postgresql.devtroncd
        - name: DB_PORT
          value: "5432"
        - name: DB_NAME
          value: lens
        - name: MIGRATE_TO_VERSION
          value: "0"
        envFrom:
        - secretRef:
            name: postgresql-migrator
        image: $migrator
        imagePullPolicy: IfNotPresent
        name: postgresql-migrate-lens
        resources: {}
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 1000
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /shared
          name: shared-volume
      dnsPolicy: ClusterFirst
      initContainers:
      - command:
        - /bin/sh
        - -c
        - cp -r sql /shared/
        image: $lens
        imagePullPolicy: IfNotPresent
        name: init-lens
        resources: {}
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 1000
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /shared
          name: shared-volume
      restartPolicy: OnFailure
      schedulerName: default-scheduler
      securityContext:
        fsGroup: 1000
        runAsGroup: 1000
        runAsUser: 1000
      terminationGracePeriodSeconds: 30
      volumes:
      - emptyDir: {}
        name: shared-volume

EOF

arch=$(uname -m)

if [ "$arch" == "x86_64" ]; then
  sed -i "s|\$migrator|$migrator|g" devtron-migration.yaml
  sed -i "s|\$devtron|$devtron|g" devtron-migration.yaml
  sed -i "s|\$RANDOM|$RANDOM|g" devtron-migration.yaml

  sed -i "s|\$migrator|$migrator|g" casbin-migration.yaml
  sed -i "s|\$devtron|$devtron|g" casbin-migration.yaml
  sed -i "s|\$RANDOM|$RANDOM|g" casbin-migration.yaml

  sed -i "s|\$migrator|$migrator|g" git-sensor-migration.yaml
  sed -i "s|\$git_sensor|$git_sensor|g" git-sensor-migration.yaml
  sed -i "s|\$RANDOM|$RANDOM|g" git-sensor-migration.yaml

  sed -i "s|\$migrator|$migrator|g" lens-migration.yaml
  sed -i "s|\$lens|$lens|g" lens-migration.yaml
  sed -i "s|\$RANDOM|$RANDOM|g" lens-migration.yaml
else
  sed -i '' "s|\$migrator|$migrator|g" devtron-migration.yaml
  sed -i '' "s|\$devtron|$devtron|g" devtron-migration.yaml
  sed -i '' "s|\$RANDOM|$RANDOM|g" devtron-migration.yaml

  sed -i '' "s|\$migrator|$migrator|g" casbin-migration.yaml
  sed -i '' "s|\$devtron|$devtron|g" casbin-migration.yaml
  sed -i '' "s|\$RANDOM|$RANDOM|g" casbin-migration.yaml

  sed -i '' "s|\$migrator|$migrator|g" git-sensor-migration.yaml
  sed -i '' "s|\$git_sensor|$git_sensor|g" git-sensor-migration.yaml
  sed -i '' "s|\$RANDOM|$RANDOM|g" git-sensor-migration.yaml

  sed -i '' "s|\$migrator|$migrator|g" lens-migration.yaml
  sed -i '' "s|\$lens|$lens|g" lens-migration.yaml
  sed -i '' "s|\$RANDOM|$RANDOM|g" lens-migration.yaml
fi

if [ "$devtron_migration_enabled" = "true" ]; then
    echo "Running migration for Devtron"
    kubectl apply -f devtron-migration.yaml
fi
if [ "$casbin_migration_enabled" = "true" ]; then
    echo "Running migration for casbin"
    kubectl apply -f casbin-migration.yaml
fi
if [ "$lens_migration_enabled" = "true" ]; then
    echo "Running migration for lens"
    kubectl apply -f lens-migration.yaml
fi
if [ "$git_sensor_migration_enabled" = "true" ]; then
    echo "Running migration for git-sensor"
    kubectl apply -f git-sensor-migration.yaml
fi
