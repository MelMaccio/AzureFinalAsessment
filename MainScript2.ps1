param (
    [Parameter(Mandatory)]$CreateOrDestroy,
    $rgName,
    $location,
    $vnName,
    $snetName,
    $saName,
    $kvName
)




# $CreateOrDestroy = Read-Host -Prompt "What do you want to do? Create Or Destroy: "

connect-AzAccount

$global:existingRG = Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -eq $rgName} 

Write-Output "Imprimiendo variables"

#Write-Output $existingRG.name

#Funciones: para crear o destruir un recurso, loggeo, loggeoResourceID

function CustomLog ($message) {

    $date = Get-Date

    # Write-Verbose "$date | $message" -Verbose

    "$date | $message" | Out-File 'C:\temp\mylog.txt' -Append

    Write-Output "#################"

    Write-Output "$message"

    Write-Output "#################"

}
function Manage-VirtualNetwork {
    param (
        $createordestroy,
        $vnName = "vnet_test",
        $snetName = "snet_test"
    )

    if($createordestroy -eq "create"){
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
        $location = "eastus"
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

function Manage-ResourceGroup {
    param(
        $createordestroy,
        $rgName,
        $location
    )
    if ($createordestroy -eq "create") {
        CustomLog("Getting Resource Group details")
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

function Manage-KeyVault {
    param(
     $createordestroy,
     $kvName,
     $location
    )
    if($createordestroy -eq "create") {
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




#Validaciones: naming convention, parametros, etc

#Logica ppal o MainScript

 if($CreateOrDestroy -eq "create"){

    $vnName = "vnet_test"
    $snetName = "snet_test"
    $saName = "melinasa123"
    $rgName = "teodiorg" 
    $kvName = "kvfacundoagrafa"
    
    #If null create RG
    if ($existingRG -eq $null) {
        Manage-ResourceGroup -createordestroy $CreateOrDestroy -rgName $rgName -Location $location
    }
    
    Manage-KeyVault -createordestroy $CreateOrDestroy -kvName $kvName -location $location
    Manage-StorageAccount -createordestroy $CreateOrDestroy -saName $saName
    Manage-VirtualNetwork -createordestroy $CreateOrDestroy -vnName $vnName -snetName $snetName

}elseif ($CreateOrDestroy -eq "destroy") {
        
    Manage-ResourceGroup -createordestroy $CreateOrDestroy -rgName $rgName -Location $location
    Manage-KeyVault -createordestroy $CreateOrDestroy -kvName $kvName -location $location
    Manage-StorageAccount -createordestroy $CreateOrDestroy -saName $saName
    Manage-VirtualNetwork -createordestroy $CreateOrDestroy -vnName $vnName -snetName $snetName

}else{
    throw "Valor no permitido"
    Write-Verbose "Valor no permitido"
}



