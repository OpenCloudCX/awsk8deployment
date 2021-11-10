##################################
## Jenkins 

resource "aws_secretsmanager_secret" "jenkins_secret" {
  name                    = "${random_string.random.id}-jenkins"
  recovery_window_in_days = 0
}

resource "random_password" "jenkins_password" {
  length           = 24
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret_version" "jenkins_secret_version" {
  secret_id     = aws_secretsmanager_secret.jenkins_secret.id
  secret_string = "{\"username\": \"admin\", \"password\": \"${random_password.jenkins_password.result}\"}"
}


##################################
## Portainer

resource "aws_secretsmanager_secret" "portainer_secret" {
  name                    = "${random_string.random.id}-portainer"
  recovery_window_in_days = 0
}

resource "random_password" "portainer_password" {
  length           = 24
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret_version" "portainer_secret_version" {
  secret_id     = aws_secretsmanager_secret.portainer_secret.id
  secret_string = "{\"username\": \"admin\", \"password\": \"${random_password.portainer_password.result}\"}"
}


##################################
## Sonarqube

resource "aws_secretsmanager_secret" "sonarqube_secret" {
  name                    = "${random_string.random.id}-sonarqube"
  recovery_window_in_days = 0
}

resource "random_password" "sonarqube_password" {
  length           = 24
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret_version" "sonarqube_secret_version" {
  secret_id     = aws_secretsmanager_secret.sonarqube_secret.id
  secret_string = "{\"username\": \"admin\", \"password\": \"${random_password.sonarqube_password.result}\"}"
}

##################################
## Code-Server 

resource "aws_secretsmanager_secret" "code_server_secret" {
  name                    = "${random_string.random.id}-code_server"
  recovery_window_in_days = 0
}

resource "random_password" "code_server_password" {
  length           = 24
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret_version" "code_server_secret_version" {
  secret_id     = aws_secretsmanager_secret.code_server_secret.id
  secret_string = "{\"username\": \"admin\", \"password\": \"${random_password.code_server_password.result}\"}"
}

##################################
## Keycloak

resource "aws_secretsmanager_secret" "keycloak_admin_secret" {
  name                    = "${random_string.random.id}-keycloak-admin"
  recovery_window_in_days = 0
}

resource "random_password" "keycloak_admin_password" {
  length           = 24
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret_version" "keycloak_admin_secret_version" {
  secret_id     = aws_secretsmanager_secret.keycloak_admin_secret.id
  secret_string = "{\"username\": \"admin\", \"password\": \"${random_password.keycloak_admin_password.result}\"}"
}


resource "aws_secretsmanager_secret" "keycloak_user_secret" {
  name                    = "${random_string.random.id}-keycloak-user"
  recovery_window_in_days = 0
}

resource "random_password" "keycloak_user_password" {
  length           = 24
  special          = true
  override_special = "_%@"
}

resource "aws_secretsmanager_secret_version" "keycloak_user_secret_version" {
  secret_id     = aws_secretsmanager_secret.keycloak_user_secret.id
  secret_string = "{\"username\": \"user\", \"password\": \"${random_password.keycloak_user_password.result}\"}"
}




