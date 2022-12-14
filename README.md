# Infra
- Terraform to create EKS cluster(s), bootstrap ArgoCD, and create required aws objects required to run EKS
- ArgoCD installs crossplane, ingress-nginx, (etc)
- Crossplane manages resources that the applications in said cluster need (RDS, S3, etc)


## Prerequisites 
* Direnv
* kubectl
* terraform
* awscli

## Quickstart

Setup env, and variables
```
cp .envrc.example .envrc
vi .envrc
direnv allow
```
Apply an environment

```
cd stage/tf
terraform init
terraform plan
terraform apply
```

## Directory Structure
```
.
├── README.md
├── global
│   ├── module1
│   ├── module2
├── prod 
│   ├── gitops
│   │   └── applications
│   └── tf
└── stage
    ├── gitops
    │   └── applications
    └── tf
```
#### `./global/`
- Houses folders for "global" terraform modules. Resources that all environments could potentially use go here. (route53 hosted zones)

#### `./{{env}}/tf`
- The terraform module for the {{env}} environment. 

#### `./{{env}}/gitops`
- The directory where ArgoCD will look for manifests