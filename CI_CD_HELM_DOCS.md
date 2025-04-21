# CI/CD Pipeline and Helm Deployment Documentation

## Overview

This repository includes a complete CI/CD pipeline using GitHub Actions that:
1. Tests the application code
2. Builds Docker images for all microservices
3. Pushes the images to Docker Hub
4. Deploys the application to Kubernetes using Helm

## Prerequisites

To use this CI/CD pipeline, you'll need:

1. A GitHub repository with the code
2. A Docker Hub account
3. A Kubernetes cluster
4. Helm installed on your local machine for testing

## GitHub Actions Setup

The CI/CD pipeline is configured in `.github/workflows/ci-cd-pipeline.yml`. To enable it, you need to add the following secrets to your GitHub repository:

- `DOCKER_USERNAME`: Your Docker Hub username
- `DOCKER_PASSWORD`: Your Docker Hub password or access token
- `KUBE_CONFIG_DATA`: Base64-encoded Kubernetes config file
- `JWT_SECRET_KEY`: JWT secret key for the application
- `GOOGLE_CLIENT_ID`: Google OAuth client ID
- `GOOGLE_CLIENT_SECRET`: Google OAuth client secret
- `GOOGLE_ADMIN_EMAILS`: Admin email addresses for Google OAuth
- `POSTGRES_PASSWORD`: PostgreSQL database password

### How to get base64-encoded Kubernetes config:

```bash
cat ~/.kube/config | base64 -w 0
```

## Helm Chart Structure

The Helm chart is located in the `helm/meeting-room-system` directory:

```
helm/meeting-room-system/
├── Chart.yaml           # Chart metadata
├── values.yaml          # Default configuration values
└── templates/           # Kubernetes manifest templates
    └── namespace.yaml   # Namespace definition
    └── ... other templates
```

## Local Deployment with Helm

To deploy the application locally using Helm:

```bash
# Install or upgrade the release
helm upgrade --install meeting-room-system ./helm/meeting-room-system \
  --namespace meeting-room-system \
  --create-namespace \
  --values ./helm/meeting-room-system/values.yaml \
  --set secrets.jwt.secretKey="your-jwt-secret" \
  --set secrets.googleOAuth.clientId="your-google-client-id" \
  --set secrets.googleOAuth.clientSecret="your-google-client-secret" \
  --set secrets.googleOAuth.adminEmails="admin@example.com" \
  --set secrets.postgres.password="secure-password"

# Check the deployment status
kubectl get pods -n meeting-room-system
```

## CI/CD Pipeline Workflow

The pipeline follows these steps:

1. **Test Stage**:
   - Checks out the code
   - Sets up Python environment
   - Installs dependencies
   - Runs tests (placeholder for actual test commands)

2. **Build and Push Stage**:
   - Only runs on the main branch after a successful push
   - Sets up Docker Buildx
   - Logs in to Docker Hub
   - Builds and pushes Docker images for all three microservices
   - Tags images with both `latest` and a timestamp-based version
   - Utilizes Docker layer caching to speed up builds

3. **Deploy Stage**:
   - Sets up kubectl and Helm
   - Configures Kubernetes connection using the provided kubeconfig
   - Updates Helm values with the new image version
   - Deploys or upgrades the application using Helm
   - Verifies the deployment

## Manual Triggering

You can manually trigger the workflow from the GitHub Actions tab in your repository.

## Customizing the Deployment

To customize the deployment, modify the `values.yaml` file in the Helm chart. This file includes configurations for:

- Docker image registry and repository
- Resource allocations (CPU, memory)
- Database configurations
- Kafka and Zookeeper settings
- Microservices configurations
- Ingress controller settings
- Secret placeholders

## Security Considerations

- Never commit secrets directly to the repository
- For production, consider using a secrets management solution like HashiCorp Vault or Kubernetes Secrets Manager
- Review the RBAC permissions for your service accounts
- Enable network policies to restrict communication between pods

## Troubleshooting

If the CI/CD pipeline fails:

1. Check the GitHub Actions logs for detailed error messages
2. Verify that all required secrets are correctly configured
3. Ensure your Kubernetes cluster is accessible from GitHub Actions
4. Check the Helm chart for any configuration errors
5. Verify Docker Hub credentials and permissions