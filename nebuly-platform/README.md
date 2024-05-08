# Nebuly Platform

![Version: 1.2.5](https://img.shields.io/badge/Version-1.2.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

Helm chart for installing Nebuly's Platform.

**Homepage:** <https://nebuly.com>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://nvidia.github.io/k8s-device-plugin | nvidia-device-plugin | 0.15.0 |
| oci://quay.io/strimzi-helm | strimzi-kafka-operator | 0.40.0 |

## Prerequisites

### Databases

The platform requires a PostgreSQL Server configured with the databases listed in the table below.
The databases can be created with arbitrary names, as the name of each database
can be provided as a configuration parameter during the installation process of the platform.

| Database        | Helm Value                        | Collation  | Charset | Description                                                                          |
|-----------------|-----------------------------------|------------|---------|--------------------------------------------------------------------------------------|
| Backend         | `backend.postgresDatabase.name`        | en_US.utf8 | utf8    | It stores users information such as settings, dashboards and projects.               |
| Auth Service    | `authService.postgresDatabase.name` | en_US.utf8 | utf8    | It stores the identity of the users and the respective permissions. |
| Analytic        | `analyticDatabase.name`           | en_US.utf8 | utf8    | It stores analytic data such as user LLM interactions                                |

The PostgreSQL server must meet the following requirements:

* The minimum supported version of PostgreSQL is 14.0.
* The server must support password authentication

### Apache Kafka

The Platform requires an [Apache Kafka](https://kafka.apache.org/) server for storing the
ingested events waiting to be processed.

At moment, the Platform only supports
[SASL/PLAIN](https://docs.confluent.io/platform/current/kafka/authentication_sasl/authentication_sasl_plain.html#kafka-sasl-auth-plain)
authentication with username and password, so the Kafka server must be configured to use this authentication method.

The Platform uses several topics in the Kafka server. You can customize the names of the topics through the following
values:

* `kafka.topicEventsMain`
* `kafka.topicEventsRetry1`
* `kafka.topicEventsRetry2`
* `kafka.topicEventsRetry3`
* `kafka.topicEventsDlq`

If the topics do not exist, the Platform creates them automatically at startup. It is recommended to create the topics
manually with the desired configuration before installing the Platform, so that its possible to
configure each topic with the desired number of partitions and replication factor according to the expected load.

## Installation

### 1. Create a GitHub personal access token

You first need to create a GitHub personal access token with the `read:packages` scope to pull the required Docker
images. You can refer to
the [GitHub documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens).

### 2. Create a container image pull secret

You need to create a container image pull secret with the PAT token you created in the previous step. You can
do that following the steps below.

1. Create a base64 encoded string of the token value with the following command, where `<username>` is your GitHub
username and `<token>` is the value of the PAT token you created in the previous step.

```bash
echo -n "<username>:<token>" | base64
```

2. Create a JSON file containing the base64 representation of your PAT. You can do that with the following commands,
   replacing the placeholder `<your-base64-token>` with the value you obtained in the previous step:

```bash
cat <<EOT > secret.json
{
  "auths": {
    "ghcr.io": {
      "auth": "<your-base64-token>"
    }
  }
}
EOT
```

3. Create the image pull secret
```bash
kubectl create secret docker-registry nebuly-docker-pull --from-file=.dockerconfigjson=secret.json --namespace nebuly
```

4. Include the created secret in the `imagePullSecrets` field of the `values.yaml` file.

```yaml
imagePullSecrets:
  - name: nebuly-docker-pull
```

### 3. Install the chart
You can install the chart in the namespace `nebuly` with the following command:

```bash
helm install oci://ghcr.io/nebuly-ai/helm-charts/nebuly-platform \
  --version 0.1.0 \
  --namespace nebuly \
  --generate-name \
  --create-namespace \
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

## Examples

### Microsoft Azure installation

The following is an example of `values.yaml` for installing the Platform on Microsoft Azure.

The Platform will use the following Azure services:

* Azure OpenAI: used for processing the ingested data (text embeddings, text generation)
* Azure Machine Learning: used for storing the ingested data (frustration and warnings detection)
* Azure Key Vault: used for storing API Keys
* Azure Event Hub: used as Kafka server for storing the ingested events

The configuration will expose the services using the following domains:

* `platform.example.nebuly.com`: the frontend application
* `backend.example.nebuly.com`: the backend APIs
* `backend.example.nebuly.com/auth`: the authentication and authorization endpoints
* `backend.example.nebuly.com/event-ingestion`: the event ingestion APIs

The configuration assumes you have already create one or more secrets containing all the required credentials (these
secrets are referenced in the `existingSecret` fields of the configuration).

<details>
<summary> <b> Microsoft Azure values.yaml </b> </summary>

```yaml
imagePullSecrets:
  - name: my-image-pull-secret

secretsStore:
  kind: "azure_keyvault"
  azure:
    keyVaultUrl: "https://example.vault.azure.net"
    tenantId: "<your-tenant-id>"

    existingSecret:
      # -- Name of the secret. Can be templated.
      name: "my-secret"
      clientIdKey: "azure-client-id"
      clientSecretKey: "azure-client-secret"

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

eventIngestion:
  rootPath: "/event-ingestion"

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

kafka:
  bootstrapServers: "<your-event-hub-name>.servicebus.windows.net:9093"

  existingSecret:
    name: my-secret
    saslPasswordKey: kafka-sasl-password
    saslUsernameKey: kafka-sasl-username

analyticDatabase:
  server: "<postgres-server-url>"
  name: analytics
  existingSecret:
    name:  my-secret
    userKey: postgres-user
    passwordKey: postgres-password

auth:
  postgresServer: "<postgres-server-url>"
  postgresDatabase: auth-service
  existingSecret:
    name: my-secret
    userKey: postgres-user
    passwordKey: postgres-password
    jwtSigningKey: jwt-key

  # Enable Microsoft SSO
  microsoft:
    enabled: true
    redirectUri: https://backend.example.nebuly.com/auth/oauth/microsoft/callback
    tenantId: "<your-tenant-id>"
    existingSecret:
      name: my-secret
      clientIdKey: microsoft-oauth-client-id
      clientSecretKey: microsoft-oauth-client-secret

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

frontend:
  rootUrl: "https://platform.example.nebuly.com"
  backendApiUrl: "https://backend.example.nebuly.com"
  authApiUrl: "https://backend.example.nebuly.com/auth"
  ingress:
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt
    enabled: true
    className: "nginx"
    tls:
      - hosts:
          - helmtest.internal.nebuly.com
        secretName: tls-secret-backend-helmtest
    hosts:
      - host: helmtest.internal.nebuly.com
        paths:
          - path: /
            pathType: Prefix

azureOpenAi:
  enabled: true
  insightsGeneratorDeployment: "gpt-4-turbo"
  textEmbeddingsDeployment: "text-embedding"
  frustrationDetectionDeployment: "gpt-4-0125-preview"
  chatCompletionDeployment: "gpt-3.5-turbo"
  endpoint: "https://<your-azure-openai-instance>.openai.azure.com"

  existingSecret:
    name: my-secret
    apiKey: azure-openai-api-key

azureml:
  enabled: true
  tenantId: "<your-tenant-id>"
  subscriptionId: "<your-subscription-id>"
  resourceGroup: "<your-resource-group-name>"
  workspace: "<your-aml-workspace-name>"
  batchEndpoint: "os-model-batch"

  existingSecret:
    name: my-secret
    clientIdKey: azure-client-id
    clientSecretKey: azure-client-secret
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
| actionsProcessing | object | - | Settings related to the CronJob for processing the actions of the collected interactions. |
| actionsProcessing.schedule | string | `"@daily"` | The schedule of the CronJob. The format is the same as the Kubernetes CronJob schedule. |
| analyticDatabase.existingSecret | object | - | Use an existing secret for the database authentication. |
| analyticDatabase.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| analyticDatabase.name | string | `"analytics"` | The name of the database used to store analytic data (interactions, actions, etc.). To be provided only when not using an existing secret (see analyticDatabase.existingSecret value below). |
| analyticDatabase.password | string | `""` | The password for the database user. To be provided only when not using an existing secret (see analyticDatabase.existingSecret value below). |
| analyticDatabase.server | string | `""` | The host of the database used to store analytic data. |
| analyticDatabase.user | string | `""` | The user for connecting to the database. |
| auth.adminUserEnabled | bool | `false` | If true, an initial admin user with username/password login will be created. |
| auth.adminUserPassword | string | `"admin"` | The password of the initial admin user. |
| auth.adminUserUsername | string | `"admin@nebuly.ai"` | The username of the initial admin user. |
| auth.affinity | object | `{}` |  |
| auth.existingSecret | object | - | Use an existing secret for the database authentication. |
| auth.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| auth.fullnameOverride | string | `""` |  |
| auth.image.pullPolicy | string | `"IfNotPresent"` |  |
| auth.image.repository | string | `"ghcr.io/nebuly-ai/nebuly-tenant-registry"` |  |
| auth.image.tag | string | `"v1.4.2"` |  |
| auth.ingress | object | - | Ingress configuration for the login endpoints. |
| auth.jwtSigningKey | string | `""` | Private RSA Key used for signing JWT tokens. Required only if not using an existing secret (see auth.existingSecret value below). |
| auth.loginModes | string | `"password"` | as a comma-separated list. Possible values are: `password`, `microsoft`. |
| auth.microsoft | object | - | Microsoft Entra ID authentication configuration. Used when auth.oauthProvider is "microsoft". |
| auth.microsoft.clientId | string | `""` | The Client ID (e.g. Application ID) of the Microsoft Entra ID application. To be provided only when not using an existing secret (see microsoft.existingSecret value below). |
| auth.microsoft.clientSecret | string | `""` | The Client Secret of the Microsoft Entra ID application. To be provided only when not using an existing secret (see microsoft.existingSecret value below). |
| auth.microsoft.enabled | bool | `false` | If true, enable Microsoft Entra ID SSO authentication. |
| auth.microsoft.existingSecret | object | - | Use an existing secret for Microsoft Entra ID authentication. |
| auth.microsoft.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| auth.microsoft.redirectUri | string | `""` | The callback URI of the SSO flow. Must be the same as the redirect URI configured for the Microsoft Entra ID application. Must be in the following format: "https://<backend-domain>/auth/oauth/microsoft/callback" Where <backend-domain> is the domain defined in `backend.ingress`. |
| auth.microsoft.tenantId | string | `""` | The ID of the Azure Tenant where the Microsoft Entra ID application is located. To be provided only when not using an existing secret (see microsoft.existingSecret value below). |
| auth.nodeSelector | object | `{}` |  |
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
| auth.service.port | int | `80` |  |
| auth.service.type | string | `"ClusterIP"` |  |
| auth.tolerations | list | `[]` |  |
| auth.volumeMounts | list | `[]` |  |
| auth.volumes | list | `[]` |  |
| azureOpenAi | object | - | Optional configuration for the Azure OpenAI integration. If enabled, the specified models on the Azure OpenAI resource will be used to process the collected data. |
| azureOpenAi.apiKey | string | `""` | The primary API Key of the Azure OpenAI resource, used for authentication. To be provided only when not using an existing secret (see azureOpenAi.existingSecret value below). |
| azureOpenAi.apiVersion | string | `"2024-02-15-preview"` | The version of the APIs to use |
| azureOpenAi.chatCompletionDeployment | string | `""` | The name of the Azure OpenAI Deployment used to complete chat messages. |
| azureOpenAi.enabled | bool | `true` | If true, enable the Azure OpenAI integration. |
| azureOpenAi.endpoint | string | `""` | The endpoint of the Azure OpenAI resource. |
| azureOpenAi.existingSecret | object | - | Use an existing secret for the Azure OpenAI authentication. |
| azureOpenAi.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| azureOpenAi.frustrationDetectionDeployment | string | `""` | The name of the Azure OpenAI Deployment used to detect frustration. |
| azureOpenAi.insightsGeneratorDeployment | string | `""` | The name of the Azure OpenAI Deployment used to generate insights. |
| azureOpenAi.textEmbeddingsDeployment | string | `""` | The name of the Azure OpenAI Deployment used to generate text embeddings. |
| azureml | object | - | [Deprecated] Optional configuration for the Azure Machine Learning integration. If enabled, a Batch Endpoint on the specified Azure Machine Learning Workspace will be used to process the collected data. |
| azureml.batchEndpoint | string | `""` | The name of the Azure Machine Learning Workspace used to process the collected data. |
| azureml.clientId | string | `""` | The client ID (e.g. Application ID) of the Azure AD application used to access the Azure Machine Learning Workspace. To be provided only when not using an existing secret (see azureml.existingSecret value below). |
| azureml.clientSecret | string | `""` | The client secret of the Azure AD application used to access the Azure Machine Learning Workspace. |
| azureml.datasetName | string | `"nebuly-batch-endpoint"` | The name of the Azure Machine Learning Dataset used to upload the data to process. |
| azureml.enabled | bool | `true` | If true, enable the Azure Machine Learning integration. |
| azureml.existingSecret | object | - | Use an existing secret for the AzureML authentication. |
| azureml.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| azureml.resourceGroup | string | `""` | The name of the Azure resource group containing the Azure Machine Learning Workspace. |
| azureml.subscriptionId | string | `""` | The subscription ID of the Azure Machine Learning Workspace. |
| azureml.tenantId | string | `""` | The ID of the Azure Tenant where the Azure Machine Learning Workspace is located. To be provided only when not using an existing secret (see azureml.existingSecret value below). |
| azureml.workspace | string | `""` | The name of the Azure Machine Learning Workspace used to process the collected data. |
| backend.affinity | object | `{}` |  |
| backend.fullnameOverride | string | `""` |  |
| backend.image.pullPolicy | string | `"IfNotPresent"` |  |
| backend.image.repository | string | `"ghcr.io/nebuly-ai/nebuly-backend"` |  |
| backend.image.tag | string | `"v1.16.7"` |  |
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
| backend.resources.limits.memory | string | `"400Mi"` |  |
| backend.resources.requests.cpu | string | `"100m"` |  |
| backend.rootPath | string | `""` | Example: "/backend-service" |
| backend.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| backend.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| backend.securityContext.runAsNonRoot | bool | `true` |  |
| backend.service.port | int | `80` |  |
| backend.service.type | string | `"ClusterIP"` |  |
| backend.tolerations | list | `[]` |  |
| backend.volumeMounts | list | `[]` |  |
| backend.volumes | list | `[]` |  |
| eventIngestion.affinity | object | `{}` |  |
| eventIngestion.fullnameOverride | string | `""` |  |
| eventIngestion.image.pullPolicy | string | `"IfNotPresent"` |  |
| eventIngestion.image.repository | string | `"ghcr.io/nebuly-ai/nebuly-event-ingestion"` |  |
| eventIngestion.image.tag | string | `"v1.4.3"` |  |
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
| eventIngestion.service.port | int | `80` |  |
| eventIngestion.service.type | string | `"ClusterIP"` |  |
| eventIngestion.tolerations | list | `[]` |  |
| eventIngestion.volumeMounts | list | `[]` |  |
| eventIngestion.volumes | list | `[]` |  |
| frontend.affinity | object | `{}` |  |
| frontend.authApiUrl | string | `""` | The URL of the API used for authentication (login, SSO, etc.). |
| frontend.backendApiUrl | string | `""` | The URL of the Backend API to which Frontend will make requests. |
| frontend.fullnameOverride | string | `""` |  |
| frontend.image.pullPolicy | string | `"IfNotPresent"` |  |
| frontend.image.repository | string | `"ghcr.io/nebuly-ai/nebuly-frontend"` |  |
| frontend.image.tag | string | `"v1.16.8"` |  |
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
| frontend.service.port | int | `80` |  |
| frontend.service.type | string | `"ClusterIP"` |  |
| frontend.tolerations | list | `[]` |  |
| frontend.volumeMounts | list | `[]` |  |
| frontend.volumes | list | `[]` |  |
| imagePullSecrets | list | `[]` |  |
| ingestionWorker.affinity | object | `{}` |  |
| ingestionWorker.categoriesWarningsGeneration | object | - | Settings related to the CronJob for generating warnings for custom categories. |
| ingestionWorker.categoriesWarningsGeneration.schedule | string | `"*/15 * * * *"` | The schedule of the CronJob. The format is the same as the Kubernetes CronJob schedule. |
| ingestionWorker.fullnameOverride | string | `""` |  |
| ingestionWorker.image.pullPolicy | string | `"IfNotPresent"` |  |
| ingestionWorker.image.repository | string | `"ghcr.io/nebuly-ai/nebuly-ingestion-worker"` |  |
| ingestionWorker.image.tag | string | `"v1.6.1"` |  |
| ingestionWorker.modelsCache | object | `{"size":"64Gi","storageClassName":""}` | Settings of the PVC used to cache AI models. |
| ingestionWorker.nodeSelector | object | `{}` |  |
| ingestionWorker.numWorkersActions | int | `10` | The number of workers (e.g. coroutines) used to process actions. |
| ingestionWorker.numWorkersFeedbackActions | int | `10` | The number of workers (e.g. coroutines) used to process feedback actions. |
| ingestionWorker.numWorkersInteractions | int | `20` | The number of workers (e.g. coroutines) used to process interactions. |
| ingestionWorker.podAnnotations | object | `{}` |  |
| ingestionWorker.podLabels | object | `{}` |  |
| ingestionWorker.podSecurityContext.runAsNonRoot | bool | `true` |  |
| ingestionWorker.replicaCount | int | `1` |  |
| ingestionWorker.resources.limits.memory | string | `"585Mi"` |  |
| ingestionWorker.resources.requests.cpu | string | `"500m"` |  |
| ingestionWorker.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| ingestionWorker.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| ingestionWorker.securityContext.runAsNonRoot | bool | `true` |  |
| ingestionWorker.service.port | int | `80` |  |
| ingestionWorker.service.type | string | `"ClusterIP"` |  |
| ingestionWorker.suggestionsGeneration | object | - | Settings related to the CronJob for generating category suggestions. |
| ingestionWorker.suggestionsGeneration.schedule | string | `"0 */2 * * *"` | The schedule of the CronJob. The format is the same as the Kubernetes CronJob schedule. |
| ingestionWorker.tolerations | list | `[]` |  |
| ingestionWorker.topicsClustering | object | - | Settings related to the CronJob for clustering topics. |
| ingestionWorker.topicsClustering.schedule | string | `"@daily"` | The schedule of the CronJob. The format is the same as the Kubernetes CronJob schedule. |
| ingestionWorker.volumeMounts | list | `[]` |  |
| ingestionWorker.volumes | list | `[]` |  |
| kafka.bootstrapServers | string | `""` | [external] Comma separated list of Kafka brokers. |
| kafka.config."replica.selector.class" | string | `"org.apache.kafka.common.replica.RackAwareReplicaSelector"` |  |
| kafka.existingSecret | object | - | [external] Use an existing secret for Kafka authentication. |
| kafka.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| kafka.external | bool | `false` | If true, deploy a Kafka cluster together with the platform services. Otherwise, use an existing Kafka cluster. |
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
| kafka.zookeeper.replicas | int | `3` |  |
| kafka.zookeeper.resources.limits.memory | string | `"2048Mi"` |  |
| kafka.zookeeper.resources.requests.cpu | string | `"100m"` |  |
| kafka.zookeeper.resources.requests.memory | string | `"1024Mi"` |  |
| kafka.zookeeper.storage.deleteClaim | bool | `false` |  |
| kafka.zookeeper.storage.size | string | `"10Gi"` |  |
| kafka.zookeeper.storage.type | string | `"persistent-claim"` |  |
| nvidia.enabled | bool | `false` |  |
| otel.enabled | bool | `false` | If True, enable OpenTelemetry instrumentation of the platform services. When enables, the services will export traces and metrics in OpenTelemetry format, sending them to the OpenTelemetry Collector endpoints specified below. |
| otel.exporterOtlpMetricsEndpoint | string | `"http://contrib-collector.otel:4317"` | The endpoint of the OpenTelemetry Collector used to collect metrics. |
| otel.exporterOtlpTracesEndpoint | string | `"http://contrib-collector.otel:4317"` | The endpoint of the OpenTelemetry Collector used to collect traces. |
| secretsStore.azure.clientId | string | `""` | The Application ID of the Azure AD application used to access the Azure Key Vault. To be provided only when not using an existing secret (see azure.existingSecret value below). |
| secretsStore.azure.clientSecret | string | `""` | The Application Secret of the Azure AD application used to access the Azure Key Vault. To be provided only when not using an existing secret (see azure.existingSecret value below). |
| secretsStore.azure.existingSecret | object | - | Use an existing secret for the Azure Key Vault authentication. |
| secretsStore.azure.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| secretsStore.azure.keyVaultUrl | string | `""` | The URL of the Azure Key Vault storing the secrets. |
| secretsStore.azure.tenantId | string | `""` | The ID of the Azure Tenant where the Azure Key Vault is located. To be provided only when not using an existing secret (see azure.existingSecret value below). |
| secretsStore.kind | string | `"database"` | Supported values: "database", "azure_keyvault" |
| strimzi.enabled | bool | `false` |  |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Michele Zanotti | <m.zanotti@nebuly.ai> | <https://github.com/Telemaco019> |
| Diego Fiori | <d.fiori@nebuly.ai> | <https://github.com/diegofiori> |

## Source Code

* <https://github.com/nebuly-ai/helm-charts>
