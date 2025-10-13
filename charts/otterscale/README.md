# OtterScale Helm Chart

A production-ready Helm chart for deploying OtterScale with PostgreSQL database and Istio service mesh integration.

## Overview

OtterScale is a comprehensive platform for Kubernetes, containers, virtualization, storage, GPU management, and more. This Helm chart provides a streamlined way to deploy the OtterScale service and web UI with all necessary dependencies, including optional Istio service mesh integration for advanced traffic management and observability.

## Features

- **Complete Stack**: Deploys OtterScale API service, Web UI, and PostgreSQL database
- **Istio Service Mesh**: 
  - Automatic Istio installation (base + istiod) via Helm dependencies
  - Automatic sidecar injection for application pods
  - Istio Gateway for external traffic ingress
  - VirtualService for intelligent traffic routing
  - DestinationRule for advanced traffic policies
  - Optional Istio Ingress Gateway deployment
- **Security Best Practices**: 
  - Secrets management for sensitive data
  - Security contexts and non-root containers
  - Read-only root filesystems where applicable
  - Resource limits and requests
  - mTLS encryption via Istio (when enabled)
- **High Availability**: Configurable replicas and health checks
- **Production Ready**: Comprehensive monitoring, logging, and observability support

## Prerequisites

- Kubernetes 1.30.0+
- Helm 3.0+
- Persistent Volume provisioner (for PostgreSQL data persistence)
- (Optional) LoadBalancer support for Istio Ingress Gateway

## Quick Start

### Option 1: Deploy with Istio (Recommended)

```bash
# 1. Update Helm dependencies (downloads Istio charts)
helm dependency update

# 2. Install with Istio enabled (default)
helm install otterscale . \
  --namespace otterscale \
  --create-namespace \
  --wait \
  --timeout 10m
```

This will:
- Install Istio base (CRDs) in `istio-system` namespace
- Install Istiod (control plane) in `istio-system` namespace
- Label `otterscale` namespace with `istio-injection=enabled`
- Deploy OtterScale services with Istio sidecar proxies
- Create Istio Gateway and VirtualServices for traffic routing

### Option 2: Deploy without Istio

```bash
helm install otterscale . \
  --namespace otterscale \
  --create-namespace \
  --set istio.enabled=false \
  --wait
```

## Installation

### Detailed Installation Steps

#### 1. Prepare Environment

```bash
# Create namespace
kubectl create namespace otterscale

# Verify cluster access
kubectl cluster-info
```

#### 2. Update Helm Dependencies

```bash
# Download Istio charts (if istio.enabled=true)
helm dependency update
```

#### 3. Customize Values (Optional)

Create a custom values file:

```bash
# Create a custom values file
cat > my-values.yaml <<EOF
appVersion: "v1.0.0"

postgres:
  password: "your-secure-password-here"
  persistence:
    size: 20Gi

otterscaleWeb:
  env:
    publicUrl: "https://otterscale.example.com"
    publicApiUrl: "https://api.otterscale.example.com"
    authSecret: "$(openssl rand -base64 32)"

istio:
  enabled: true
  gateway:
    servers:
      - port:
          number: 80
          name: http
          protocol: HTTP
        hosts:
          - "otterscale.example.com"
EOF

# Install with custom values
helm install otterscale . \
  --namespace otterscale \
  --create-namespace \
  --values my-values.yaml
```

### Installation with Istio

If you want to deploy Istio alongside OtterScale:

```bash
helm install otterscale . \
  --namespace otterscale \
  --create-namespace \
  --set istiod.enabled=true \
  --set istio.enabled=true
```

**Note**: If Istio is already installed in your cluster, keep `istiod.enabled=false` and only set `istio.enabled=true`.

## Configuration

### Key Configuration Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `appVersion` | OtterScale application version tag | `latest` |
| `postgres.db` | PostgreSQL database name | `mydb` |
| `postgres.user` | PostgreSQL username | `myuser` |
| `postgres.password` | PostgreSQL password | `mypass` |
| `postgres.persistence.enabled` | Enable persistent storage | `true` |
| `postgres.persistence.size` | Storage size for PostgreSQL | `10Gi` |
| `postgres.persistence.storageClass` | Storage class name | `""` (default) |
| `otterscale.replicas` | Number of API service replicas | `1` |
| `otterscale.resources.limits.memory` | Memory limit for API service | `512Mi` |
| `otterscale.resources.limits.cpu` | CPU limit for API service | `500m` |
| `otterscaleWeb.replicas` | Number of Web UI replicas | `1` |
| `otterscaleWeb.env.publicUrl` | Public URL for web application | `""` |
| `otterscaleWeb.env.publicApiUrl` | Public URL for API service | `""` |
| `otterscaleWeb.env.authSecret` | Authentication secret key | `""` |
| `istio.enabled` | Enable Istio integration | `true` |
| `istio.sidecarInjection.enabled` | Enable automatic sidecar injection | `true` |
| `istio.gateway.enabled` | Create Istio Gateway | `true` |
| `istiod.enabled` | Install Istio control plane | `false` |
| `gatekeeper.enabled` | Enable OPA Gatekeeper policy engine | `true` |
| `gatekeeper.replicas` | Number of Gatekeeper controller replicas | `3` |
| `gatekeeper.audit.interval` | Audit interval in seconds | `60` |
| `gatekeeper.validatingWebhook.failurePolicy` | Webhook failure policy (Fail/Ignore) | `Ignore` |
| `gatekeeper.logging.level` | Log level (DEBUG/INFO/WARNING/ERROR) | `INFO` |

### Complete Configuration

For a complete list of configurable parameters, see the extensively documented `values.yaml` file.

## OtterScale Configuration

The OtterScale service requires a configuration file. Edit the `configContent` in `values.yaml`:

```yaml
configContent: |
  server:
    host: 0.0.0.0
    port: 8299
  
  database:
    host: {{ include "otterscale.fullname" . }}-postgres
    port: 5432
    name: {{ .Values.postgres.db }}
  
  # Add your specific OtterScale configuration here
```

## Istio Configuration

### Basic Gateway Setup

```yaml
istio:
  enabled: true
  gateway:
    enabled: true
    servers:
      - port:
          number: 80
          name: http
          protocol: HTTP
        hosts:
          - "otterscale.example.com"
```

### HTTPS/TLS Setup

```yaml
istio:
  enabled: true
  gateway:
    enabled: true
    servers:
      - port:
          number: 443
          name: https
          protocol: HTTPS
        hosts:
          - "otterscale.example.com"
        tls:
          mode: SIMPLE
          credentialName: otterscale-tls-cert  # Kubernetes secret name
```

Before enabling HTTPS, create a TLS secret:

```bash
kubectl create secret tls otterscale-tls-cert \
  --cert=path/to/cert.pem \
  --key=path/to/key.pem \
  --namespace otterscale
```

### Virtual Service Routing

The chart automatically creates VirtualServices for API and Web traffic routing. Customize the routing in `values.yaml`:

```yaml
istio:
  virtualService:
    otterscale:
      enabled: true
      hosts:
        - "api.otterscale.example.com"
      http:
        - match:
            - uri:
                prefix: /api
          route:
            - destination:
                host: otterscale
                port:
                  number: 8299
          timeout: 30s
```

## OPA Gatekeeper Configuration

OPA Gatekeeper provides policy and governance for your Kubernetes cluster. It validates, mutates, and enforces policies using the Open Policy Agent (OPA).

### Basic Gatekeeper Setup

```yaml
gatekeeper:
  enabled: true
  replicas: 3                    # High availability with 3 replicas
  audit:
    interval: 60                 # Audit every 60 seconds
    constraintViolationsLimit: 20
  validatingWebhook:
    failurePolicy: Ignore        # Don't block resources if webhook fails
    timeoutSeconds: 3
  logging:
    level: INFO                  # INFO level logging
```

### Development Environment

For development, you might want more lenient settings:

```yaml
gatekeeper:
  enabled: true
  replicas: 1                    # Single replica for dev
  validatingWebhook:
    failurePolicy: Ignore        # Allow resources through if policy fails
  logging:
    level: DEBUG                 # Verbose logging for debugging
```

### Production Environment

For production, use stricter settings:

```yaml
gatekeeper:
  enabled: true
  replicas: 3                    # High availability
  validatingWebhook:
    failurePolicy: Fail          # Block non-compliant resources
    timeoutSeconds: 5
  audit:
    interval: 30                 # More frequent auditing
  logging:
    level: INFO
    logDenies: true              # Log policy violations
```

### Exempting Namespaces

You can exempt specific namespaces from policy enforcement:

```yaml
gatekeeper:
  controllerManager:
    exemptNamespaces:
      - kube-system
      - kube-public
      - gatekeeper-system
      - istio-system
```

### Resource Configuration

Adjust resources based on your cluster size:

```yaml
gatekeeper:
  controllerManager:
    resources:
      limits:
        memory: 1Gi              # Increase for larger clusters
        cpu: 1000m
      requests:
        cpu: 200m                # Increase for high policy load
        memory: 512Mi
```

### Policy Examples

After installing Gatekeeper, you can apply policies using ConstraintTemplates and Constraints. See the [Gatekeeper documentation](https://open-policy-agent.github.io/gatekeeper/website/docs/) for policy examples.

## Upgrading

```bash
# Upgrade with new values
helm upgrade otterscale . \
  --namespace otterscale \
  --values my-values.yaml

# Upgrade to a new app version
helm upgrade otterscale . \
  --namespace otterscale \
  --set appVersion=v1.2.0
```

## Uninstallation

```bash
# Uninstall the release
helm uninstall otterscale --namespace otterscale

# Note: PVCs are not automatically deleted. To delete them:
kubectl delete pvc -n otterscale -l app.kubernetes.io/instance=otterscale
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -n otterscale -l app.kubernetes.io/instance=otterscale
```

### View Logs

```bash
# API service logs
kubectl logs -n otterscale -l app.kubernetes.io/component=backend

# Web UI logs
kubectl logs -n otterscale -l app.kubernetes.io/component=frontend

# Database logs
kubectl logs -n otterscale -l app.kubernetes.io/component=database
```

### Check Istio Configuration

```bash
# Verify Gateway
kubectl get gateway -n otterscale

# Verify VirtualServices
kubectl get virtualservice -n otterscale

# Check Istio proxy status
istioctl proxy-status
```

### Check Gatekeeper Status

```bash
# Check Gatekeeper pods
kubectl get pods -n gatekeeper-system

# Check constraint violations
kubectl get constraints

# Check constraint templates
kubectl get constrainttemplates

# View Gatekeeper logs
kubectl logs -n gatekeeper-system -l control-plane=controller-manager

# Check webhook configurations
kubectl get validatingwebhookconfigurations | grep gatekeeper
kubectl get mutatingwebhookconfigurations | grep gatekeeper
```

### Common Issues

**PostgreSQL Connection Failed**
- Check if PostgreSQL pod is running: `kubectl get pods -n otterscale -l app.kubernetes.io/component=database`
- Verify credentials in the secret: `kubectl get secret -n otterscale`
- Check PostgreSQL logs for errors

**Cannot Access Web UI**
- If using Istio, verify Gateway has an external IP: `kubectl get svc -n istio-system istio-ingressgateway`
- Check VirtualService configuration matches your host settings
- Verify DNS points to the correct IP address

**Pods in CrashLoopBackOff**
- Check logs: `kubectl logs -n otterscale <pod-name>`
- Verify resource limits are sufficient
- Check if persistent volumes are provisioned correctly

**Gatekeeper Issues**
- **Webhook timeout**: Increase `gatekeeper.validatingWebhook.timeoutSeconds` value
- **Policy blocking resources**: Set `gatekeeper.validatingWebhook.failurePolicy: Ignore` for debugging
- **High resource usage**: Adjust `gatekeeper.controllerManager.resources` limits
- **Namespace exemption not working**: Verify `gatekeeper.controllerManager.exemptNamespaces` configuration
- **CRD conflicts**: Ensure `gatekeeper.upgradeCRDs.enabled: true` before upgrading

## Security Considerations

1. **Change Default Passwords**: Always change the default PostgreSQL password before production deployment
2. **Generate Strong Secrets**: Use `openssl rand -base64 32` to generate secure authentication secrets
3. **Use TLS**: Enable HTTPS/TLS for production deployments
4. **External Secrets**: Consider using external secret management solutions (e.g., HashiCorp Vault, AWS Secrets Manager)
5. **Network Policies**: Implement Kubernetes Network Policies to restrict traffic
6. **RBAC**: Apply appropriate RBAC rules for service accounts
7. **Policy Governance**: Use OPA Gatekeeper to enforce security and compliance policies
8. **Admission Control**: Configure Gatekeeper webhook failure policies appropriately for your environment

## Production Checklist

- [ ] Change all default passwords
- [ ] Generate and configure strong authentication secrets
- [ ] Configure TLS/HTTPS for external access
- [ ] Set appropriate resource limits and requests
- [ ] Configure persistent storage with appropriate storage class
- [ ] Set up monitoring and alerting
- [ ] Configure backup strategy for PostgreSQL
- [ ] Review and apply security contexts
- [ ] Configure Istio policies (if using service mesh)
- [ ] Configure OPA Gatekeeper policies and constraints
- [ ] Review Gatekeeper webhook failure policies
- [ ] Set up appropriate namespace exemptions for Gatekeeper
- [ ] Test disaster recovery procedures

## Contributing

Contributions are welcome! Please submit issues and pull requests to the repository.

## License

This Helm chart is provided as-is. Refer to the OtterScale project for application licensing.

## Support

For issues and questions:
- GitHub Issues: https://github.com/otterscale/otterscale/issues
- Documentation: https://docs.otterscale.io (if available)

## Chart Versioning

This chart follows semantic versioning. Check the `Chart.yaml` for the current version and compatibility information.
