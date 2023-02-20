#!/bin/sh
echo "hello"
ls
folder=$1
action=$2
echo $folder
echo $action
cd $folder
terraform init
if [ $action=plan ]
then
    terraform $action
else
   terraform $action -auto-approve
fi