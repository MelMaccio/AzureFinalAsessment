param (
    [Parameter(Mandatory)]$CreateOrDestroy,
    $rgName,
    $location ,
    $vnName,
    $snetName,
    $saName,
    $kvName
)

connect-AzAccount

$global:existingRG = Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -eq $rgName} 

function CustomLog ($message) {

    $date = Get-Date

    "$date | $message" | Out-File 'C:\temp\mylog.txt' -Append

    Write-Output "$message"

}

function Manage-ResourceGroup {
    param(
        $createordestroy,
        $rgName,
        $location = "eastus"
    )
    if ($createordestroy -eq "create") {
        CustomLog("Creating Resource Group...")
        try {
            $global:existingRG = New-AzSubscriptionDeployment -rgName $rgName -Location $location -TemplateFile ".\RGdeployment.json"
            if ($existingRG) {
                CustomLog("Resource Group created successfully. ID: ")
                CustomLog($existingRG.Id)                
            }
        }
        catch {
            Throw "Deployment failed: $_"
        }
    }else {
        Remove-AzResourceGroup -Name $rgName 
    }
}

function Manage-VirtualNetwork {
    param (
        $createordestroy,
        $vnName = "vnet_test",
        $snetName = "snet_test"
    )

    if($createordestroy -eq "create"){

        CustomLog("Creating Virtual Network...")
       try {
         $deploymentVN = New-AzResourceGroupDeployment -ResourceGroupName $existingRG.ResourceGroupName -vnName $vnName -snetName $snetName -TemplateFile ".\VNDeployment.json"
         $resourceId = (Get-AzVirtualNetwork -ResourceGroupName $existingRG.ResourceGroupName -Name $vnName).Id

         if($resourceId){
             CustomLog("Virtual Network Created Succesfully. ID: ")
             CustomLog($resourceId)
         }
       }
       catch {

            throw "Deployment failed: $_"

       }

    }else{
        Remove-AzVirtualNetwork -Name $vnName -ResourceGroupName $existingRG.ResourceGroupName
    }
    
}

function Manage-StorageAccount {
    param (
        $createordestroy,
        $saName,
        $location = "eastus",
        $existingRG
    )

   if($createordestroy -eq "create"){

    CustomLog("Creating Storage Account...")
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

function Manage-KeyVault {
    param(
     $createordestroy,
     $kvName,
     $location,
     $existingRG
    )
    if($createordestroy -eq "create") {

        CustomLog("Creating Key Vault...")
     try {
         New-AzResourceGroupDeployment -ResourceGroupName $existingRG.ResourceGroupName -location $location -kvName $kvName  -TemplateFile ".\KVDeployment.json"
         $deploymentKV = (Get-AzKeyVault -VaultName $kvName).ResourceId
         if($deploymentKV){
             CustomLog("Key Vault created successfully. ID: ")
             CustomLog($deploymentKV)
         }
     }
     catch {
         Throw "Deployment failed: $_"
     }
    } else {
        Remove-AzKeyVault -VaultName $kvName  -ResourceGroupName $existingRG.ResourceGroupName -PassThru
    }
}

#MainScript

 if($CreateOrDestroy -eq "create"){

    $vnName = "vneestasdsa"
    $snetName = "snetasdstsda"
    $saName = "safacotsda"
    $rgName = "rgtesst1" 
    $kvName = "kvfafteasssand"
    $location = "eastus"

    $global:existingRG = Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -eq $rgName} 

    if ($existingRG -eq $null) {
        Manage-ResourceGroup -createordestroy $CreateOrDestroy -rgName $rgName -location $location
        $global:existingRG = Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -eq $rgName} 

    }
    
    Start-Sleep -Seconds 20
    Manage-KeyVault -createordestroy $CreateOrDestroy -kvName $kvName -location $location -existingRG $existingRG
    Manage-StorageAccount -createordestroy $CreateOrDestroy -saName $saName -existingRG $existingRG
    Manage-VirtualNetwork -createordestroy $CreateOrDestroy -vnName $vnName -snetName $snetName -existingRG $existingRG

} 
    if($CreateOrDestroy -eq "destroy") {

        $vnName = "vneestasdsa"
        $snetName = "snetasdstsda"
        $saName = "safacotsda"
        $rgName = "rgtesst1" 
        $kvName = "kvfafteasssand"
        $location = "eastus"
    
        $global:existingRG = Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -eq $rgName} 
        Manage-ResourceGroup -createordestroy $CreateOrDestroy -rgName $rgName -location $location -force

}
else
{
    throw "Invalid value"
}



