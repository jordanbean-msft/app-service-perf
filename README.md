# app-service-perf

## Useful scripts

### Pre
terraform apply -var-file="$HOME/secure.tfvars" -var-file="../env/central.tfvars" -var-file="../env/global.tfvars"

### Init
terraform apply -var-file="$HOME/secure.tfvars" -var-file="../env/dev.tfvars" -var-file="../env/global.tfvars" -var="CENTRALRESOURCEGROUPNAME=rg-appServicePerf-USSC-central" -var="CENTRALVIRTUALNETWORKNAME=vNet-central" -var="CENTRALADOAGENTADDRESSPREFIX=10.0.1.0/24"

### WebApp
terraform apply -var-file="$HOME/secure.tfvars" -var-file="../env/dev.tfvars" -var-file="../env/global.tfvars" -var="KEYVAULTNAME=kvappServicePerfUSSCDEV" -var="RESOURCEGROUPNAME=rg-appServicePerf-USSC-DEV" -var="VNETNAME=vnet-appServicePerf-USSC-DEV" -var="APPSERVICESUBNETNAME=appServiceSubnet"

### Import/Rm
terraform import -var-file="$HOME/secure.tfvars" -var-file="../env/dev.tfvars" -var-file="../env/global.tfvars" module.init.azurerm_subnet.appServiceSubnet /subscriptions/dcf66641-6312-4ee1-b296-723bb0a999ba/resourceGroups/rg-appServicePerf-USSC-prod/providers/Microsoft.Network/virtualNetworks/vnet-appServicePerf-USSC-dev/subnets/appServiceSubnet

terraform state rm module.init.azurerm_resource_group.resourceGroup