#!/bin/sh
echo "hello"
ls
folder=$1
action=$2
env=$3
echo $folder
echo $action
cd $folder
terraform init
if [ $action == plan ]
then
    terraform $action -var-file="$env/terraform.tfvars"
else
   terraform $action -auto-approve -var-file="$env/terraform.tfvars"
fi