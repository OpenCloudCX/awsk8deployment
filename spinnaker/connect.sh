#!/bin/bash

function usage() {
    echo "usage: connect.sh [options]\\n\\n"
    echo "  options:\\n\\n"
    echo "    -p, --profile\\t     AWS profile name to use for execution\\n"
    echo "\\n\\n"
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
  *)
    _POSITIONAL+=("$1")
    echo "!! Unknown parameter [$_key]"
    shift
    ;;
esac
done

set -- "${POSITIONAL[@]}"

if [ -z "$_PROFILE" ]; then
  echo ""
  echo "Profile has not been specified."
  echo ""
  echo -e $(usage)
  exit
fi

_k8sName=$(aws eks list-clusters --profile $_PROFILE --region us-east-1 | jq -r ".clusters[0]")

# do the mubectl thing
aws eks --region us-east-1 update-kubeconfig --name "$_k8sName" --profile $_PROFILE
echo''

# get k8s node name and store it
echo "Cluster name --> $_k8sName"
echo''

# print dashbaord token
_dashboardToken=$(kubectl get secret -n dashboard $(kubectl get sa/k8s-dashboard-admin --namespace dashboard -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}")
echo "Dashboard token --> $_dashboardToken"
echo''

#print jenkins password
_jenkinsPw=$(kubectl get secret --namespace jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode)
echo "Jenkins PW --> $_jenkinsPw"
echo''

# #print load balancer url
# _lbUrl=$(aws elb describe-load-balancers --profile $_PROFILE --region us-east-1 | jq ".LoadBalancerDescriptions[0].DNSName" | xargs)
# echo "Ingress IP address --> $_lbUrl"
# echo''

# #print nslookup for load balancer
# _lbIp=$(nslookup $_lbUrl)
# echo "IP address for ingress load balancer"
# echo''
# echo "$_lbIp"