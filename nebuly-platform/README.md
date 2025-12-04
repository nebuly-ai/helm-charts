# Nebuly Platform

![Version: 1.74.7](https://img.shields.io/badge/Version-1.74.7-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

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
| aiModels | object | `{"aws":{"bucketName":"","endpointUrl":"","existingSecret":{"accessKeyIdKey":"","name":"","secretAccessKeyKey":""}},"azure":{"managedIdentityClientId":"","storageAccountName":"","storageContainerName":"","tenantId":""},"azureml":{"clientId":"","clientSecret":"","existingSecret":{"clientIdKey":"","clientSecretKey":"","name":""},"resourceGroup":"","subscriptionId":"","tenantId":"","workspace":""},"gcp":{"bucketName":"","projectName":""},"modelActionClassifier":{"name":"action-classifier","version":"6"},"modelInferenceInteractions":{"name":"interaction-analyzer-7b-v2","version":"35"},"modelLanguageDetection":{"name":"language-detection","version":"2"},"modelPiiRemoval":{"name":"pii-removal","version":"1"},"modelTopicClassifier":{"name":"topic-classifier","version":"16"},"registry":"","sync":{"affinity":{},"enabled":false,"env":{},"image":{"pullPolicy":"IfNotPresent","repository":"ghcr.io/nebuly-ai/nebuly-models-sync","tag":"v0.4.1"},"nodeSelector":{},"podAnnotations":{},"podLabels":{},"podSecurityContext":{"runAsNonRoot":true},"resources":{"limits":{"memory":"8Gi"},"requests":{"memory":"4Gi"}},"schedule":"0 23 * * *","securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"runAsNonRoot":true},"source":{"clientId":"","clientSecret":"","existingSecret":{"clientIdKey":"","clientSecretKey":"","name":""}},"tolerations":[],"volumeMounts":[],"volumes":[]}}` | Settings of the AI models used for inference. |
| aiModels.aws | object | - | Config of the AWS S3 model registry. |
| aiModels.aws.bucketName | string | `""` | The name of the AWS S3 bucket. |
| aiModels.aws.endpointUrl | string | `""` | Optional AWS S3 endpoint URL. The URL should not include the bucket name. Example: "https://my-domain.com:9444" |
| aiModels.aws.existingSecret | object | `{"accessKeyIdKey":"","name":"","secretAccessKeyKey":""}` | Optionally use an existing secret for AWS S3 authentication. If no secret is provided, the services will default to using the Service Account linked to an IAM Role with the required permissions. |
| aiModels.aws.existingSecret.accessKeyIdKey | string | `""` | The key of the secret containing the AWS Access Key ID. |
| aiModels.aws.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| aiModels.aws.existingSecret.secretAccessKeyKey | string | `""` | The key of the secret containing the AWS Secret Access Key. |
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
| aiModels.gcp | object | - | Config of the GCP Storage model registry. |
| aiModels.gcp.bucketName | string | `""` | The name of the GCP bucket. |
| aiModels.gcp.projectName | string | `""` | The name of the GCP project containing the bucket. |
| aiModels.registry | string | `""` | The kind of registry used to store the AI models. Available values are: "azure_ml", "aws_s3", "azure_storage", "gcp_bucket" |
| aiModels.sync | object | - | Settings for the Sync Job that pulls AI models from Nebuly's private registry and makes them available in your platform's registry. The Job checks if the specified model versions are available in your private registry. If not, it pulls them from Nebuly's registry and pushes them to your registry. |
| aiModels.sync.enabled | bool | `false` | Enable or disable the Sync Job. Default is false for compatibility reasons. |
| aiModels.sync.env | object | `{}` | Additional environment variables, in the standard Kubernetes format. Example: - name: MY_ENV_VAR   value: "my-value" |
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
| analyticDatabase.schema | string | `"public"` | The schema of the database used to store analytic data. |
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
| auth.google | object | `{"clientId":"","clientSecret":"","enabled":false,"existingSecret":{"clientIdKey":"","clientSecretKey":"","name":""},"redirectUri":"","roleMapping":""}` | Google authentication configuration. Used when `auth.loginModes` contains "google". |
| auth.google.clientId | string | `""` | The Client ID of the Google application. To be provided only when not using an existing secret (see google.existingSecret value below). |
| auth.google.clientSecret | string | `""` | The Client Secret of the Google application. To be provided only when not using an existing secret (see google.existingSecret value below). |
| auth.google.existingSecret | object | - | Use an existing secret for Google SSO authentication. |
| auth.google.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| auth.google.redirectUri | string | `""` | The callback URI of the SSO flow. Must be the same as the redirect URI configured for the Okta application. Must be in the following format: "https://<backend-domain>/auth/oauth/google/callback" Where <backend-domain> is the domain defined in `backend.ingress`. |
| auth.google.roleMapping | string | `""` | The mapping between Nebuly roles and Google groups. Example: "viewer:<viewer-group-email>,admin: <admin-group-email>,member: <member-group-email>" |
| auth.image.pullPolicy | string | `"IfNotPresent"` |  |
| auth.image.repository | string | `"ghcr.io/nebuly-ai/nebuly-tenant-registry"` |  |
| auth.image.tag | string | `"v1.22.1"` |  |
| auth.ingress | object | - | Ingress configuration for the login endpoints. |
| auth.jwtSigningKey | string | `""` | Private RSA Key used for signing JWT tokens. Required only if not using an existing secret (see auth.existingSecret value below). |
| auth.ldap | object | `{"activeDirectoryRoot":"","adminPassword":"","adminUsername":"","attributeMapping":"","enabled":false,"existingSecret":{"adminPasswordKey":"","adminUsernameKey":"","name":""},"groupObjectClass":"","host":"","port":"389","roleMapping":"","searchBase":"","userSearchFilter":""}` | LDAP authentication configuration. |
| auth.ldap.activeDirectoryRoot | string | `""` | Optional directory root for the LDAP server. |
| auth.ldap.adminPassword | string | `""` | The password of the LDAP user with permissions to perform LDAP searches. To be provided only when not using an existing secret (see auth ldap.existingSecret value below). |
| auth.ldap.adminUsername | string | `""` | The username of the LDAP user with permissions to perform LDAP searches. To be provided only when not using an existing secret (see auth ldap.existingSecret value below). |
| auth.ldap.attributeMapping | string | `""` | Custom mapping for LDAP attributes used for users full name and email. If not provided, the following attributes will be used: * `mail`: user email * `cn`: user full name  When provided, it should be a comma separated list of attributes. Example: `email:<ldap-attribute>,full_name:<ldap-attribute>` |
| auth.ldap.enabled | bool | `false` | If true, enable LDAP authentication. |
| auth.ldap.groupObjectClass | string | `""` | The name of the object class used for groups. |
| auth.ldap.host | string | `""` | The address of LDAP server. |
| auth.ldap.port | string | `"389"` | The port of the LDAP server. |
| auth.ldap.roleMapping | string | `""` | Mapping between LDAP Roles and Nebuly roles. Example: `<ladp-admin>:admin, <ldap-member>:member, <ldap-viewer>:viewer`. |
| auth.ldap.searchBase | string | `""` | The LDAP search base to use. Example: `dc=example,dc=org` |
| auth.ldap.userSearchFilter | string | `""` | The search filter to use for user searches. Example: `(&(objectClass=inetOrgPerson))` |
| auth.loginModes | string | `"password"` | The available login modes. Value must be string with the login mode specified as a comma-separated list. Possible values are: `password`, `microsoft`, `okta`, `google`. |
| auth.microsoft | object | - | Microsoft Entra ID authentication configuration. Used when `auth.loginModes` contains "microsoft". |
| auth.microsoft.clientId | string | `""` | The Client ID (e.g. Application ID) of the Microsoft Entra ID application. To be provided only when not using an existing secret (see microsoft.existingSecret value below). |
| auth.microsoft.clientSecret | string | `""` | The Client Secret of the Microsoft Entra ID application. To be provided only when not using an existing secret (see microsoft.existingSecret value below). |
| auth.microsoft.enabled | bool | `false` | If true, enable Microsoft Entra ID SSO authentication. |
| auth.microsoft.existingSecret | object | - | Use an existing secret for Microsoft Entra ID authentication. |
| auth.microsoft.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| auth.microsoft.redirectUri | string | `""` | The callback URI of the SSO flow. Must be the same as the redirect URI configured for the Microsoft Entra ID application. Must be in the following format: "https://<backend-domain>/auth/oauth/microsoft/callback" Where <backend-domain> is the domain defined in `backend.ingress`. |
| auth.microsoft.roleMapping | string | `""` | Optional mapping between Nebuly roles and Microsoft Entra ID groups. If not provided, Nebuly roles will be read from the App Roles assigned to users in the Microsoft Entra ID application. Example: "viewer:<group-id>,admin:<group-id>,member:<group-id>" |
| auth.microsoft.tenantId | string | `""` | The ID of the Azure Tenant where the Microsoft Entra ID application is located. |
| auth.nodeSelector | object | `{}` |  |
| auth.okta | object | `{"clientId":"","clientSecret":"","enabled":false,"existingSecret":{"clientIdKey":"","clientSecretKey":"","name":""},"issuer":"","redirectUri":""}` | Okta authentication configuration. Used when `auth.loginModes` contains "okta". |
| auth.okta.clientId | string | `""` | The Client ID of the Okta application. To be provided only when not using an existing secret (see okta.existingSecret value below). |
| auth.okta.clientSecret | string | `""` | The Client Secret of the Okta application. To be provided only when not using an existing secret (see okta.existingSecret value below). |
| auth.okta.existingSecret | object | - | Use an existing secret for Okta SSO authentication. |
| auth.okta.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| auth.okta.issuer | string | `""` | The issuer of the Okta application. |
| auth.okta.redirectUri | string | `""` | The callback URI of the SSO flow. Must be the same as the redirect URI configured for the Okta application. Must be in the following format: "https://<backend-domain>/auth/oauth/okta/callback" Where <backend-domain> is the domain defined in `backend.ingress`. |
| auth.podAnnotations | object | `{}` |  |
| auth.podLabels | object | `{}` |  |
| auth.podSecurityContext.runAsNonRoot | bool | `true` |  |
| auth.postgresDatabase | string | `"auth-service"` | The name of the PostgreSQL database used to store user data. |
| auth.postgresPassword | string | `""` | The password for the database user. Required only if not using an existing secret (see auth.existingSecret value below). |
| auth.postgresSchema | string | `"public"` | The schema of the PostgreSQL database used to store user data. |
| auth.postgresServer | string | `""` | The host of the PostgreSQL database used to store user data. |
| auth.postgresUser | string | `""` | The user for connecting to the database. Required only if not using an existing secret (see auth.existingSecret value below). |
| auth.refreshTokenExpirationDays | int | `7` | Number of days before a refresh token expires due to inactivity. Determines how long a user can remain logged in without activity before being required to log in again. For example, a value of 1 means users must log in again after 24 hours of inactivity. |
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
| backend.image.tag | string | `"v1.97.12"` |  |
| backend.ingress.annotations | object | `{}` |  |
| backend.ingress.className | string | `""` |  |
| backend.ingress.enabled | bool | `false` |  |
| backend.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| backend.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| backend.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| backend.ingress.tls | list | `[]` |  |
| backend.interactionsDetailsAccessControlRoles | list | `["viewer","member","admin"]` | If interactionsDetailsAccessControlEnabled is true, the roles that are not allowed to access the interactions details. |
| backend.nodeSelector | object | `{}` |  |
| backend.podAnnotations | object | `{}` |  |
| backend.podLabels | object | `{}` |  |
| backend.podSecurityContext.runAsNonRoot | bool | `true` |  |
| backend.replicaCount | int | `1` |  |
| backend.resources.limits.memory | string | `"1024Mi"` |  |
| backend.resources.requests.cpu | string | `"100m"` |  |
| backend.rootPath | string | `""` | Optionally, the base path of the Backend API when running behind a reverse proxy with a path prefix. Example: "/backend-service" |
| backend.scheduler.livenessProbe.failureThreshold | int | `10` |  |
| backend.scheduler.livenessProbe.httpGet.path | string | `"/healthz"` |  |
| backend.scheduler.livenessProbe.httpGet.port | string | `"http"` |  |
| backend.scheduler.livenessProbe.initialDelaySeconds | int | `10` |  |
| backend.scheduler.livenessProbe.periodSeconds | int | `15` |  |
| backend.scheduler.readinessProbe.httpGet.path | string | `"/readyz"` |  |
| backend.scheduler.readinessProbe.httpGet.port | string | `"http"` |  |
| backend.scheduler.readinessProbe.initialDelaySeconds | int | `10` |  |
| backend.scheduler.readinessProbe.periodSeconds | int | `10` |  |
| backend.scheduler.resources.limits.memory | string | `"2048Mi"` |  |
| backend.scheduler.resources.requests.cpu | string | `"100m"` |  |
| backend.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| backend.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| backend.securityContext.runAsNonRoot | bool | `true` |  |
| backend.sentry | object | `{"dsn":"","enabled":false,"environment":"","profilesSampleRate":0,"tracesSampleRate":0}` | Settings of the Sentry integration. |
| backend.sentry.dsn | string | `""` | The DSN of the Sentry project |
| backend.sentry.enabled | bool | `false` | If true, enable the Sentry integration. |
| backend.sentry.environment | string | `""` | The name of the Sentry environment. |
| backend.service.port | int | `80` |  |
| backend.service.type | string | `"ClusterIP"` |  |
| backend.settings.alembicTable | string | `""` | The name of the alembic table used to store the status of the backend migrations. If not provided, the default `alembic_version` table will be used. |
| backend.settings.multiTenancyMode | string | `"dynamic_schema"` |  |
| backend.tolerations | list | `[]` |  |
| backend.volumeMounts | list | `[]` |  |
| backend.volumes | list | `[]` |  |
| bootstrap-aws | object | `{"enabled":false}` | If True, install the Chart `nebuly-ai/bootstrap-aws`, which installs all the dependencies required for installing nebuly-platform on an EKS cluster on AWS. |
| bootstrap-azure | object | `{"enabled":false}` | If True, install the Chart `nebuly-ai/bootstrap-azure`, which installs all the dependencies required for installing nebuly-platform on an AKS cluster on Microsoft Azure. |
| bootstrap-gcp | object | `{"enabled":false}` | If True, install the Chart `nebuly-ai/bootstrap-gcp`, which installs all the dependencies required for installing nebuly-platform on an GKE cluster on Google Cloud Platform. |
| clickhouse.active | bool | `true` | Flag to roll out clickhouse progressively on existing postgres installations (first deploy clickhouse, then enable it on backend) |
| clickhouse.affinity | object | `{}` |  |
| clickhouse.auth.backupsUser | object | `{"password":"nebuly","username":"backups"}` | Credentials of the user used to create backups. |
| clickhouse.auth.nebulyUser | object | `{"password":"nebuly","username":"nebulyadmin"}` | Credentials of the user used by Nebuly to access the ClickHouse database. |
| clickhouse.backups | object | `{"aws":{"bucketName":"","endpointUrl":"","existingSecret":{"accessKeyIdKey":"","name":"","secretAccessKeyKey":""},"region":""},"azure":{"existingSecret":{"name":"","storageAccountKeyKey":""},"storageAccountKey":"","storageAccountName":"","storageContainerName":""},"enabled":false,"fullBackupWeekday":7,"gcp":{"bucketName":"","projectName":""},"image":{"pullPolicy":"IfNotPresent","repository":"altinity/clickhouse-backup","tag":"2.6.5"},"numToKeepLocal":4,"numToKeepRemote":120,"remoteStorage":"","restore":{"backupName":"","enabled":false},"schedule":"0 */4 * * *"}` | Backups configuration. |
| clickhouse.backups.aws | object | - | Config of the AWS Bucket used for storing backups remotely. |
| clickhouse.backups.aws.bucketName | string | `""` | The name of the AWS S3 bucket. |
| clickhouse.backups.aws.endpointUrl | string | `""` | the bucket name. Example: "https://my-domain.com:9444" |
| clickhouse.backups.aws.existingSecret | object | `{"accessKeyIdKey":"","name":"","secretAccessKeyKey":""}` | linked to an IAM Role with the required permissions. |
| clickhouse.backups.aws.existingSecret.accessKeyIdKey | string | `""` | The key of the secret containing the AWS Access Key ID. |
| clickhouse.backups.aws.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| clickhouse.backups.aws.existingSecret.secretAccessKeyKey | string | `""` | The key of the secret containing the AWS Secret Access Key. |
| clickhouse.backups.aws.region | string | `""` | The AWS region where the bucket is located. |
| clickhouse.backups.azure | object | - | Config of the Azure Storage used for storing backups remotely. |
| clickhouse.backups.azure.existingSecret | object | `{"name":"","storageAccountKeyKey":""}` | Use an existing secret for the Azure Storage authentication. |
| clickhouse.backups.azure.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| clickhouse.backups.azure.existingSecret.storageAccountKeyKey | string | `""` | The key of the secret containing the Azure Storage Account Key. |
| clickhouse.backups.azure.storageAccountKey | string | `""` | The storage account key. |
| clickhouse.backups.azure.storageAccountName | string | `""` | The name of the Azure Storage account. |
| clickhouse.backups.azure.storageContainerName | string | `""` | The name of the Azure Storage container. |
| clickhouse.backups.enabled | bool | `false` | If True, enable the backups of the ClickHouse database. |
| clickhouse.backups.gcp | object | - | Config of the GCP Storage used for storing backups remotely. |
| clickhouse.backups.gcp.bucketName | string | `""` | The name of the GCP bucket. |
| clickhouse.backups.gcp.projectName | string | `""` | The name of the GCP project containing the bucket. |
| clickhouse.backups.image | object | `{"pullPolicy":"IfNotPresent","repository":"altinity/clickhouse-backup","tag":"2.6.5"}` | The settings of the Docker image used to run the backup job. |
| clickhouse.backups.numToKeepLocal | int | `4` | Number of backups to keep locally. Default: keep last day (e.g. last 4 backups). |
| clickhouse.backups.numToKeepRemote | int | `120` | Number of backups to keep on the remote cloud storage. Default: keep last 30 days (e.g. last 120 backups). |
| clickhouse.backups.remoteStorage | string | `""` | The kind of storage used to store backups. Possible values are: "aws_s3", "gcp_bucket", "azure_storage". |
| clickhouse.backups.restore.backupName | string | `""` | The name of the backup to restore. If not provided, the latest backup will be restored. |
| clickhouse.backups.restore.enabled | bool | `false` | If True, enable the backup restore cronjob. The cronjob is configured to never run, so it must be manually triggered. |
| clickhouse.backups.schedule | string | `"0 */4 * * *"` | The schedule of the job. The format is the same as the Kubernetes CronJob schedule. Default: every 4 hours |
| clickhouse.databaseName | string | `"analytics"` | The name of the ClickHouse database. |
| clickhouse.enabled | bool | `false` |  |
| clickhouse.image.pullPolicy | string | `"IfNotPresent"` |  |
| clickhouse.image.repository | string | `"clickhouse/clickhouse-server"` |  |
| clickhouse.image.tag | string | `"24.12.5-alpine"` |  |
| clickhouse.ingestionBatchSize | int | `25000` | The size of the batches used to ingest data into ClickHouse. |
| clickhouse.keeper.affinity | object | `{}` |  |
| clickhouse.keeper.enabled | bool | `false` |  |
| clickhouse.keeper.image | object | `{"pullPolicy":"IfNotPresent","repository":"clickhouse/clickhouse-keeper","tag":"25.1.5.31"}` | The ClickHouse Keeper version to use (Docker image tag). |
| clickhouse.keeper.replicas | int | `1` |  |
| clickhouse.keeper.resources.limits.memory | string | `"4Gi"` |  |
| clickhouse.keeper.storage | object | `{"size":"32Gi","storageClassName":"default"}` | Storage configuration of the ClickHouse Keeper instances. |
| clickhouse.keeper.tolerations | list | `[]` |  |
| clickhouse.keeper.volumeMounts | list | `[]` | Additional volumeMounts on ClickHouse Keeper pods. |
| clickhouse.keeper.volumes | list | `[]` | Additional volumes on the ClickHouse Keeper pods. |
| clickhouse.logLevel | string | `"debug"` | ClickHouse log level. |
| clickhouse.replicas | int | `1` | The number of ClickHouse replicas. |
| clickhouse.resources.limits.memory | string | `"13Gi"` |  |
| clickhouse.resources.requests.memory | string | `"13Gi"` |  |
| clickhouse.storage | object | `{"size":"128Gi","storageClassName":"default"}` | Persistent storage settings. |
| clickhouse.tolerations | list | `[]` |  |
| clickhouse.volumeMounts | list | `[]` | Additional volumeMounts on ClickHouse pods. |
| clickhouse.volumes | list | `[]` | Additional volumes on the ClickHouse pods. |
| clusterIssuer | object | `{"email":"support@nebuly.ai","enabled":false,"name":"letsencrypt"}` | Optional cert-manager cluster issuer. @default -- |
| eventIngestion.affinity | object | `{}` |  |
| eventIngestion.fullnameOverride | string | `""` |  |
| eventIngestion.image.pullPolicy | string | `"IfNotPresent"` |  |
| eventIngestion.image.repository | string | `"ghcr.io/nebuly-ai/nebuly-event-ingestion"` |  |
| eventIngestion.image.tag | string | `"v1.17.0"` |  |
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
| eventIngestion.resources.limits.memory | string | `"256Mi"` |  |
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
| frontend.defaultAggregation | string | `"interaction"` | The default aggregation level of the platform. |
| frontend.enableAbTesting | bool | `false` | Enable the AB testing feature. |
| frontend.enableAiSummary | bool | `false` | If set to true, enable the AI summarization feature. |
| frontend.enableHighPerformanceMode | bool | `true` | If true enable High performance mode. This mode increases the performance of  the platform and is suggested for environments with high volumes of data  (more than 1 million interactions per month). |
| frontend.enableLLMIssueHiding | bool | `false` | If True, hide LLM issues from users without the proper role. |
| frontend.enableOldRiskyBehavior | bool | `false` | Feature flag to activate the old risky behavior page. Used for retro-compatibility. |
| frontend.enableOrganizationSettings | bool | `false` | If True, allow admins to assign/exclude users from organizations. |
| frontend.enableSubCategories | bool | `false` | If set to true, enable the sub-categories feature. |
| frontend.faviconPath | string | `"/favicon.svc"` | The relative path to the favicon file. |
| frontend.fullnameOverride | string | `""` |  |
| frontend.image.pullPolicy | string | `"IfNotPresent"` |  |
| frontend.image.repository | string | `"ghcr.io/nebuly-ai/nebuly-frontend"` |  |
| frontend.image.tag | string | `"v1.72.5"` |  |
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
| frontend.useFaviconAsLogo | bool | `false` |  |
| frontend.volumeMounts | list | `[]` |  |
| frontend.volumes | list | `[]` |  |
| fullProcessing | object | `{"affinity":{},"deploymentStrategy":{"type":"Recreate"},"enabled":false,"env":{},"fullnameOverride":"","hostIPC":false,"modelsCache":{"enabled":false,"size":"128Gi","storageClassName":""},"nodeSelector":{},"podAnnotations":{},"podLabels":{},"podSecurityContext":{"fsGroup":101,"runAsNonRoot":true},"resources":{"limits":{"nvidia.com/gpu":1},"requests":{"cpu":1}},"securityContext":{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"runAsNonRoot":true},"settings":{"processingDelaySeconds":0},"tolerations":[{"effect":"NoSchedule","key":"nvidia.com/gpu","operator":"Exists"}],"volumeMounts":[],"volumes":[]}` | Settings related to the runtime full-processing mode, which replaces the primary and secondary processing CronJobs with an always running Deployment. |
| fullProcessing.enabled | bool | `false` | If true, replaces the processing CronJobs with an always running Deployment. |
| fullProcessing.env | object | `{}` | Additional environment variables, in the standard Kubernetes format. Example: - name: MY_ENV_VAR   value: "my-value" |
| fullProcessing.hostIPC | bool | `false` | Set to True when running on multiple GPUs. |
| fullProcessing.settings.processingDelaySeconds | int | `0` | Seconds of delay between processing. |
| imagePullSecrets | list | `[]` |  |
| ingestionWorker.affinity | object | `{}` |  |
| ingestionWorker.deploymentStrategy.type | string | `"Recreate"` |  |
| ingestionWorker.env | object | `{}` | Example: - name: MY_ENV_VAR   value: "my-value" |
| ingestionWorker.fullnameOverride | string | `""` |  |
| ingestionWorker.healthCheckPath | string | `""` | Example: /mnt/health-check/healthy.timestamp |
| ingestionWorker.image.pullPolicy | string | `"IfNotPresent"` |  |
| ingestionWorker.image.repository | string | `"ghcr.io/nebuly-ai/nebuly-ingestion-worker"` |  |
| ingestionWorker.image.tag | string | `"v1.64.10"` |  |
| ingestionWorker.nodeSelector | object | `{}` |  |
| ingestionWorker.numWorkersFeedbackActions | int | `10` | The number of workers (e.g. coroutines) used to process feedback actions. |
| ingestionWorker.numWorkersInteractions | int | `10` | The number of workers (e.g. coroutines) used to process interactions. |
| ingestionWorker.podAnnotations | object | `{}` |  |
| ingestionWorker.podLabels | object | `{}` |  |
| ingestionWorker.podSecurityContext.runAsNonRoot | bool | `true` |  |
| ingestionWorker.replicaCount | int | `1` |  |
| ingestionWorker.resources.limits.cpu | int | `2` |  |
| ingestionWorker.resources.limits.memory | string | `"2600Mi"` |  |
| ingestionWorker.resources.requests.cpu | string | `"100m"` |  |
| ingestionWorker.resources.requests.memory | string | `"1024Mi"` |  |
| ingestionWorker.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| ingestionWorker.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| ingestionWorker.securityContext.runAsNonRoot | bool | `true` |  |
| ingestionWorker.sentry | object | `{"dsn":"","enabled":false,"environment":"","profilesSampleRate":0,"tracesSampleRate":0}` | Settings of the Sentry integration. |
| ingestionWorker.sentry.dsn | string | `""` | The DSN of the Sentry project |
| ingestionWorker.sentry.enabled | bool | `false` | If true, enable the Sentry integration. |
| ingestionWorker.sentry.environment | string | `""` | The name of the Sentry environment. |
| ingestionWorker.service.port | int | `80` |  |
| ingestionWorker.service.type | string | `"ClusterIP"` |  |
| ingestionWorker.settings.alembicTable | string | `""` | The name of the alembic table used to store the status of the ingestion worker migrations. If not provided, the default `alembic_version` table will be used. |
| ingestionWorker.settings.enableDbCache | bool | `true` | Use the database as a cache for aggregate jobs; disable it for projects with over 1 million interactions. |
| ingestionWorker.settings.enablePiiLanguageDetection | bool | `false` | Enable language detection for PII detection. |
| ingestionWorker.settings.enablePiiLlm | bool | `false` | Enable use of LLM (pii-removal) to remove the PII during interaction processing.  |
| ingestionWorker.settings.enrichInteractionBatchSize | int | `10000` | Batch size of interactions loaded in each step of enrich interactions. |
| ingestionWorker.settings.entitiesBatchSize | int | `20000` | Batch size of entities loaded in each step of aggregate jobs. |
| ingestionWorker.settings.piiDenyList | list | `[]` | List of PII keywords to be ignored. You can insert names and addresses that you don't want the PII detection to remove. |
| ingestionWorker.settings.piiEnabledTenants | list | `[]` | List of tenants for which PII detection is enabled. Note that when given this will override the enablePiiLlm setting for the given tenants. |
| ingestionWorker.settings.tasks | object | `{"feedbackAction":true,"interaction":true,"tags":true,"traceInteraction":true}` | Enable or disable internal worker tasks. This is primarily intended for debugging or performance tuning. |
| ingestionWorker.statementTimeoutSeconds | int | `120` | The timeout in seconds for the database queries. |
| ingestionWorker.tolerations | list | `[]` |  |
| ingestionWorker.volumeMounts | list | `[]` |  |
| ingestionWorker.volumes | list | `[]` |  |
| interactionsAccessControl | object | `{"enabled":false,"openDetailsMode":"disabled","openDetailsRoles":["member","admin"],"redactedRoles":["viewer","member","admin"]}` | Settings for controlling the access to the users interactions stored in the  platform. |
| interactionsAccessControl.enabled | bool | `false` | If true, enable the access control for the interactions, making their details available only to the users with the proper roles. |
| interactionsAccessControl.openDetailsMode | string | `"disabled"` | Possible values: "disabled", "reason". When set to "reason", the users that are allowed to access the interactions details will need to provide a reason for accessing them. |
| interactionsAccessControl.openDetailsRoles | list | `["member","admin"]` | The roles that are subject to the open details mode when the access control is enabled.  If the openDetailsMode is set to "reason", the users with the specified roles will be able to access the interactions details only if they provide a reason.  If the openDetailsMode is set to "disabled", the users with the specified roles won't be able to access the interactions details. |
| interactionsAccessControl.redactedRoles | list | `["viewer","member","admin"]` | The roles for which the input/output fields of the interactions are redacted when the access control is enabled. |
| kafka.affinity | object | `{}` |  |
| kafka.bootstrapServers | string | `""` | [external] Comma separated list of Kafka brokers. |
| kafka.config."replica.selector.class" | string | `"org.apache.kafka.common.replica.RackAwareReplicaSelector"` |  |
| kafka.createTopics | bool | `true` | [external] If True, create the Kafka topics automatically if not present on the specified external Kafka cluster. |
| kafka.existingSecret | object | - | [external] Use an existing secret for Kafka authentication. |
| kafka.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| kafka.existingSecret.sslCaCertKey | string | `""` | The key of the secret containing the CA certificate (in PEM format) used for SSL authentication. |
| kafka.external | bool | `false` | If false, deploy a Kafka cluster together with the platform services. Otherwise, use an existing Kafka cluster. |
| kafka.krb5Config | string | `""` | [external] Used only when saslMechanism is set to "GSSAPI". The Keberos configuration file used for SASL GSSAPI authentication. |
| kafka.nameOverride | string | `""` | with the provided value. |
| kafka.rack.topologyKey | string | `"topology.kubernetes.io/zone"` |  |
| kafka.replicas | int | `3` | The number of Kafka brokers in the cluster. |
| kafka.resources.limits.memory | string | `"2048Mi"` |  |
| kafka.resources.requests.cpu | string | `"100m"` |  |
| kafka.resources.requests.memory | string | `"1024Mi"` |  |
| kafka.saslGssapiKerberosPrincipal | string | `""` | [external] Used only when saslMechanism is set to "GSSAPI". The principal used for SASL GSSAPI authentication, including the realm. Example: "kafka/kafka.example.com@EXAMPLE.COM" |
| kafka.saslGssapiServiceName | string | `""` | [external] Used only when saslMechanism is set to "GSSAPI". The service name used for SASL GSSAPI authentication, without the realm. Example: "kafka" |
| kafka.saslMechanism | string | `"PLAIN"` | [external] The mechanism used for authentication. Allowed values are: "PLAIN", "GSSAPI", "SCRAM-SHA-512" |
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
| kafka.user | string | `"nebuly-platform"` | The name of the user used by the services for connecting to the created kafka cluster. |
| kafka.zookeeper.affinity | object | `{}` |  |
| kafka.zookeeper.replicas | int | `3` |  |
| kafka.zookeeper.resources.limits.memory | string | `"2048Mi"` |  |
| kafka.zookeeper.resources.requests.cpu | string | `"100m"` |  |
| kafka.zookeeper.resources.requests.memory | string | `"1024Mi"` |  |
| kafka.zookeeper.storage.deleteClaim | bool | `false` |  |
| kafka.zookeeper.storage.size | string | `"10Gi"` |  |
| kafka.zookeeper.storage.type | string | `"persistent-claim"` |  |
| namespaceOverride | string | `""` | Override the namespace. |
| openAi | object | - | Optional configuration for the OpenAI integration. If enabled, the specified models on the OpenAI resource will be used to process the collected data. Both OpenAI and Azure OpenAI are supported. |
| openAi.apiKey | string | `""` | The primary API Key of the OpenAI resource, used for authentication. To be provided only when not using an existing secret (see openAi.existingSecret value below). |
| openAi.apiVersion | string | `"2024-02-15-preview"` | The version of the APIs to use. Used only for Azure OpenAI. |
| openAi.enabled | bool | `true` | If true, enable the OpenAI integration. |
| openAi.endpoint | string | `""` | The endpoint of the OpenAI resource. For Azure OpenAI: `https://<resource-name>.openai.azure.com/`. For OpenAI: `https://api.openai.com/v1`. |
| openAi.existingSecret | object | - | Use an existing secret for the Azure OpenAI authentication. |
| openAi.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| openAi.gpt4oDeployment | string | `""` | For Azure OpenAI: the name of the GPT-4o deployment. For OpenAI: `gpt-4o`. |
| openAi.translationDeployment | string | `""` | For Azure OpenAI: the name of the OpenAI Deployment used to translate interactions. For OpenAI: the name of the OpenAI model used to translate interactions. |
| otel.enabled | bool | `false` | If True, enable OpenTelemetry instrumentation of the platform services. When enables, the services will export traces and metrics in OpenTelemetry format, sending them to the OpenTelemetry Collector endpoints specified below. |
| otel.exporterOtlpMetricsEndpoint | string | `"http://contrib-collector.otel:4317"` | The endpoint of the OpenTelemetry Collector used to collect metrics. |
| otel.exporterOtlpTracesEndpoint | string | `"http://contrib-collector.otel:4317"` | The endpoint of the OpenTelemetry Collector used to collect traces. |
| postUpgrade | object | `{"migrateInteractionEdits":{"enabled":false,"resources":{"limits":{"memory":"512Mi"},"requests":{"cpu":"100m"}}},"refreshRoTables":{"enabled":false,"resources":{"limits":{"memory":"512Mi"},"requests":{"cpu":"100m"}}}}` | Post-upgrade hooks settings. |
| postUpgrade.migrateInteractionEdits | object | `{"enabled":false,"resources":{"limits":{"memory":"512Mi"},"requests":{"cpu":"100m"}}}` | If True, run a post-install job that migrates the interaction edits logs. |
| postUpgrade.refreshRoTables | object | `{"enabled":false,"resources":{"limits":{"memory":"512Mi"},"requests":{"cpu":"100m"}}}` | If True, run a post-install job that runs a full refresh of the backend RO tables. |
| primaryProcessing | object | - | Settings related to the Primary processing CronJobs. |
| primaryProcessing.env | object | `{}` | Additional environment variables, in the standard Kubernetes format. Example: - name: MY_ENV_VAR   value: "my-value" |
| primaryProcessing.hostIPC | bool | `false` | Set to True when running on multiple GPUs. |
| primaryProcessing.modelsCache | object | `{"enabled":false,"size":"128Gi","storageClassName":""}` | Settings of the PVC used to cache AI models. |
| primaryProcessing.schedule | string | `"0 23 * * *"` | The schedule of the CronJob. The format is the same as the Kubernetes CronJob schedule. |
| primaryProcessing.timezone | string | `""` | The timezone of the CronJob. If not provided, the default timezone of the Kubernetes cluster will be used. |
| reprocessing | object | `{"interactions":{"enabled":false},"modelIssues":{"enabled":false},"modelSuggestions":{"enabled":false},"userIntelligence":{"enabled":false}}` | Settings for data reprocessing jobs required during major platform upgrades. Keep everything disabled by default unless you're upgrading the platform to a major release. |
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
| telemetry.gtmId | string | `""` | The Google Tag Manager (GTM) Id. |
| telemetry.promtail | object | `{"enabled":true}` | If True, enable the Promtail log collector. Only logs from Nebuly's containers will be collected. |
| telemetry.tenant | string | `""` | Code of the tenant to which the telemetry data will be associated. |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Michele Zanotti | <m.zanotti@nebuly.ai> | <https://github.com/Telemaco019> |
| Diego Fiori | <d.fiori@nebuly.ai> | <https://github.com/diegofiori> |

## Source Code

* <https://github.com/nebuly-ai/helm-charts>
