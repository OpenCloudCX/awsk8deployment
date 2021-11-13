Param(
    [string]$AwsProfile
)


$_k8sName = $(aws eks list-clusters --profile $AwsProfile | ConvertFrom-Json)[0].clusters
# Connect to eks cluster
aws eks --region us-east-1 update-kubeconfig --name "$_k8sName" --profile $AwsProfile

Write-Output "Cluster Name --> $_k8sName" 
Write-Output ""

$_dashboardToken=$(kubectl get secret -n dashboard $(kubectl get sa/k8s-dashboard-admin --namespace dashboard -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}")
Write-Output "Dashboard token --> $_dashboardToken"
Write-Output ""

$_jenkinsPw = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($(kubectl get secret --namespace jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}")))
$_grafanaPw = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($(kubectl get secret --namespace opencloudcx grafana-admin -o jsonpath="{.data.password}")))
$_codeserverPw = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($(kubectl get secret --namespace develop codeserver-password -o jsonpath="{.data.password}")))

Write-Output "Services and Passwords"
Write-Output "----------------------"
Write-Output "Jenkins     $_jenkinsPw"
Write-Output "Grafana     $_grafanaPw"
Write-Output "CodeServer  $_codeserverPw"

Write-Output ""
