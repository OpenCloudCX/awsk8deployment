# Full example of spinnaker module for AWS

## Usage example
You can use this module like below. This shows how to create the resources for spinnaker. This module will create vpc, subnets, s3 bucket, iam policies and kubernetes cluster.

### Setup
This is the first step to create a spinnaker cluster. Just get terraform module and apply it with your custom variables.
```hcl
# Complete example

terraform {
  required_version = "~> 0.14.2"
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  version             = ">= 3.0"
}

provider "aws" {
  alias               = "prod"
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]
  version             = ">= 3.0"
}


module "opencloudcx" {
  source  = "OpenCloudCX/opencloudcx/aws"
  version = "~> 0.1.0"

  name               = "example"
  stack              = "dev"
  detail             = "module-test"
  tags               = { "env" = "dev" }
  region             = "us-east-1"
  azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
  cidr               = "10.0.0.0/16"
  dns_zone           = "your.private"
  kubernetes_version = "1.17"
  kubernetes_node_groups = {
    default = {
      instance_type = "m5.large"
      min_size      = "1"
      max_size      = "3"
      desired_size  = "2"
    }
  }
  aurora_cluster = {
    node_size = "1"
    node_type = "db.t3.medium"
    version   = "5.7.12"
  }
  helm_chart_version = "2.1.0-rc.1"
  helm_chart_values  = [file("values.yaml")]
  assume_role_arn    = [module.spinnaker-managed-role.role_arn]
}

# spinnaker managed role
module "spinnaker-managed-role" {
  source  = "OpenCloudCX/opencloudcx/aws//modules/spinnaker-managed-aws"
  version = "~> 0.1.0"

  providers        = { aws = aws.prod }
  name             = "example"
  stack            = "dev"
  trusted_role_arn = [module.opencloudcx.role_arn]
}

```
Run terraform:
```
terraform init
terraform apply
```
Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```
terraform plan -var-file=default.tfvars
terraform apply -var-file=default.tfvars
```
After then you will see so many resources like EKS, S3, IAM, RDS, and others on AWS. 

### Validate Installation
aws eks --region us-east-1 update-kubeconfig --name "EKS-CLUSTER-NAME i.e. example-dev-module-test-lrlf"
  
kubectl get pods --all-namespaces

- kubectl -n spinnaker port-forward svc/spin-deck 9000:9000 &
- kubectl -n opencloudcx port-forward svc/grafana 3000:3000 &
- kubectl -n opencloudcx port-forward svc/prometheus 9090:9090 &

- Navigate to http://localhost:9000/ in your browser to access Spinnakers

### When you want to delete
rm -rf .terraform*

rm -rf tfstate files inside your terraform execution dir 

### Jenkins 
* http://100.25.48.203/
* admin/rebellis

### Sonarqube
* http://3.82.232.178/
* admin/rebellis

### Portainer
* kubectl get svc --all-namespaces
* You should see a line like this:
* portainer     portainer                     LoadBalancer   172.20.49.121    ab1a9a5a20c6645c1b7ebe9e21374879-1220642400.us-east-1.elb.amazonaws.com   9000:31776/TCP,8000:32602/TCP   13d

* Point your browser to i.e. http://ab1a9a5a20c6645c1b7ebe9e21374879-1220642400.us-east-1.elb.amazonaws.com:9000 and setup the admin user/password. Keep it simple in line with Jenkins or Sonarqube.


### Configure Spinnaker for Jenkins: https://spinnaker.io/setup/ci/jenkins/
* Get to the command line for the Spinnaker Halyard container (Use kubectl or Portainer via web browser)
##### Run the following commands:
* hal config ci jenkins enable
* echo TOKEN | hal config ci jenkins master add jenkins --address http://100.25.48.203/ --username admin --password
* hal deploy apply

### Enable Spinnaker Prometheus Integration
* https://spinnaker.io/setup/monitoring/prometheus/

### Canary
* https://spinnaker.io/setup/canary/
