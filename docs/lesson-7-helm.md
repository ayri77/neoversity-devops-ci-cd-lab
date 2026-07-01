# Lesson 7 — Helm Deployment to EKS

## Goal

The goal of this lesson is to deploy a Django application to an AWS EKS cluster using Helm.

The infrastructure is created with Terraform, the Docker image is stored in Amazon ECR, and the application is deployed to Kubernetes using a custom Helm chart.

## Components

### Terraform

- VPC
- Public and private subnets
- NAT Gateway
- Internet Gateway
- EKS cluster
- EKS managed node group
- ECR repository

### Docker

- Django application image
- Image pushed to Amazon ECR

### Kubernetes / Helm

- Deployment for Django
- Service of type `LoadBalancer`
- ConfigMap for environment variables
- HorizontalPodAutoscaler
- PostgreSQL Deployment and Service for the Django database
- Optional Ingress template, disabled by default

## Project structure

```text
django-chart/
├── Chart.yaml
├── values.yaml
└── templates/
    ├── configmap.yaml
    ├── deployment.yaml
    ├── hpa.yaml
    ├── ingress.yaml
    ├── postgres.yaml
    └── service.yaml
```

## Terraform infrastructure

Go to the Terraform directory:

```bash
cd terraform
```

Format and validate Terraform files:

```bash
terraform fmt -recursive
terraform validate
```

Create AWS infrastructure:

```bash
terraform plan
terraform apply
```

After successful deployment, Terraform creates:

- EKS cluster: `lesson-7-eks`
- ECR repository: `lesson-7-ecr`

Example Terraform outputs:

```text
ecr_repository_url = "487337210313.dkr.ecr.eu-central-1.amazonaws.com/lesson-7-ecr"
eks_cluster_name   = "lesson-7-eks"
```

## Configure kubectl

```bash
aws eks update-kubeconfig \
  --region eu-central-1 \
  --name lesson-7-eks
```

Check EKS nodes:

```bash
kubectl get nodes
```

Expected result:

```text
STATUS   ROLES    VERSION
Ready    <none>   v1.36.x-eks-...
```

## Build and push Docker image to ECR

Set ECR repository URL:

```bash
export ECR_REPOSITORY_URL=487337210313.dkr.ecr.eu-central-1.amazonaws.com/lesson-7-ecr
```

Login to ECR:

```bash
aws ecr get-login-password --region eu-central-1 \
  | docker login \
    --username AWS \
    --password-stdin 487337210313.dkr.ecr.eu-central-1.amazonaws.com
```

Build Docker image:

```bash
export IMAGE_TAG=allowed-hosts
docker build -t lesson-7-django:$IMAGE_TAG docker/django
```

Tag image for ECR:

```bash
docker tag lesson-7-django:$IMAGE_TAG $ECR_REPOSITORY_URL:$IMAGE_TAG
```

Push image to ECR:

```bash
docker push $ECR_REPOSITORY_URL:$IMAGE_TAG
```

## Helm chart validation

From the project root:

```bash
helm lint django-chart
```

Render Kubernetes manifests locally:

```bash
helm template my-django django-chart
```

## Deploy application with Helm

Install the Helm release:

```bash
helm install my-django django-chart
```

If the release already exists, update it:

```bash
helm upgrade my-django django-chart
```

Check Helm release:

```bash
helm list
```

Expected result:

```text
NAME        NAMESPACE   REVISION   STATUS     CHART
my-django   default     1          deployed   django-chart-0.1.0
```

## Check Kubernetes resources

```bash
kubectl get all
```

Expected resources:

```text
pod/my-django-django-...       1/1 Running
pod/my-django-postgres-...     1/1 Running

service/db                     ClusterIP
service/my-django-django       LoadBalancer

deployment.apps/my-django-django
deployment.apps/my-django-postgres

horizontalpodautoscaler.autoscaling/my-django-django
```

## External access

Get the LoadBalancer address:

```bash
kubectl get svc my-django-django
```

Example:

```text
a6720a18ab9ec48059fede2d4b5d04c8-1335644762.eu-central-1.elb.amazonaws.com
```

Check HTTP response:

```bash
curl -I http://a6720a18ab9ec48059fede2d4b5d04c8-1335644762.eu-central-1.elb.amazonaws.com
```

Expected result:

```text
HTTP/1.1 200 OK
```

## HorizontalPodAutoscaler

The Helm chart creates an HPA resource:

```bash
kubectl get hpa
```

Example output:

```text
NAME               REFERENCE                     TARGETS              MINPODS   MAXPODS   REPLICAS
my-django-django   Deployment/my-django-django   cpu: <unknown>/70%   1         3         1
```

The HPA resource was created successfully. CPU metrics may be shown as `<unknown>` if `metrics-server` is not installed in the cluster.

## Notes

The Django application requires PostgreSQL. A simple PostgreSQL Deployment and internal ClusterIP Service named `db` were added to the Helm chart so that the Django application can connect to the database using:

```text
POSTGRES_HOST=db
```

The Ingress template is included in the chart but disabled by default:

```yaml
ingress:
  enabled: false
```

The bonus task with Ingress and TLS was not implemented. The application is exposed using a Kubernetes Service of type `LoadBalancer`, as required in the main task.

## Cleanup

Delete the Helm release:

```bash
helm uninstall my-django
```

Destroy AWS infrastructure:

```bash
cd terraform
terraform destroy
```

This is important because EKS, EC2 nodes, NAT Gateway, Elastic IP, and Load Balancer are paid AWS resources.
