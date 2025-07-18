# GCP - Kubernetes bootstrap

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

Helm chart for bootstrapping a Kubernetes cluster on GCP with all the dependencies required for installing [Nebuly Platform](https://nebuly.com).

**Homepage:** <https://nebuly.com>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.jetstack.io | cert-manager(cert-manager) | ~v1.15.2 |
| https://charts.portefaix.xyz | secrets-store-csi-driver-provider-gcp | ~0.6.0 |
| https://helm.ngc.nvidia.com/nvidia | gpu-operator | ~25.3 |
| https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts | secrets-store-csi-driver | ~1.4 |
| https://kubernetes.github.io/ingress-nginx | ingress-nginx | ~4.10 |

## Installation

You can install this chart as a standalone, or you can install it as dependency
of `nebuly-platform` by setting the `bootstrap-gcp.enabled` value to `true`.

```yaml
bootstrap-gcp:
  enabled: true
```

You can refer to the Nebuly Platform
chart [installation instructions](../nebuly-platform/README.md#installation) for more
details.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cert-manager.crds.enabled | bool | `true` |  |
| cert-manager.enabled | bool | `true` |  |
| gpu-operator.cdi.default | bool | `true` |  |
| gpu-operator.cdi.enabled | bool | `true` |  |
| gpu-operator.driver.enabled | bool | `false` |  |
| gpu-operator.enabled | bool | `true` |  |
| gpu-operator.hostPaths.driverInstallDir | string | `"/home/kubernetes/bin/nvidia"` |  |
| gpu-operator.toolkit.installDir | string | `"/home/kubernetes/bin/nvidia"` |  |
| ingress-nginx.controller.allowSnippetAnnotations | bool | `true` |  |
| ingress-nginx.controller.config | object | `{}` |  |
| ingress-nginx.controller.service.annotations | object | `{}` |  |
| ingress-nginx.controller.service.targetPorts.http | string | `"http"` |  |
| ingress-nginx.controller.service.targetPorts.https | string | `"https"` |  |
| ingress-nginx.enabled | bool | `true` |  |
| nvidia-device-plugin.enabled | bool | `true` |  |
| secrets-store-csi-driver.enabled | bool | `true` |  |
| secrets-store-csi-driver.syncSecret.enabled | bool | `true` |  |

## Source Code

* <https://github.com/nebuly-ai/helm-charts>
