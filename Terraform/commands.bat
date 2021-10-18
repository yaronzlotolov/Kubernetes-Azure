rem *** Login to Azure ***
az login

rem *** List the subscriptions ***
az account list -o table

rem *** Store the subsciprion in a variable ***
$SUBSCRIPTION="<SubscriptionId>"
echo $SUBSCRIPTION

rem *** create service principal and store values in variables for terraform***
$SERVICE_PRINCIPAL_JSON=(az ad sp create-for-rbac --skip-assignment --name terraform-sp -o json)
echo $SERVICE_PRINCIPAL_JSON
$SERVICE_PRINCIPAL=(echo $SERVICE_PRINCIPAL_JSON | jq -r '.appId')
echo $SERVICE_PRINCIPAL
$SERVICE_PRINCIPAL_SECRET=(echo $SERVICE_PRINCIPAL_JSON | jq -r '.password')
echo $SERVICE_PRINCIPAL_SECRET
$TENANT_ID=(echo $SERVICE_PRINCIPAL_JSON | jq -r '.tenant')
echo $TENANT_ID

rem *** Add Contributor role to the subsciprion ***
az role assignment create --assignee $SERVICE_PRINCIPAL --scope "/subscriptions/$SUBSCRIPTION" --role Contributor
az role assignment list --assignee $SERVICE_PRINCIPAL

rem *** Create ssh key and save it to variable ***
ssh-keygen -t rsa -b 4096 -N "VeryStrongSecret123!" -C "yaron.zlotolov@gmail.com" -q -f .\ssh\id_rsa
$SSH_KEY=cat C:\Kubernetes\Kubernetes-Azure\ssh\id_rsa.pub
echo $SSH_KEY

rem *** chaeck the aks version supported in westus region and update variables.tf in main and cluster module***
az aks get-versions --location westus --output table

rem *** Run terraform ***
cd .\Terraform\
terraform init
terraform plan -var serviceprinciple_id=$SERVICE_PRINCIPAL -var serviceprinciple_key="$SERVICE_PRINCIPAL_SECRET" -var tenant_id=$TENANT_ID -var subscription_id=$SUBSCRIPTION -var ssh_key=$SSH_KEY -out=C:\Kubernetes\Kubernetes-Azure\Terraform\plan
terraform apply C:\Kubernetes\Kubernetes-Azure\Terraform\plan

az aks get-credentials --resource-group aks-demo-rg --name aks-demo
kubectl get nodes

terraform destroy -var serviceprinciple_id=$SERVICE_PRINCIPAL -var serviceprinciple_key="$SERVICE_PRINCIPAL_SECRET" -var tenant_id=$TENANT_ID -var subscription_id=$SUBSCRIPTION -var ssh_key=$SSH_KEY

Done with IaaS! 
Next Step go to deployemt folder to deploy net core app with mssql - commands in deploy.bat