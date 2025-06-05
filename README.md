# Kubernetes Deployment Example

This repository demonstrates a simple Kubernetes deployment using GitLab CI/CD.
The pipeline expects a base64 encoded kubeconfig in the `KUBE_CONFIG` CI/CD
variable. A self-hosted GitLab Runner executes the job and applies the manifests
found in the `k8s/` directory.

1. Build your Docker image in the BMC repository or another project.
2. Push the image to your container registry.
3. Update `k8s/deployment.yaml` with the new image reference.
4. Commit and push the changes to run the deployment pipeline.

The provided `.gitlab-ci.yml` defines a single `deploy` job that configures
kubectl and applies the manifests to your EKS cluster.
