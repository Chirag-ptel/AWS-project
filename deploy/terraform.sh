#!/bin/sh
echo "hello"
ls
folder=$1
action=$2
echo $folder
echo $action
cd $folder
terraform init
 if $action==plan (
    terraform $action
 ) else (
    terraform $action -auto-approve
 )