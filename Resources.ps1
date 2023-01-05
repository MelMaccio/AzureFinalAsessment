function Manage-StorageAccount {
    param (
        $createordestroy,
        $saName,
        $location = "eastus",
        $existingRG
    )
   if($createordestroy -eq "create"){
      try {
        $deploymentSA = New-AzResourceGroupDeployment -ResourceGroupName $existingRG.ResourceGroupName -location $location -storageAccountName $saName  -TemplateFile ".\SADeployment.json"
        $resourceId = (Get-AzStorageAccount -ResourceGroupName $existingRG.ResourceGroupName -Name $saName).Id
        if($resourceId){
            CustomLog("Storage account created succesfully. ID: ")
            CustomLog($resourceId)
        }
      }
      catch {
        throw "Deployment failed: $_"
      }
   }else {
    Remove-AzStorageAccount -ResourceGroupName $existingRG.ResourceGroupName -Name $saName
   }
    
}


Function Manage-NetworkSecurityGroup {
    param(
        $createordestroy,
        $nsgName,
        $location = "eastus",
        $existingRG
    )
    if($createordestroy -eq "create"){
        try {
            $deploymentNSG = New-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $existingRG.ResourceGroupName -location $location

        }
        catch {
            {1:<#Do this if a terminating exception happens#>}
        }
    }
}