dir
$folder=$args[0]
$action=$args[1]
write-host $folder
write-host $action
cd $folder
terraform init
 if $action==plan (
    terraform $action
 ) else (
    terraform $action -auto-approve
 )