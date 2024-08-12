# Microsoft Azure - Kubernetes bootstrap

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

Helm chart for bootstrapping a Kubernetes cluster on AWS with all the dependencies required for installing [Nebuly Platform](https://nebuly.com).

**Homepage:** <https://nebuly.com>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://kubernetes.github.io/ingress-nginx | ingress-nginx | ~4.10 |

## Installation

This chart is meant to be used as a dependency of
the [Nebuly Platform](../nebuly-platform/README.md) chart.

You can install this chart as a standalone, or you can install it as dependency
of `nebuly-platform` by setting the `bootstrapAzure.enabled` value to `true`.

```yaml
bootstrapAzure:
  enabled: true
```

You can refer to the Nebuly Platform
chart [installation instructions](../nebuly-platform/README.md#installation) for more
details.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| annotations | object | `{}` | Extra annotations that will be added to all resources. |
| ingress-nginx.controller.allowSnippetAnnotations | bool | `true` |  |
| ingress-nginx.controller.config | object | `{}` |  |
| ingress-nginx.controller.service.annotations | object | `{}` |  |
| ingress-nginx.controller.service.targetPorts.http | string | `"http"` |  |
| ingress-nginx.controller.service.targetPorts.https | string | `"https"` |  |
| ingress-nginx.enabled | bool | `true` |  |
| nameOverride | string | `""` | Override the name of the chart. |
| namespaceOverride | string | `""` | Override the namespace. |
| nvidia-device-plugin.enabled | bool | `true` |  |

## Source Code

* <https://github.com/nebuly-ai/helm-charts>
