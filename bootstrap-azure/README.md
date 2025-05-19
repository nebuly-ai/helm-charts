# Microsoft Azure - Kubernetes bootstrap

![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Helm chart for bootstrapping a Kubernetes cluster on AWS with all the dependencies required for installing [Nebuly Platform](https://nebuly.com).

**Homepage:** <https://nebuly.com>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.jetstack.io | cert-manager(cert-manager) | ~v1.15.2 |
| https://kubernetes.github.io/ingress-nginx | ingress-nginx | ~4.10 |
| https://nvidia.github.io/k8s-device-plugin | nvidia-device-plugin(nvidia-device-plugin) | ~0.15.0 |

## Installation

This chart is meant to be used as a dependency of
the [Nebuly Platform](../nebuly-platform/README.md) chart.

You can install this chart as a standalone, or you can install it as dependency
of `nebuly-platform` by setting the `bootstrap-azure.enabled` value to `true`.

```yaml
bootstrap-azure:
  enabled: true
```

You can refer to the Nebuly Platform
chart [installation instructions](../nebuly-platform/README.md#installation) for more
details.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| annotations | object | `{}` | Extra annotations that will be added to all resources. |
| cert-manager.crds.enabled | bool | `true` |  |
| cert-manager.enabled | bool | `true` |  |
| ingress-nginx.controller.allowSnippetAnnotations | bool | `true` |  |
| ingress-nginx.controller.config | object | `{}` |  |
| ingress-nginx.controller.service.annotations."service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path" | string | `"/healthz"` |  |
| ingress-nginx.controller.service.targetPorts.http | string | `"http"` |  |
| ingress-nginx.controller.service.targetPorts.https | string | `"https"` |  |
| ingress-nginx.enabled | bool | `true` |  |
| nameOverride | string | `""` | Override the name of the chart. |
| namespaceOverride | string | `""` | Override the namespace. |
| nvidia-device-plugin.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].key | string | `"feature.node.kubernetes.io/pci-10de.present"` |  |
| nvidia-device-plugin.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].operator | string | `"In"` |  |
| nvidia-device-plugin.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[0].matchExpressions[0].values[0] | string | `"true"` |  |
| nvidia-device-plugin.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[1].matchExpressions[0].key | string | `"feature.node.kubernetes.io/cpu-model.vendor_id"` |  |
| nvidia-device-plugin.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[1].matchExpressions[0].operator | string | `"In"` |  |
| nvidia-device-plugin.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[1].matchExpressions[0].values[0] | string | `"NVIDIA"` |  |
| nvidia-device-plugin.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[2].matchExpressions[0].key | string | `"nvidia.com/gpu.present"` |  |
| nvidia-device-plugin.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[2].matchExpressions[0].operator | string | `"In"` |  |
| nvidia-device-plugin.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[2].matchExpressions[0].values[0] | string | `"true"` |  |
| nvidia-device-plugin.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[3].matchExpressions[0].key | string | `"kubernetes.azure.com/accelerator"` |  |
| nvidia-device-plugin.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[3].matchExpressions[0].operator | string | `"In"` |  |
| nvidia-device-plugin.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms[3].matchExpressions[0].values[0] | string | `"nvidia"` |  |
| nvidia-device-plugin.enabled | bool | `true` |  |
| nvidia-device-plugin.tolerations[0].key | string | `"CriticalAddonsOnly"` |  |
| nvidia-device-plugin.tolerations[0].operator | string | `"Exists"` |  |
| nvidia-device-plugin.tolerations[1].effect | string | `"NoSchedule"` |  |
| nvidia-device-plugin.tolerations[1].key | string | `"nvidia.com/gpu"` |  |
| nvidia-device-plugin.tolerations[1].operator | string | `"Exists"` |  |
| nvidia-device-plugin.tolerations[2].effect | string | `"NoSchedule"` |  |
| nvidia-device-plugin.tolerations[2].key | string | `"sku"` |  |
| nvidia-device-plugin.tolerations[2].operator | string | `"Equal"` |  |
| nvidia-device-plugin.tolerations[2].value | string | `"gpu"` |  |
| nvidia-device-plugin.tolerations[3].effect | string | `"NoSchedule"` |  |
| nvidia-device-plugin.tolerations[3].key | string | `"kubernetes.azure.com/scalesetpriority"` |  |
| nvidia-device-plugin.tolerations[3].operator | string | `"Equal"` |  |
| nvidia-device-plugin.tolerations[3].value | string | `"spot"` |  |

## Source Code

* <https://github.com/nebuly-ai/helm-charts>
