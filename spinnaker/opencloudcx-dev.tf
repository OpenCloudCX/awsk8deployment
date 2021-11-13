module "opencloudcx" {
  # source  = "OpenCloudCX/opencloudcx/aws"
  # version = ">= 0.3.15"

  source = "../../terraform-aws-opencloudcx"

  name               = "riva"
  stack              = "dev"
  detail             = "module-test"
  tags               = { "env" = "dev" }
  region             = "us-east-1"
  azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
  cidr               = "10.0.0.0/16"
  dns_zone           = var.dns_zone
  kubernetes_version = "1.21"
  kubernetes_node_groups = {
    default = {
      instance_type = "m5.large"
      min_size      = "1"
      max_size      = "4"
      desired_size  = "3"
    }
  }

  jenkins_secret        = random_password.jenkins_password.result
  sonarqube_secret      = random_password.sonarqube_password.result
  keycloak_admin_secret = random_password.keycloak_admin_password.result
  keycloak_user_secret  = random_password.keycloak_user_password.result
  code_server_secret    = random_password.code_server_password.result
  grafana_secret        = random_password.grafana_password.result

  aws_account_id        = var.aws_account_id

  aurora_cluster = {
    node_size = "1"
    node_type = "db.t3.medium"
    version   = "5.7.12"
  }

  helm_chart_version = "2.2.3"
  helm_chart_values  = [file("values.yaml")]
  assume_role_arn = [module.spinnaker-managed-role.role_arn]
}

module "spinnaker-managed-role" {
  # source  = "OpenCloudCX/opencloudcx/aws//modules/spinnaker-managed-aws"
  # version = "~> 0.3.15"

  source = "../../terraform-aws-opencloudcx/modules/spinnaker-managed-aws"

  providers        = { aws = aws.prod }
  name             = "riva"
  stack            = "dev"
  trusted_role_arn = [module.opencloudcx.role_arn]
}
