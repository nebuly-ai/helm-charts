# Nebuly Platform

![Version: 1.22.0](https://img.shields.io/badge/Version-1.22.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

Helm chart for installing Nebuly's Platform on Kubernetes.

**Homepage:** <https://nebuly.com>

## Installation

1. Create a namespace for the deployment.

```bash
kubectl create namespace nebuly
```

2. Create an image pull secret to access the Nebuly Platform Docker images, using
the `dockerfile.json` provided by Nebuly.

```bash
kubectl create secret docker-registry \
    nebuly-docker-pull \
    --from-file=.dockerconfigjson=dockerfile.json \
    --namespace nebuly
```

3. Include the created secret in the `imagePullSecrets` field of the `values.yaml` file.

```yaml
imagePullSecrets:
  - name: nebuly-docker-pull
```

4. Install the chart
You can install the chart with the following command:

```bash
helm install oci://ghcr.io/nebuly-ai/helm-charts/nebuly-platform \
  --namespace nebuly \
  --generate-name \
  -f values.yaml
```

## Exposing the services to the Internet

To expose the Platform services to the Internet, you need to specify the Ingress configurations of each
service in the `values.yaml` file. You can expose the following services:

* `frontend`: the Platform frontend application
* `authService`: endpoints used for authentication and authorization
* `backend`: the Platform backend APIs used by the frontend
* `eventIngestion`: the Platform event ingestion APIs, used for receiving events and interactions.

Below you can find an example configuration for exposing all the services using
[ingress-nginx](https://github.com/kubernetes/ingress-nginx) as ingress
controller and [cert-manager](https://github.com/cert-manager/cert-manager) for managing SSL certificates.

The configuration below exposes the services using the following domains:
* `platform.example.nebuly.com`: the frontend application
* `backend.example.nebuly.com`: the backend APIs
* `backend.example.nebuly.com/auth`: the authentication and authorization endpoints
* `backend.example.nebuly.com/event-ingestion`: the event ingestion APIs

<details>
<summary> <b> Example values for ingress configuration </b> </summary>

```yaml
backend:
  ingress:
    enabled: true
    className: nginx
    annotations:
        cert-manager.io/cluster-issuer: letsencrypt
    tls:
      - hosts:
          - backend.example.nebuly.com
        secretName: tls-secret-backend
    hosts:
      - host: backend.example.nebuly.com
        paths:
          - path: /api
            pathType: Prefix

frontend:
  backendApiUrl: https://backend.example.nebuly.com
  rootUrl: https://platform.example.nebuly.com
  authApiUrl: https://backend.example.nebuly.com/auth

  ingress:
    enabled: true
    className: nginx
    annotations:
        cert-manager.io/cluster-issuer: letsencrypt
    tls:
      - hosts:
          - platform.example.nebuly.com
        secretName: tls-secret-frontend
    hosts:
      - host: platform.example.nebuly.com
        paths:
          - path: /
            pathType: Prefix

eventIngestion:
  ingress:
    enabled: true
    className: nginx
    annotations:
        nginx.ingress.kubernetes.io/use-regex: "true"
        nginx.ingress.kubernetes.io/rewrite-target: $1
        cert-manager.io/cluster-issuer: letsencrypt
    tls:
      - hosts:
          - backend.example.nebuly.com
        secretName: tls-secret-backend
    hosts:
      - host: backend.example.nebuly.com
        paths:
          - path: /event-ingestion(/|$)(.*)
            pathType: Prefix

authService:
  ingress:
    enabled: true
    className: nginx
    annotations:
        cert-manager.io/cluster-issuer: letsencrypt
    tls:
      - hosts:
          - backend.example.nebuly.com
        secretName: tls-secret-backend
    hosts:
      - host: backend.example.nebuly.com
        paths:
          - path: /auth
            pathType: Prefix
```
</details>

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
helm uninstall my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| aiModels | object | `{"aws":{"bucketName":""},"azure":{"managedIdentityClientId":"","storageAccountName":"","storageContainerName":"","tenantId":""},"azureml":{"clientId":"","clientSecret":"","existingSecret":{"clientIdKey":"","clientSecretKey":"","name":""},"resourceGroup":"","subscriptionId":"","tenantId":"","workspace":""},"gcp":{"bucketName":"","projectName":""},"modelActionClassifier":{"name":"action-classifier","version":"6"},"modelEmbeddingIntents":{"name":"intent-embedding","version":3},"modelEmbeddingTopic":{"name":"topic-embedding","version":4},"modelEmbeddingWarnings":{"name":"warning-embedding","version":1},"modelInferenceInteractions":{"name":"interaction-analyzer-7b-v2","version":17},"modelTopicClassifier":{"name":"topic-classifier","version":"4"},"registry":"","sync":{"affinity":{},"enabled":false,"image":{"pullPolicy":"IfNotPresent","repository":"ghcr.io/nebuly-ai/nebuly-models-sync","tag":"v0.2.0"},"nodeSelector":{},"podAnnotations":{},"podLabels":{},"podSecurityContext":{"runAsNonRoot":true},"resources":{"limits":{"memory":"8Gi"},"requests":{"memory":"4Gi"}},"schedule":"0 23 * * *","securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"runAsNonRoot":true},"source":{"clientId":"","clientSecret":"","existingSecret":{"clientIdKey":"","clientSecretKey":"","name":""}},"tolerations":[],"volumeMounts":[],"volumes":[]}}` | Settings of the AI models used for inference. |
| aiModels.aws | object | - | Config of the AWS S3 model registry. |
| aiModels.azure | object | - | Config of the Azure Storage model registry. |
| aiModels.azure.managedIdentityClientId | string | `""` | The client ID of the Azure managed identity used to access the Azure Storage account. |
| aiModels.azure.storageAccountName | string | `""` | The name of the Azure Storage account. |
| aiModels.azure.storageContainerName | string | `""` | The name of the Azure Storage container. |
| aiModels.azure.tenantId | string | `""` | The tenant ID of the Azure account. |
| aiModels.azureml | object | - | Config of the Azure Machine Learning model registry. |
| aiModels.azureml.clientId | string | `""` | The client ID of the Azure AD application used to access the Azure Machine Learning Workspace. |
| aiModels.azureml.clientSecret | string | `""` | The client secret of the Azure AD application used to access the Azure Machine Learning Workspace. |
| aiModels.azureml.existingSecret | object | - | Use an existing secret for the AzureML authentication. |
| aiModels.azureml.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| aiModels.azureml.resourceGroup | string | `""` | The name of the Azure resource group containing the Azure Machine Learning Workspace. |
| aiModels.azureml.subscriptionId | string | `""` | The subscription ID of the Azure Machine Learning Workspace. |
| aiModels.azureml.tenantId | string | `""` | The ID of the Azure Tenant where the Azure Machine Learning Workspace is located. To be provided only when not using an existing secret (see azureml.existingSecret value below). |
| aiModels.azureml.workspace | string | `""` | The name of the Azure Machine Learning Workspace. |
| aiModels.gcp | object | - | Config of the AWS S3 model registry. |
| aiModels.gcp.bucketName | string | `""` | The name of the GCP bucket. |
| aiModels.gcp.projectName | string | `""` | The name of the GCP project containing the bucket. |
| aiModels.registry | string | `""` | Available values are: "azure_ml", "aws_s3", "azure_storage", "gcp_bucket" |
| aiModels.sync | object | - | to your registry. |
| aiModels.sync.enabled | bool | `false` | Enable or disable the Sync Job. Default is false for compatibility reasons. |
| aiModels.sync.schedule | string | `"0 23 * * *"` | The schedule of the job. The format is the same as the Kubernetes CronJob schedule. |
| aiModels.sync.source | object | `{"clientId":"","clientSecret":"","existingSecret":{"clientIdKey":"","clientSecretKey":"","name":""}}` | Source Nebuly models registry. |
| aiModels.sync.source.existingSecret | object | - | Use an existing secret for the AzureML authentication. |
| aiModels.sync.source.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| aiModels.sync.volumeMounts | list | `[]` | Additional volumeMounts |
| aiModels.sync.volumes | list | `[]` | Additional volumes |
| analyticDatabase.existingSecret | object | - | Use an existing secret for the database authentication. |
| analyticDatabase.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| analyticDatabase.name | string | `"analytics"` | The name of the database used to store analytic data (interactions, actions, etc.). To be provided only when not using an existing secret (see analyticDatabase.existingSecret value below). |
| analyticDatabase.password | string | `""` | The password for the database user. To be provided only when not using an existing secret (see analyticDatabase.existingSecret value below). |
| analyticDatabase.server | string | `""` | The host of the database used to store analytic data. |
| analyticDatabase.user | string | `""` | The user for connecting to the database. |
| annotations | object | `{}` | Extra annotations that will be added to all resources. |
| auth.addMembersEnabled | bool | `false` | If True, enable the admin panel for inviting new members to the platform. |
| auth.adminUserEnabled | bool | `false` | If true, an initial admin user with username/password login will be created. |
| auth.adminUserPassword | string | `"admin"` | The password of the initial admin user. |
| auth.adminUserUsername | string | `"admin@nebuly.ai"` | The username of the initial admin user. |
| auth.affinity | object | `{}` |  |
| auth.corsAllowOrigins | list | `[]` | If provided, add a CORS middleware to the auth service with the specified origins.  If empty, the CORS middleware will be disabled, and it will be assumed that CORS headers and settings are managed by the Ingress controller. |
| auth.existingSecret | object | - | Use an existing secret for the database authentication. |
| auth.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| auth.fullnameOverride | string | `""` |  |
| auth.image.pullPolicy | string | `"IfNotPresent"` |  |
| auth.image.repository | string | `"ghcr.io/nebuly-ai/nebuly-tenant-registry"` |  |
| auth.image.tag | string | `"v1.13.1"` |  |
| auth.ingress | object | - | Ingress configuration for the login endpoints. |
| auth.jwtSigningKey | string | `""` | Private RSA Key used for signing JWT tokens. Required only if not using an existing secret (see auth.existingSecret value below). |
| auth.loginModes | string | `"password"` | as a comma-separated list. Possible values are: `password`, `microsoft`, `okta`. |
| auth.microsoft | object | - | contains "microsoft". |
| auth.microsoft.clientId | string | `""` | The Client ID (e.g. Application ID) of the Microsoft Entra ID application. To be provided only when not using an existing secret (see microsoft.existingSecret value below). |
| auth.microsoft.clientSecret | string | `""` | The Client Secret of the Microsoft Entra ID application. To be provided only when not using an existing secret (see microsoft.existingSecret value below). |
| auth.microsoft.enabled | bool | `false` | If true, enable Microsoft Entra ID SSO authentication. |
| auth.microsoft.existingSecret | object | - | Use an existing secret for Microsoft Entra ID authentication. |
| auth.microsoft.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| auth.microsoft.redirectUri | string | `""` | The callback URI of the SSO flow. Must be the same as the redirect URI configured for the Microsoft Entra ID application. Must be in the following format: "https://<backend-domain>/auth/oauth/microsoft/callback" Where <backend-domain> is the domain defined in `backend.ingress`. |
| auth.microsoft.tenantId | string | `""` | The ID of the Azure Tenant where the Microsoft Entra ID application is located. |
| auth.nodeSelector | object | `{}` |  |
| auth.okta | object | `{"clientId":"","clientSecret":"","enabled":false,"existingSecret":{"clientIdKey":"","clientSecretKey":"","name":""},"issuer":"","redirectUri":""}` | Okta authentication configuration. Used when `auth.loginModes` contains "okta". |
| auth.okta.clientId | string | `""` | The Client ID of the Okta application. To be provided only when not using an existing secret (see okta.existingSecret value below). |
| auth.okta.clientSecret | string | `""` | The Client Secret of the Okta application. To be provided only when not using an existing secret (see okta.existingSecret value below). |
| auth.okta.existingSecret | object | - | Use an existing secret for Okta SSO authentication. |
| auth.okta.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| auth.okta.issuer | string | `""` | The issuer of the Okta application. |
| auth.okta.redirectUri | string | `""` | The callback URI of the SSO flow. Must be the same as the redirect URI configured for the Okta application. Must be in the following format: "https://<backend-domain>/auth/oauth/microsoft/callback" Where <backend-domain> is the domain defined in `backend.ingress`. |
| auth.podAnnotations | object | `{}` |  |
| auth.podLabels | object | `{}` |  |
| auth.podSecurityContext.runAsNonRoot | bool | `true` |  |
| auth.postgresDatabase | string | `"auth-service"` | The name of the PostgreSQL database used to store user data. |
| auth.postgresPassword | string | `""` | The password for the database user. Required only if not using an existing secret (see auth.existingSecret value below). |
| auth.postgresServer | string | `""` | The host of the PostgreSQL database used to store user data. |
| auth.postgresUser | string | `""` | The user for connecting to the database. Required only if not using an existing secret (see auth.existingSecret value below). |
| auth.replicaCount | int | `1` |  |
| auth.resources.limits.memory | string | `"256Mi"` |  |
| auth.resources.requests.cpu | string | `"100m"` |  |
| auth.resources.requests.memory | string | `"128Mi"` |  |
| auth.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| auth.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| auth.securityContext.runAsNonRoot | bool | `true` |  |
| auth.sentry | object | `{"dsn":"","enabled":false,"environment":"","profilesSampleRate":0,"tracesSampleRate":0}` | Settings of the Sentry integration. |
| auth.sentry.dsn | string | `""` | The DSN of the Sentry project |
| auth.sentry.enabled | bool | `false` | If true, enable the Sentry integration. |
| auth.sentry.environment | string | `""` | The name of the Sentry environment. |
| auth.service.port | int | `80` |  |
| auth.service.type | string | `"ClusterIP"` |  |
| auth.tolerations | list | `[]` |  |
| auth.volumeMounts | list | `[]` |  |
| auth.volumes | list | `[]` |  |
| backend.affinity | object | `{}` |  |
| backend.corsAllowOrigins | list | `[]` | If provided, add a CORS middleware to the auth service with the specified origins.  If empty, the CORS middleware will be disabled, and it will be assumed that CORS headers and settings are managed by the Ingress controller. |
| backend.fullnameOverride | string | `""` |  |
| backend.image.pullPolicy | string | `"IfNotPresent"` |  |
| backend.image.repository | string | `"ghcr.io/nebuly-ai/nebuly-backend"` |  |
| backend.image.tag | string | `"v1.45.0"` |  |
| backend.ingress.annotations | object | `{}` |  |
| backend.ingress.className | string | `""` |  |
| backend.ingress.enabled | bool | `false` |  |
| backend.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| backend.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| backend.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| backend.ingress.tls | list | `[]` |  |
| backend.nodeSelector | object | `{}` |  |
| backend.podAnnotations | object | `{}` |  |
| backend.podLabels | object | `{}` |  |
| backend.podSecurityContext.runAsNonRoot | bool | `true` |  |
| backend.replicaCount | int | `1` |  |
| backend.resources.limits.memory | string | `"1024Mi"` |  |
| backend.resources.requests.cpu | string | `"100m"` |  |
| backend.rootPath | string | `""` | Example: "/backend-service" |
| backend.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| backend.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| backend.securityContext.runAsNonRoot | bool | `true` |  |
| backend.sentry | object | `{"dsn":"","enabled":false,"environment":"","profilesSampleRate":0,"tracesSampleRate":0}` | Settings of the Sentry integration. |
| backend.sentry.dsn | string | `""` | The DSN of the Sentry project |
| backend.sentry.enabled | bool | `false` | If true, enable the Sentry integration. |
| backend.sentry.environment | string | `""` | The name of the Sentry environment. |
| backend.service.port | int | `80` |  |
| backend.service.type | string | `"ClusterIP"` |  |
| backend.tolerations | list | `[]` |  |
| backend.volumeMounts | list | `[]` |  |
| backend.volumes | list | `[]` |  |
| bootstrap-aws | object | `{"enabled":false}` | - an EKS cluster on AWS. |
| bootstrap-azure | object | `{"enabled":false}` | - an AKS cluster on Microsoft Azure. |
| bootstrap-gcp | object | `{"enabled":false}` | - an GKE cluster on Google Cloud Platform. |
| clusterIssuer | object | `{"email":"support@nebuly.ai","enabled":false,"name":"letsencrypt"}` | Optional cert-manager cluster issuer. @default -- |
| eventIngestion.affinity | object | `{}` |  |
| eventIngestion.fullnameOverride | string | `""` |  |
| eventIngestion.image.pullPolicy | string | `"IfNotPresent"` |  |
| eventIngestion.image.repository | string | `"ghcr.io/nebuly-ai/nebuly-event-ingestion"` |  |
| eventIngestion.image.tag | string | `"v1.9.4"` |  |
| eventIngestion.ingress.annotations | object | `{}` |  |
| eventIngestion.ingress.className | string | `""` |  |
| eventIngestion.ingress.enabled | bool | `false` |  |
| eventIngestion.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| eventIngestion.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| eventIngestion.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| eventIngestion.ingress.tls | list | `[]` |  |
| eventIngestion.nodeSelector | object | `{}` |  |
| eventIngestion.podAnnotations | object | `{}` |  |
| eventIngestion.podLabels | object | `{}` |  |
| eventIngestion.podSecurityContext.runAsNonRoot | bool | `true` |  |
| eventIngestion.replicaCount | int | `1` |  |
| eventIngestion.resources.limits.memory | string | `"1024Mi"` |  |
| eventIngestion.resources.requests.cpu | string | `"100m"` |  |
| eventIngestion.rootPath | string | `""` | Example: "/backend-service" |
| eventIngestion.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| eventIngestion.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| eventIngestion.securityContext.runAsNonRoot | bool | `true` |  |
| eventIngestion.sentry | object | `{"dsn":"","enabled":false,"environment":"","profilesSampleRate":0,"tracesSampleRate":0}` | Settings of the Sentry integration. |
| eventIngestion.sentry.dsn | string | `""` | The DSN of the Sentry project |
| eventIngestion.sentry.enabled | bool | `false` | If true, enable the Sentry integration. |
| eventIngestion.sentry.environment | string | `""` | The name of the Sentry environment. |
| eventIngestion.service.port | int | `80` |  |
| eventIngestion.service.type | string | `"ClusterIP"` |  |
| eventIngestion.tolerations | list | `[]` |  |
| eventIngestion.volumeMounts | list | `[]` |  |
| eventIngestion.volumes | list | `[]` |  |
| frontend.affinity | object | `{}` |  |
| frontend.authApiUrl | string | `""` | The URL of the API used for authentication (login, SSO, etc.). |
| frontend.backendApiUrl | string | `""` | The URL of the Backend API to which Frontend will make requests. |
| frontend.customIntentConfig | object | `{}` |  |
| frontend.faviconPath | string | `"/favicon.svc"` | The relative path to the favicon file. |
| frontend.fullnameOverride | string | `""` |  |
| frontend.image.pullPolicy | string | `"IfNotPresent"` |  |
| frontend.image.repository | string | `"ghcr.io/nebuly-ai/nebuly-frontend"` |  |
| frontend.image.tag | string | `"v1.48.1"` |  |
| frontend.ingress.annotations | object | `{}` |  |
| frontend.ingress.className | string | `""` |  |
| frontend.ingress.enabled | bool | `false` |  |
| frontend.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| frontend.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| frontend.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| frontend.ingress.tls | list | `[]` |  |
| frontend.nodeSelector | object | `{}` |  |
| frontend.podAnnotations | object | `{}` |  |
| frontend.podLabels | object | `{}` |  |
| frontend.podSecurityContext.runAsNonRoot | bool | `true` |  |
| frontend.replicaCount | int | `1` |  |
| frontend.resources.limits.memory | string | `"128Mi"` |  |
| frontend.resources.requests.cpu | string | `"100m"` |  |
| frontend.rootUrl | string | `""` | The full public facing url you use in browser, used for redirects. |
| frontend.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| frontend.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| frontend.securityContext.runAsNonRoot | bool | `true` |  |
| frontend.sentry | object | `{"dsn":"","enabled":false,"environment":"","replaySessionSampleRate":0,"tracesSampleRate":0}` | Settings of the Sentry integration. |
| frontend.sentry.dsn | string | `""` | The DSN of the Sentry project |
| frontend.sentry.enabled | bool | `false` | If true, enable the Sentry integration. |
| frontend.sentry.environment | string | `""` | The name of the Sentry environment. |
| frontend.sentry.replaySessionSampleRate | int | `0` | The sample rate for replay sessions. |
| frontend.service.port | int | `80` |  |
| frontend.service.type | string | `"ClusterIP"` |  |
| frontend.title | string | `"Nebuly"` | The title of the application. |
| frontend.tolerations | list | `[]` |  |
| frontend.volumeMounts | list | `[]` |  |
| frontend.volumes | list | `[]` |  |
| imagePullSecrets | list | `[]` |  |
| ingestionWorker.affinity | object | `{}` |  |
| ingestionWorker.deploymentStrategy.type | string | `"Recreate"` |  |
| ingestionWorker.fullnameOverride | string | `""` |  |
| ingestionWorker.image.pullPolicy | string | `"IfNotPresent"` |  |
| ingestionWorker.image.repository | string | `"ghcr.io/nebuly-ai/nebuly-ingestion-worker"` |  |
| ingestionWorker.image.tag | string | `"v1.40.5"` |  |
| ingestionWorker.nodeSelector | object | `{}` |  |
| ingestionWorker.numWorkersActions | int | `10` | The number of workers (e.g. coroutines) used to process actions. |
| ingestionWorker.numWorkersFeedbackActions | int | `10` | The number of workers (e.g. coroutines) used to process feedback actions. |
| ingestionWorker.numWorkersInteractions | int | `20` | The number of workers (e.g. coroutines) used to process interactions. |
| ingestionWorker.podAnnotations | object | `{}` |  |
| ingestionWorker.podLabels | object | `{}` |  |
| ingestionWorker.podSecurityContext.runAsNonRoot | bool | `true` |  |
| ingestionWorker.replicaCount | int | `1` |  |
| ingestionWorker.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| ingestionWorker.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| ingestionWorker.securityContext.runAsNonRoot | bool | `true` |  |
| ingestionWorker.sentry | object | `{"dsn":"","enabled":false,"environment":"","profilesSampleRate":0,"tracesSampleRate":0}` | Settings of the Sentry integration. |
| ingestionWorker.sentry.dsn | string | `""` | The DSN of the Sentry project |
| ingestionWorker.sentry.enabled | bool | `false` | If true, enable the Sentry integration. |
| ingestionWorker.sentry.environment | string | `""` | The name of the Sentry environment. |
| ingestionWorker.service.port | int | `80` |  |
| ingestionWorker.service.type | string | `"ClusterIP"` |  |
| ingestionWorker.settings.topicsAndActionsVersion | string | `"v2"` |  |
| ingestionWorker.stage1.resources.limits.memory | string | `"585Mi"` |  |
| ingestionWorker.stage1.resources.requests.cpu | string | `"100m"` |  |
| ingestionWorker.stage1.resources.requests.memory | string | `"585Mi"` |  |
| ingestionWorker.stage2.resources.limits.memory | string | `"585Mi"` |  |
| ingestionWorker.stage2.resources.requests.cpu | string | `"100m"` |  |
| ingestionWorker.stage2.resources.requests.memory | string | `"585Mi"` |  |
| ingestionWorker.stage4.resources.limits.memory | string | `"585Mi"` |  |
| ingestionWorker.stage4.resources.requests.cpu | string | `"100m"` |  |
| ingestionWorker.stage4.resources.requests.memory | string | `"585Mi"` |  |
| ingestionWorker.thresholds | object | `{"intentClustering":0.25,"intentMergeClusters":0.2,"subjectClustering":0.3,"subjectMergeClusters":0.3}` | Thresholds for tuning the data-processing pipeline. |
| ingestionWorker.tolerations | list | `[]` |  |
| ingestionWorker.volumeMounts | list | `[]` |  |
| ingestionWorker.volumes | list | `[]` |  |
| kafka.affinity | object | `{}` |  |
| kafka.bootstrapServers | string | `""` | [external] Comma separated list of Kafka brokers. |
| kafka.config."replica.selector.class" | string | `"org.apache.kafka.common.replica.RackAwareReplicaSelector"` |  |
| kafka.existingSecret | object | - | [external] Use an existing secret for Kafka authentication. |
| kafka.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| kafka.external | bool | `false` | If true, deploy a Kafka cluster together with the platform services. Otherwise, use an existing Kafka cluster. |
| kafka.nameOverride | string | `""` | with the provided value. |
| kafka.rack.topologyKey | string | `"topology.kubernetes.io/zone"` |  |
| kafka.replicas | int | `3` | The number of Kafka brokers in the cluster. |
| kafka.resources.limits.memory | string | `"2048Mi"` |  |
| kafka.resources.requests.cpu | string | `"100m"` |  |
| kafka.resources.requests.memory | string | `"1024Mi"` |  |
| kafka.saslPassword | string | `""` | [external] The password for connecting to the Kafka cluster with the method SASL/PLAIN. To be provided only when not using an existing secret (see kafka.existingSecret value below). |
| kafka.saslUsername | string | `""` | [external] The username for connecting to the Kafka cluster with the method SASL/PLAIN. To be provided only when not using an existing secret (see kafka.existingSecret value below). |
| kafka.socketKeepAliveEnabled | bool | `true` | If true, the Kafka clients will use the keep alive feature. |
| kafka.storage | object | - | The storage class used for the Kafka and Zookeeper storage. |
| kafka.topicEventsDlq | object | `{"name":"events-dlq","partitions":1,"replicas":null}` | Settings of the Kafka topic used as dead letter queue. |
| kafka.topicEventsDlq.name | string | `"events-dlq"` | The name of the Kafka topic. |
| kafka.topicEventsDlq.partitions | int | `1` | The number of partitions of the Kafka topic. Used only for self-hosted Kafka clusters. |
| kafka.topicEventsDlq.replicas | string | `nil` | The number of replicas of the Kafka topic. Used only for self-hosted Kafka clusters. |
| kafka.topicEventsMain | object | `{"name":"events-main","partitions":8,"replicas":null}` | Settings of the main Kafka topic used to store events (e.g. interactions) |
| kafka.topicEventsMain.name | string | `"events-main"` | The name of the Kafka topic |
| kafka.topicEventsRetry1 | object | `{"name":"events-retry-1","partitions":2,"replicas":null}` | Settings f the Kafka topic used to retry events that failed processing. |
| kafka.topicEventsRetry1.name | string | `"events-retry-1"` | The name of the Kafka topic. |
| kafka.topicEventsRetry1.partitions | int | `2` | The number of partitions of the Kafka topic. Used only for self-hosted Kafka clusters. |
| kafka.topicEventsRetry1.replicas | string | `nil` | The number of replicas of the Kafka topic. Used only for self-hosted Kafka clusters. |
| kafka.topicEventsRetry2 | object | `{"name":"events-retry-2","partitions":1,"replicas":null}` | Settings of the Kafka topic used to retry events that failed processing (backoff 2). |
| kafka.topicEventsRetry2.name | string | `"events-retry-2"` | The name of the Kafka topic. |
| kafka.topicEventsRetry2.partitions | int | `1` | The number of partitions of the Kafka topic. Used only for self-hosted Kafka clusters. |
| kafka.topicEventsRetry2.replicas | string | `nil` | The number of replicas of the Kafka topic. Used only for self-hosted Kafka clusters. |
| kafka.topicEventsRetry3 | object | `{"name":"events-retry-3","partitions":1,"replicas":null}` | Settings of the Kafka topic used to retry events that failed processing (backoff 3). |
| kafka.topicEventsRetry3.name | string | `"events-retry-3"` | The name of the Kafka topic. |
| kafka.topicEventsRetry3.partitions | int | `1` | The number of partitions of the Kafka topic. Used only for self-hosted Kafka clusters. |
| kafka.topicEventsRetry3.replicas | string | `nil` | The number of replicas of the Kafka topic. Used only for self-hosted Kafka clusters. |
| kafka.zookeeper.affinity | object | `{}` |  |
| kafka.zookeeper.replicas | int | `3` |  |
| kafka.zookeeper.resources.limits.memory | string | `"2048Mi"` |  |
| kafka.zookeeper.resources.requests.cpu | string | `"100m"` |  |
| kafka.zookeeper.resources.requests.memory | string | `"1024Mi"` |  |
| kafka.zookeeper.storage.deleteClaim | bool | `false` |  |
| kafka.zookeeper.storage.size | string | `"10Gi"` |  |
| kafka.zookeeper.storage.type | string | `"persistent-claim"` |  |
| lionLinguist.affinity | object | `{}` |  |
| lionLinguist.deploymentStrategy.type | string | `"Recreate"` |  |
| lionLinguist.fullnameOverride | string | `""` |  |
| lionLinguist.image.pullPolicy | string | `"IfNotPresent"` |  |
| lionLinguist.image.repository | string | `"ghcr.io/nebuly-ai/nebuly-lion-linguist"` |  |
| lionLinguist.image.tag | string | `"v0.5.0"` |  |
| lionLinguist.maxConcurrentRequests | int | `8` | The maximum number of concurrent requests that the service will handle. |
| lionLinguist.modelsCache | object | `{"accessModes":["ReadWriteMany","ReadWriteOnce"],"enabled":true,"size":"64Gi","storageClassName":""}` | Settings of the PVC used to cache AI models. |
| lionLinguist.nodeSelector | object | `{}` |  |
| lionLinguist.podAnnotations | object | `{}` |  |
| lionLinguist.podLabels | object | `{}` |  |
| lionLinguist.podSecurityContext.fsGroup | int | `101` |  |
| lionLinguist.podSecurityContext.runAsNonRoot | bool | `true` |  |
| lionLinguist.replicaCount | int | `1` |  |
| lionLinguist.resources.limits.memory | string | `"2Gi"` |  |
| lionLinguist.resources.requests.cpu | string | `"200m"` |  |
| lionLinguist.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| lionLinguist.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| lionLinguist.securityContext.runAsNonRoot | bool | `true` |  |
| lionLinguist.sentry | object | `{"dsn":"","enabled":false,"environment":"","profilesSampleRate":0,"tracesSampleRate":0}` | Settings of the Sentry integration. |
| lionLinguist.sentry.dsn | string | `""` | The DSN of the Sentry project |
| lionLinguist.sentry.enabled | bool | `false` | If true, enable the Sentry integration. |
| lionLinguist.sentry.environment | string | `""` | The name of the Sentry environment. |
| lionLinguist.service.port | int | `80` |  |
| lionLinguist.service.type | string | `"ClusterIP"` |  |
| lionLinguist.volumeMounts | list | `[]` |  |
| lionLinguist.volumes | list | `[]` |  |
| namespaceOverride | string | `""` | Override the namespace. |
| openAi | object | - | Optional configuration for the Azure OpenAI integration. If enabled, the specified models on the OpenAI resource will be used to process the collected data. |
| openAi.apiKey | string | `""` | The primary API Key of the OpenAI resource, used for authentication. To be provided only when not using an existing secret (see openAi.existingSecret value below). |
| openAi.apiVersion | string | `"2024-02-15-preview"` | The version of the APIs to use |
| openAi.enabled | bool | `true` | If true, enable the OpenAI integration. |
| openAi.endpoint | string | `""` | The endpoint of the OpenAI resource. |
| openAi.existingSecret | object | - | Use an existing secret for the Azure OpenAI authentication. |
| openAi.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| openAi.gpt4oDeployment | string | `""` | The name of the GPT-4o deployment. |
| openAi.translationDeployment | string | `""` | The name of the OpenAI Deployment used to translate interactions. |
| otel.enabled | bool | `false` | If True, enable OpenTelemetry instrumentation of the platform services. When enables, the services will export traces and metrics in OpenTelemetry format, sending them to the OpenTelemetry Collector endpoints specified below. |
| otel.exporterOtlpMetricsEndpoint | string | `"http://contrib-collector.otel:4317"` | The endpoint of the OpenTelemetry Collector used to collect metrics. |
| otel.exporterOtlpTracesEndpoint | string | `"http://contrib-collector.otel:4317"` | The endpoint of the OpenTelemetry Collector used to collect traces. |
| postUpgrade | object | `{"refreshRoTables":{"enabled":false,"resources":{"limits":{"memory":"512Mi"},"requests":{"cpu":"100m"}}}}` | Post-upgrade hooks settings. |
| postUpgrade.refreshRoTables | object | `{"enabled":false,"resources":{"limits":{"memory":"512Mi"},"requests":{"cpu":"100m"}}}` | If True, run a post-install jop that runs a full refresh of the backend RO tables. |
| primaryProcessing | object | - | Settings related to the Primary processing CronJobs. |
| primaryProcessing.hostIPC | bool | `false` | Set to True when running on multiple GPUs. |
| primaryProcessing.modelsCache | object | `{"enabled":false,"size":"128Gi","storageClassName":""}` | Settings of the PVC used to cache AI models. |
| primaryProcessing.numHoursProcessed | int | `50` | Example: 24 -> process the last 24 hours of interactions. |
| primaryProcessing.schedule | string | `"0 23 * * *"` | The schedule of the CronJob. The format is the same as the Kubernetes CronJob schedule. |
| reprocessing | object | `{"modelSuggestions":{"enabled":false}}` | major release. |
| secondaryProcessing | object | - | Settings related to the Primary processing CronJobs. |
| secondaryProcessing.modelsCache | object | `{"enabled":false,"size":"64Gi","storageClassName":""}` | Settings of the PVC used to cache AI models. |
| secondaryProcessing.schedule | string | `"0 2 * * *"` | The schedule of the CronJob. The format is the same as the Kubernetes CronJob schedule. |
| secretsStore.azure.clientId | string | `""` | The Application ID of the Azure AD application used to access the Azure Key Vault. To be provided only when not using an existing secret (see azure.existingSecret value below). |
| secretsStore.azure.clientSecret | string | `""` | The Application Secret of the Azure AD application used to access the Azure Key Vault. To be provided only when not using an existing secret (see azure.existingSecret value below). |
| secretsStore.azure.existingSecret | object | - | Use an existing secret for the Azure Key Vault authentication. |
| secretsStore.azure.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| secretsStore.azure.keyVaultUrl | string | `""` | The URL of the Azure Key Vault storing the secrets. |
| secretsStore.azure.tenantId | string | `""` | The ID of the Azure Tenant where the Azure Key Vault is located. To be provided only when not using an existing secret (see azure.existingSecret value below). |
| secretsStore.kind | string | `"database"` | Supported values: "database", "azure_keyvault" |
| serviceAccount | object | `{"annotations":{},"create":false,"name":"default"}` | The name of the service account used by the platform services. |
| strimzi.enabled | bool | `false` |  |
| telemetry.apiKey | string | `""` | The API key used to authenticate with the telemetry service. |
| telemetry.enabled | bool | `false` | If True, enable telemetry collection. Collected telemetry data consists of anonymous usage statistics and error reports. |
| telemetry.promtail | object | `{"enabled":true}` | If True, enable the Promtail log collector. Only logs from Nebuly's containers will be collected. |
| telemetry.tenant | string | `""` | Code of the tenant to which the telemetry data will be associated. |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Michele Zanotti | <m.zanotti@nebuly.ai> | <https://github.com/Telemaco019> |
| Diego Fiori | <d.fiori@nebuly.ai> | <https://github.com/diegofiori> |

## Source Code

* <https://github.com/nebuly-ai/helm-charts>
