# GCP - Kubernetes bootstrap

![Version: 0.3.1](https://img.shields.io/badge/Version-0.3.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.3.1](https://img.shields.io/badge/AppVersion-0.3.1-informational?style=flat-square)

Helm chart for bootstrapping a Kubernetes cluster on GCP with all the dependencies required for installing [Nebuly Platform](https://nebuly.com).

**Homepage:** <https://nebuly.com>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.jetstack.io | cert-manager(cert-manager) | ~v1.21 |
| https://charts.portefaix.xyz | secrets-store-csi-driver-provider-gcp | ~0.6.0 |
| https://helm.ngc.nvidia.com/nvidia | gpu-operator | ~26.7 |
| https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts | secrets-store-csi-driver | ~1.6 |
| https://traefik.github.io/charts | traefik | ~41.3 |

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
| nvidia-device-plugin.enabled | bool | `true` |  |
| secrets-store-csi-driver.enabled | bool | `true` |  |
| secrets-store-csi-driver.syncSecret.enabled | bool | `true` |  |
| traefik.enabled | bool | `true` |  |
| traefik.ingressClass.enabled | bool | `true` |  |
| traefik.ingressClass.isDefaultClass | bool | `true` |  |
| traefik.ingressClass.name | string | `"traefik"` |  |
| traefik.providers.kubernetesIngress.enabled | bool | `true` |  |
| traefik.providers.kubernetesIngress.ingressClass | string | `"traefik"` |  |
| traefik.service.spec.type | string | `"LoadBalancer"` |  |

## Source Code

* <https://github.com/nebuly-ai/helm-charts>
