#!/bin/bash

account_id=$(aws sts get-caller-identity --query "Account" --output text)
cluster_name='eks-stack'
region_code='us-east-1'

certificate_data=$(aws eks describe-cluster \
    --region us-east-1 \
    --name eks-stack \
    --query "cluster.certificateAuthority.data" \
    --output text)

echo "Certificate data" + $certificate_data

echo "------------------------------------------\n"

cluster_endpoint=$(aws eks describe-cluster \
    --region us-east-1 \
    --name eks-stack \
    --query "cluster.endpoint" \
    --output text)

echo "Cluster endpoint" + $cluster_endpoint


echo "------------------------------------------\n"

echo "Full config file"

echo -e "apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $certificate_data
    server: $cluster_endpoint
  name: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
contexts:
- context:
    cluster: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
    user: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
  name: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
current-context: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
kind: Config
preferences: {}
users:
- name: arn:aws:eks:$region_code:$account_id:cluster/$cluster_name
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws
      args:
        - --region
        - $region_code
        - eks
        - get-token
        - --cluster-name
        - $cluster_name
        command: aws
"

#echo $kube_config