#!/bin/bash

function usage() {
    echo "usage: connect.sh [options]"
    echo " "
    echo "  options:"
    echo " "
    echo "    -p, --profile   AWS profile name to use for execution"
    echo "    -d. --default   Use default profile"
    echo " "
}

_POSITIONAL=()
while [[ $# -gt 0 ]]
do
_key="$1"

case $_key in
  -p|--profile)
    _PROFILE="$2"
    shift
    shift
    ;;
  -d|--default)
    _PROFILE="default"
    shift
    shift
    ;;
  *)
    _POSITIONAL+=("$1")
    echo "!! Unknown parameter [$_key]"
    shift
    ;;
esac
done

set -- "${POSITIONAL[@]}"

if [ -z "$_PROFILE" ]; then
  echo " "
  echo "No profile specified. Defaulting to [default] entry in configuration (~/.aws/credentials). Use -p to specify a named profile to use."
  _PROFILE="default"
fi
_k8sName=$(aws eks list-clusters --profile $_PROFILE --region us-east-1 | jq -r ".clusters[0]")

if [ -z "$_k8sName" ]; then
  echo " "
  echo "No kubernetes cluster found for [$_PROFILE] profile. Exiting."
  exit
fi

# do the mubectl thing
aws eks --region us-east-1 update-kubeconfig --name "$_k8sName" --profile $_PROFILE
echo''

# get k8s node name and store it
echo "Cluster name --> $_k8sName"
echo''

# print dashboard token
_dashboardToken=$(kubectl get secret -n dashboard $(kubectl get sa/k8s-dashboard-admin --namespace dashboard -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}")
echo "Dashboard token --> $_dashboardToken"
echo''

_passwordTable=""

#display passwords
_jenkinsPw=$(kubectl get secret --namespace jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode) 
_passwordTable="${_passwordTable}\nJenkins,${_jenkinsPw}"

_grafanaPw=$(kubectl get secret --namespace opencloudcx grafana-admin -o jsonpath="{.data.password}" | base64 --decode)
_passwordTable="${_passwordTable}\nGrafana,${_grafanaPw}"

_codeserverPw=$(kubectl get secret --namespace develop codeserver-password -o jsonpath="{.data.password}" | base64 --decode)
_passwordTable="${_passwordTable}\nCodeServer,${_codeserverPw}"

echo "Services and Passwords"
echo "----------------------"
echo -e $_passwordTable | column -t -s ',' 