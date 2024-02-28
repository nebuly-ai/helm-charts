# Nebuly Platform

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

Helm chart for installing Nebuly's Platform.

**Homepage:** <https://nebuly.com>

## Prerequisites

### Databases

The platform requires a PostgreSQL Server configured with the databases listed in the table below.
The databases can be created with arbitrary names, as the name of each database
can be provided as a configuration parameter during the installation process of the platform.

| Database        | Helm Value                        | Collation  | Charset | Description                                                                          |
|-----------------|-----------------------------------|------------|---------|--------------------------------------------------------------------------------------|
| Backend         | `backend.postgresDatabase`        | en_US.utf8 | utf8    | It stores users information such as settings, dashboards and projects.               |
| Tenant Registry | `tenantRegistry.postgresDatabase` | en_US.utf8 | utf8    | It stores internal information necessary for the proper functioning of the platform. |
| Analytic        | `analyticDatabase.name`           | en_US.utf8 | utf8    | It stores analytic data such as user LLM interactions                                |

The PostgreSQL server must meet the following requirements:

* The minimum supported version of PostgreSQL is 14.0.
* The server must support password authentication
* [TimescaleDB](https://github.com/timescale/timescaledb) extension must be installed on the server
* The minimum supported version of TimescaleDB is 2.5.0

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

Below you can find a minimal `values.yaml` file with all the mandatory configuration settings:

```yaml
imagePullSecrets:
  - name: nebuly-docker-pull

tenantRegistry:
  postgresServer: mydatabaseserver.postgres.database.azure.com
  postgresUser: myusername
  postgresPassword: mypassword

kafka:
  bootstrapServers: serverurl
  saslUsername: username
  saslPassword: password

analyticDatabase:
  server: mydatabaseserver.postgres.database.azure.com
  user: username
  password: password
```

You can refer to the section [Values](#values) for the full list of all the available configuration settings.

## Expose the services to the Internet

To expose the Platform services to the Internet, you need to specify the Ingress configuration in the
`values.yaml` file. You can expose the following services:

* `frontend`: the Platform frontend application
* `backend`: the Platform backend APIs used by the frontend
* `eventIngestion`: the Platform event ingestion APIs, used for receiving events and interactions.

Below you can find an example configuration for exposing all the services using
[ingress-nginx](https://github.com/kubernetes/ingress-nginx) as ingress
controller and [cert-manager](https://github.com/cert-manager/cert-manager) for managing SSL certificates:

```yaml
backend:
  ingress:
    enabled: true
    className: nginx
    annotations:
        cert-manager.io/cluster-issuer: letsencrypt
    tls:
      - hosts:
          - backend.nebuly.com
        secretName: tls-secret-backend
    hosts:
      - host: dev.backend.nebuly.com
        paths:
          - path: /api
            pathType: Prefix

frontend:
  backendApiUrl: https://dev.backend.nebuly.com

  ingress:
    enabled: true
    className: nginx
    annotations:
        cert-manager.io/cluster-issuer: letsencrypt
    tls:
      - hosts:
          - platform.nebuly.com
        secretName: tls-secret-frontend
    hosts:
      - host: platform.nebuly.com
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
          - platform.nebuly.com
        secretName: tls-secret-frontend
    hosts:
      - host: backend.nebuly.com
        paths:
          - path: /event-ingestion(/|$)(.*)
            pathType: Prefix
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
helm uninstall my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| analyticDatabase.existingSecret | object | `{"name":"","passwordKey":"","userKey":""}` | Use an existing secret for the database authentication. |
| analyticDatabase.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| analyticDatabase.name | string | `"analytics"` | when not using an existing secret (see analyticDatabase.existingSecret value below). |
| analyticDatabase.password | see analyticDatabase.existingSecret value below | `""` | . |
| analyticDatabase.server | string | `""` | The host of the database used to store analytic data. |
| analyticDatabase.user | string | `""` | The user for connecting to the database. |
| auth.adminUserEnabled | bool | `false` | If true, an initial admin user with username/password login will be created. |
| auth.adminUserPassword | string | `"admin"` | The password of the initial admin user. |
| auth.adminUserUsername | string | `"admin@nebuly.ai"` | The username of the initial admin user. |
| auth.microsoft | object | `{"clientId":"","clientSecret":"","existingSecret":{"clientIdKey":"","clientSecretKey":"","name":"","tenantIdKey":""},"redirectUri":"","tenantId":""}` | Microsoft Entra ID authentication configuration. Used when auth.oauthProvider is "microsoft". |
| auth.microsoft.clientId | string | `""` | not using an existing secret (see microsoft.existingSecret value below). |
| auth.microsoft.clientSecret | string | `""` | existing secret (see microsoft.existingSecret value below). |
| auth.microsoft.existingSecret | object | `{"clientIdKey":"","clientSecretKey":"","name":"","tenantIdKey":""}` | Use an existing secret for Microsoft Entra ID authentication. |
| auth.microsoft.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| auth.microsoft.redirectUri | string | `""` | Where <backend-domain> is the domain of the Backend API defined in the backend ingress. |
| auth.microsoft.tenantId | string | `""` | when not using an existing secret (see microsoft.existingSecret value below). |
| auth.oauthProvider | string | `"microsoft"` | only username/password login will be available. |
| azureml | object | `{"batchEndpoint":"","clientId":"","clientSecret":"","resourceGroup":"","subscriptionId":"","tenantId":"","workspace":""}` | process the collected data. |
| azureml.batchEndpoint | string | `""` | The name of the Azure Machine Learning Workspace used to process the collected data. |
| azureml.clientId | string | `""` | The client ID (e.g. Application ID) of the Azure AD application used to access the Azure Machine Learning Workspace. |
| azureml.clientSecret | string | `""` | The client secret of the Azure AD application used to access the Azure Machine Learning Workspace. |
| azureml.resourceGroup | string | `""` | The name of the Azure resource group containing the Azure Machine Learning Workspace. |
| azureml.subscriptionId | string | `""` | The subscription ID of the Azure Machine Learning Workspace. |
| azureml.tenantId | string | `""` | The ID of the Azure Tenant where the Azure Machine Learning Workspace is located. |
| azureml.workspace | string | `""` | The name of the Azure Machine Learning Workspace used to process the collected data. |
| backend.affinity | object | `{}` |  |
| backend.fullnameOverride | string | `""` |  |
| backend.image.pullPolicy | string | `"IfNotPresent"` |  |
| backend.image.repository | string | `"ghcr.io/nebuly-ai/nebuly-backend"` |  |
| backend.image.tag | string | `"latest"` |  |
| backend.ingress.annotations | object | `{}` |  |
| backend.ingress.className | string | `""` |  |
| backend.ingress.enabled | bool | `false` |  |
| backend.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| backend.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| backend.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| backend.ingress.tls | list | `[]` |  |
| backend.nameOverride | string | `""` |  |
| backend.nodeSelector | object | `{}` |  |
| backend.podAnnotations | object | `{}` |  |
| backend.podLabels | object | `{}` |  |
| backend.podSecurityContext.runAsNonRoot | bool | `true` |  |
| backend.replicaCount | int | `1` |  |
| backend.resources.limits.memory | string | `"384Mi"` |  |
| backend.resources.requests.cpu | string | `"100m"` |  |
| backend.resources.requests.memory | string | `"256Mi"` |  |
| backend.rootPath | string | `""` | Example: rootPath: "/backend-service" |
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
| eventIngestion.image.tag | string | `"latest"` |  |
| eventIngestion.ingress.annotations | object | `{}` |  |
| eventIngestion.ingress.className | string | `""` |  |
| eventIngestion.ingress.enabled | bool | `false` |  |
| eventIngestion.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| eventIngestion.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| eventIngestion.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| eventIngestion.ingress.tls | list | `[]` |  |
| eventIngestion.nameOverride | string | `""` |  |
| eventIngestion.nodeSelector | object | `{}` |  |
| eventIngestion.podAnnotations | object | `{}` |  |
| eventIngestion.podLabels | object | `{}` |  |
| eventIngestion.podSecurityContext.runAsNonRoot | bool | `true` |  |
| eventIngestion.replicaCount | int | `1` |  |
| eventIngestion.resources.limits.memory | string | `"256Mi"` |  |
| eventIngestion.resources.requests.cpu | string | `"100m"` |  |
| eventIngestion.resources.requests.memory | string | `"128Mi"` |  |
| eventIngestion.rootPath | string | `""` | Example: rootPath: "/event-ingestion" |
| eventIngestion.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| eventIngestion.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| eventIngestion.securityContext.runAsNonRoot | bool | `true` |  |
| eventIngestion.service.port | int | `80` |  |
| eventIngestion.service.type | string | `"ClusterIP"` |  |
| eventIngestion.tolerations | list | `[]` |  |
| eventIngestion.volumeMounts | list | `[]` |  |
| eventIngestion.volumes | list | `[]` |  |
| frontend.affinity | object | `{}` |  |
| frontend.backendApiUrl | string | `""` | The URL of the Backend API to which Frontend will make requests. |
| frontend.fullnameOverride | string | `""` |  |
| frontend.image.pullPolicy | string | `"IfNotPresent"` |  |
| frontend.image.repository | string | `"ghcr.io/nebuly-ai/nebuly-frontend"` |  |
| frontend.image.tag | string | `"latest"` |  |
| frontend.ingress.annotations | object | `{}` |  |
| frontend.ingress.className | string | `""` |  |
| frontend.ingress.enabled | bool | `false` |  |
| frontend.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| frontend.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| frontend.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| frontend.ingress.tls | list | `[]` |  |
| frontend.nameOverride | string | `""` |  |
| frontend.nodeSelector | object | `{}` |  |
| frontend.podAnnotations | object | `{}` |  |
| frontend.podLabels | object | `{}` |  |
| frontend.podSecurityContext.runAsNonRoot | bool | `true` |  |
| frontend.replicaCount | int | `1` |  |
| frontend.resources.limits.memory | string | `"256Mi"` |  |
| frontend.resources.requests.cpu | string | `"100m"` |  |
| frontend.resources.requests.memory | string | `"128Mi"` |  |
| frontend.rootUrl | string | `""` | The full public facing url you use in browser, used for redirects and emails |
| frontend.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| frontend.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| frontend.securityContext.runAsNonRoot | bool | `true` |  |
| frontend.service.port | int | `80` |  |
| frontend.service.type | string | `"ClusterIP"` |  |
| frontend.tolerations | list | `[]` |  |
| frontend.volumeMounts | list | `[]` |  |
| frontend.volumes | list | `[]` |  |
| imagePullSecrets | list | `[]` |  |
| ingestionWorker.actionsProcessing | object | `{"resources":{"limits":{"memory":"512Mi"},"requests":{"cpu":"500m","memory":"256Mi"}},"schedule":"@daily"}` | Settings related to the CronJob for processing the actions of the collected interactions. |
| ingestionWorker.actionsProcessing.schedule | string | `"@daily"` | The schedule of the CronJob. The format is the same as the Kubernetes CronJob schedule. |
| ingestionWorker.affinity | object | `{}` |  |
| ingestionWorker.fullnameOverride | string | `""` |  |
| ingestionWorker.image.pullPolicy | string | `"IfNotPresent"` |  |
| ingestionWorker.image.repository | string | `"ghcr.io/nebuly-ai/nebuly-ingestion-worker"` |  |
| ingestionWorker.image.tag | string | `"latest"` |  |
| ingestionWorker.nameOverride | string | `""` |  |
| ingestionWorker.nodeSelector | object | `{}` |  |
| ingestionWorker.numWorkersActions | int | `10` | The number of workers (e.g. coroutines) used to process actions. |
| ingestionWorker.numWorkersFeedbackActions | int | `10` | The number of workers (e.g. coroutines) used to process feedback actions. |
| ingestionWorker.numWorkersInteractions | int | `20` | The number of workers (e.g. coroutines) used to process interactions. |
| ingestionWorker.podAnnotations | object | `{}` |  |
| ingestionWorker.podLabels | object | `{}` |  |
| ingestionWorker.podSecurityContext.runAsNonRoot | bool | `true` |  |
| ingestionWorker.replicaCount | int | `1` |  |
| ingestionWorker.resources.limits.memory | string | `"1512Mi"` |  |
| ingestionWorker.resources.requests.cpu | string | `"500m"` |  |
| ingestionWorker.resources.requests.memory | string | `"1024Mi"` |  |
| ingestionWorker.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| ingestionWorker.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| ingestionWorker.securityContext.runAsNonRoot | bool | `true` |  |
| ingestionWorker.service.port | int | `80` |  |
| ingestionWorker.service.type | string | `"ClusterIP"` |  |
| ingestionWorker.tolerations | list | `[]` |  |
| ingestionWorker.topicsClustering | object | `{"resources":{"limits":{"cpu":1,"memory":"5024Mi"},"requests":{"cpu":1,"memory":"5024Mi"}},"schedule":"@daily"}` | Settings related to the CronJob for clustering topics. |
| ingestionWorker.topicsClustering.schedule | string | `"@daily"` | The schedule of the CronJob. The format is the same as the Kubernetes CronJob schedule. |
| ingestionWorker.volumeMounts | list | `[]` |  |
| ingestionWorker.volumes | list | `[]` |  |
| kafka.bootstrapServers | string | `""` | Comma separated list of Kafka brokers. |
| kafka.existingSecret | object | `{"name":"","saslPasswordKey":"","saslUsernameKey":""}` | Use an existing secret for Kafka authentication. |
| kafka.existingSecret.name | string | `""` | Name of the secret. Can be templated. |
| kafka.saslPassword | string | `""` | when not using an existing secret (see kafka.existingSecret value below). |
| kafka.saslUsername | string | `""` | when not using an existing secret (see kafka.existingSecret value below). |
| kafka.socketKeepAliveEnabled | bool | `true` | If true, the Kafka clients will use the keep alive feature. |
| kafka.topicEventsDlq | string | `"events-dlq"` | The name of the Kafka topic used as dead letter queue. |
| kafka.topicEventsMain | string | `"events-main"` | The name of the main Kafka topic used to store events (e.g. interactions) |
| kafka.topicEventsRetry1 | string | `"events-retry-1"` | The name of the Kafka topic used to retry events that failed processing. |
| kafka.topicEventsRetry2 | string | `"events-retry-2"` | The name of the Kafka topic used to retry events that failed processing (backoff 2). |
| kafka.topicEventsRetry3 | string | `"events-retry-3"` | The name of the Kafka topic used to retry events that failed processing (backoff 3). |
| nameOverride | string | `""` |  |
| otel.enabled | bool | `false` | OpenTelemetry Collector endpoints specified below. |
| otel.exporterOtlpMetricsEndpoint | string | `"http://contrib-collector.otel:4317"` | The endpoint of the OpenTelemetry Collector used to collect metrics. |
| otel.exporterOtlpTracesEndpoint | string | `"http://contrib-collector.otel:4317"` | The endpoint of the OpenTelemetry Collector used to collect traces. |
| secretsStore.azure.clientId | string | `""` | The Application ID of the Azure AD application used to access the Azure Key Vault. |
| secretsStore.azure.clientSecret | string | `""` | The Application Secret of the Azure AD application used to access the Azure Key Vault. |
| secretsStore.azure.keyVaultUrl | string | `""` | The URL of the Azure Key Vault storing the Tenant Registry secrets. |
| secretsStore.azure.tenantId | string | `""` | The ID of the Azure Tenant where the Azure Key Vault is located. |
| secretsStore.kind | string | `"azure_keyvault"` | Supported values: "database", "azure_keyvault" |
| tenantRegistry.affinity | object | `{}` |  |
| tenantRegistry.fullnameOverride | string | `""` |  |
| tenantRegistry.image.pullPolicy | string | `"IfNotPresent"` |  |
| tenantRegistry.image.repository | string | `"ghcr.io/nebuly-ai/nebuly-tenant-registry"` |  |
| tenantRegistry.image.tag | string | `"latest"` |  |
| tenantRegistry.nameOverride | string | `""` |  |
| tenantRegistry.nodeSelector | object | `{}` |  |
| tenantRegistry.podAnnotations | object | `{}` |  |
| tenantRegistry.podLabels | object | `{}` |  |
| tenantRegistry.podSecurityContext.runAsNonRoot | bool | `true` |  |
| tenantRegistry.postgresDatabase | string | `"tenant-registry"` | The name of the PostgreSQL database used to store service's data. |
| tenantRegistry.postgresPassword | string | `""` | The password for the database user. |
| tenantRegistry.postgresServer | string | `""` | The host of the PostgreSQL database used to store service's data. |
| tenantRegistry.postgresUser | string | `""` | The user for connecting to the database. |
| tenantRegistry.replicaCount | int | `1` |  |
| tenantRegistry.resources.limits.memory | string | `"256Mi"` |  |
| tenantRegistry.resources.requests.cpu | string | `"100m"` |  |
| tenantRegistry.resources.requests.memory | string | `"128Mi"` |  |
| tenantRegistry.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| tenantRegistry.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| tenantRegistry.securityContext.runAsNonRoot | bool | `true` |  |
| tenantRegistry.service.port | int | `80` |  |
| tenantRegistry.service.type | string | `"ClusterIP"` |  |
| tenantRegistry.tolerations | list | `[]` |  |
| tenantRegistry.volumeMounts | list | `[]` |  |
| tenantRegistry.volumes | list | `[]` |  |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Michele Zanotti | <m.zanotti@nebuly.ai> | <https://github.com/Telemaco019> |
| Diego Fiori | <d.fiori@nebuly.ai> | <https://github.com/diegofiori> |

## Source Code

* <https://github.com/nebuly-ai/helm-charts>
