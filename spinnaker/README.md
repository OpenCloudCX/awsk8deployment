# Full example of OpenCloudCX setup in AWS

This repository contains a framework to use for creation of an OpenCloudCX cluster. After cloning this repository, refer to the below sections for configuration.

# Toolsets

This project uses multiple open source toolsets for environment creation. 

|Toolset|Links|Notes|
|---|---|---|
|Terraform&nbsp;(version&nbsp;0.14.2)|[Download](https://releases.hashicorp.com/terraform/0.14.2/) | Terraform is distributed as a single binary. Install Terraform by unzipping it and moving it to a directory included in your system's [PATH](https://superuser.com/questions/284342/what-are-path-and-other-environment-variables-and-how-can-i-set-or-use-them) |
|AWS&nbsp;CLI|[Instructions](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html) \|\| [Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)|This link provides information for getting started with version 2 of the AWS Command Line Interface (AWS CLI)|
|kubectl|[Instructions](https://kubernetes.io/docs/tasks/tools/#kubectl)|Allows commands to be executed against Kubernetes clusters|
| Git |[Instructions](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)| need to run this command to avoid a CRLF issues: git config --global core.autocrlf input|

# Setup

Once all toolsets are installed and verified to be operational, configure the cloned bootstrap project.

## AWS S3 State Bucket
OpenCloudCX uses Terraform state buckets to store all infrastructure snapshot information (e.g., S3 buckets, VPC, EC2, EKS). State buckets allow for teams to have a centralized souce of truth for the infrastructure. Per AWS S3 requirements, this bucket name needs to be globally unique. This bucket is not created automatically and needs to be in place before the terraform project is initialized. 

Follows [these]() instructions to create a unique bucket in the account where OpenCloudCX is going to be installed. A good conventioni for this project is to create and use ```opencloucx-state-bucket-####``` and replace ```####``` with the last 4 digits of the AWS account number. 

Once the bucket has been created, change the state bucket name in the ```main.tf``` file of this project. 

```bash
  backend "s3" {
    key    = "opencloudcx"
    bucket = "opencloudcx-state-bucket-####"
    region = "us-east-1"
  }
```

## Project Variables

Create a copy of the ```variables.example.tfvars``` file and name it ```variables.auto.tfvars```. If another filename needs to be used, Terraform automatically loads a number of variable definitions files if named the following way:
* Files named exactly ```terraform.tfvars``` or ```terraform.tfvars.json```
* Any files with names ending in ```.auto.tfvars``` or ```.auto.tfvars.json```

### AWS Account Number

Update the account number in the project variables file. 

```bash
aws_account_id     = "123456789012"
```

### OPTIONAL: DNS CONFIGURATION

To experience the full impact of an OpenCloudCX installation, a valid, publicly accessible DNS zone needs to be supplied within the configuration. The default DNS Zone of ```spinnaker.internal``` can be used for initial prototyping with appropriate local hosts file manipulation. 

DNS configuration changes are made in the project variables file.

```bash
dns_zone           = "spinnaker.internal"
```

## Check version of terraform modules
There are 2 sections within the ```main.tf``` file where the version of the terraform module can be changed. In the below snippets, the current version is ```0.3.13```. This number should correspond to the latest version at the [OpenCloudCX Terraform Module](https://registry.terraform.io/modules/OpenCloudCX/opencloudcx/aws/latest) page.

```bash
module "opencloudcx" {
  source  = "OpenCloudCX/opencloudcx/aws"
  version = ">= 0.3.15"
```

```bash
module "spinnaker-managed-role" {
  source  = "OpenCloudCX/opencloudcx/aws//modules/spinnaker-managed-aws"
  version = "~> 0.3.15"
```

# Environment creation

## Initialize Terraform and Execute

### ```terraform init```

The ```init``` command tells Terraform to initialize the project from the current working directory of terraform configurations. If commands relying on initialization are executed before this step, the command will fail with an error.

From [terraform.io](https://www.terraform.io/docs/cli/init/index.html)

>Initialization performs several tasks to prepare a directory, including accessing state in the configured backend, downloading and installing provider plugins, and downloading modules. Under some conditions (usually when changing from one backend to another), it might ask the user for guidance or confirmation.

### ```terraform apply```

From [terraform.io](https://www.terraform.io/docs/cli/commands/apply.html)

>The terraform apply command performs a plan just like terraform plan does, but then actually carries out the planned changes to each resource using the relevant infrastructure provider's API. It asks for confirmation from the user before making any changes, unless it was explicitly told to skip approval.
### Command Execution

Execute these two commands in succession.

```
$ terraform init
$ terraform apply --auto-approve
```

If you receive the following error, confirm the s3 state bucket referenced above is correct

```bash
Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.
Error refreshing state: AccessDenied: Access Denied
        status code: 403, request id: <string> host id: <string>
```


---
_NOTE: Terraform assumes the current ```[default]``` profile contains the appropriate credentials for environment initialization. If this is not correct, each Terraform command needs to be prefixed with ```AWS_PROFILE=``` and the desired AWS profile to use._
On Linux this can be found in your home directory .aws update both credentials and config file
On Windows C:\Users\[username]\.aws update both credentials and config file
```
$ AWS_PROFILE=<profile name> terraform init
$ AWS_PROFILE=<profile name> terraform apply --auto-approve
```
---

Once Terraform instructions have been applied, the following message will be displayed 

<span style='font-size: 13pt; color: green'>Apply complete! Resources: ### added, 0 changed, 0 destroyed.</span>
# Environment Validation

Once a successful message of completion has been achieved, connect to the OpenCloudCX cluster by executing the ```connect.sh``` command with the desired AWS profile.

```bash
$ connect.sh --profile <profile name>
```

Output:
|Label|Description|
|---|---|
|Cluster name|Name of the Kubernetes cluster for OpenCloudCX. This name will always contain a 4-character randomized string at the end|
|Dashboard&nbsp;token|Token for use when authenticating to the Kubeternetes dashboard (see below)|
|Jenkins PW|Jenkins admin password|

Execute following command to list the PODS in the cluster

```bash
$ kubectl get namespaces -A

NAME                   STATUS   AGE
anchore-engine         Active   9h
cert-manager           Active   9h
dashboard              Active   9h
default                Active   9h
develop                Active   9h
ingress-nginx          Active   9h
ingress-nginx-secure   Active   9h
jenkins                Active   9h
kube-node-lease        Active   9h
kube-public            Active   9h
kube-system            Active   9h
opencloudcx            Active   9h
portainer              Active   9h
sonarqube              Active   9h
spinnaker              Active   9h
```

# OpenCloudCX Constituents and Credentials

To access the individual toolsets contained within the OpenCloudCX enclave, use the following URLs, with the appropriate DNS zone from above, paired with the credentials outlined.

|Name|URL|Username|Password Location|
|---|---|---|---|
|Code Server| ```https://code-server.[DNS ZONE]```|None|AWS Secrets Manager|
|Dashboard| ```https://dashboard.[DNS ZONE]```|None|```connect.sh``` token output|
|Grafana| ```https://grafana.[DNS ZONE]```|admin|AWS Secrets Manager|
|Jenkins| ```https://jenkins.[DNS ZONE]```|admin|AWS Secrets Manager or ```connect.sh``` token output|
|Keycloak| ```https://keycloak.[DNS ZONE]```|user|AWS Secrets Manager|
|Selenium| ```https://selenium.[DNS ZONE]```|None|None|
|SonarQube| ```https://sonarqube.[DNS ZONE]```|admin|AWS Secrets Manager|
|Spinnaker| ```https://spinnaker.[DNS ZONE]```|None|None|

# Code-Server configuration

The OpenCloudCX enclave include an out-of-the-box Code Server instance allowing for a browser-based VSCode instance. Once the password has been retrieved from AWS Secrets Manager and used to authenticate to the server, some generic configuration will be necessary.

## Create SSH Key
Each instance will need to create their own SSH key for use within the github repository. To bring up the console within Code-Server, press ```SHIFT-~``` and a terminal window will display at the bottom of the browser page. 

```bash
$ ssh-keygen

Generating public/private rsa key pair.
Enter file in which to save the key (/home/kodelib/.ssh/id_rsa): <enter>
Created directory '/home/kodelib/.ssh'.
Enter passphrase (empty for no passphrase): <enter>
Enter same passphrase again: <enter>
Your identification has been saved in /home/kodelib/.ssh/id_rsa
Your public key has been saved in /home/kodelib/.ssh/id_rsa.pub
```

Use [these instructions](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) to copy the public key from ```id_rsa.pub``` to github.

NOTE: If a 403 error message occurs when attempting to push changes to the repository after keys have been exchanged, check the ```url``` in ```.git/config``` file. If it begins with ```https://github.com```, change it to ```ssh://git@github.com/```. Further reference is in [stack**overflow**](https://stackoverflow.com/questions/7438313/pushing-to-git-returning-error-code-403-fatal-http-request-failed/)

