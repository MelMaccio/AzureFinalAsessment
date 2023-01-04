param (
    [Parameter(Mandatory)]$CreateOrDestroy,
    $rgName,
    $location,
    $vnName,
    $snetName,
    $saName
)

connect-AzAccount

$existingRG= Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -eq $rgName} 
Write-Output "Imprimiendo variables"
$existingRG

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
        $existingRG,
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
        $existingRG,
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
        $location = "eastus"
    )
    if ($createordestroy -eq "create") {
        CustomLog("Getting Resource Group details")
        try {
            $deploymentRG = New-AzSubscriptionDeployment -rgName $rgName -Location $location -TemplateFile ".\RGdeployment.json"
            if ($deploymentRG) {
                CustomLog("Resource Group created successfully. ID: ")
                CustomLog($deploymentRG.Id)
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
    $existingRG,
    $location
   )

   if($createordestroy -eq "create") {
    try {
        New-AzResourceGroupDeployment -ResourceGroupName $existingRG.ResourceGroupName -location $location -VaultName $kvName  -TemplateFile ".\KVDeployment.json"
        $deploymentKV = Get-AzKeyVault -VaultName $kvName
        if($deploymentKV){
            CustomLog("Key Vault created successfully. ID: ")
            CustomLog($deploymentKV.Id)
        }
    }
    catch {
        Throw "Deployment failed: $_"
    }
    
   } else {
    Remove-AzKeyVault -VaultName $kvName  -ResourceGroupName $existingRG -PassThru
   }
   
}

#Validaciones: naming convention, parametros, etc

#Logica ppal o MainScript

# if($CreateOrDestroy -eq "create"){
#     #creacion de recursos en cascada

# }elseif ($CreateOrDestroy -eq "destroy") {
#     #destruccion de recursos

# }else{
#     throw "Valor no permitido"
#     Write-Verbose "Valor no permitido"
# }

# $vnName = "vnet_test"
# $snetName = "snet_test"

# $saName = "melinasa123"

# Manage-VirtualNetwork -createordestroy $CreateOrDestroy -existingRG $existingRG -vnName $vnName -snetName $snetName

# Manage-StorageAccount -createordestroy $CreateOrDestroy -existingRG $existingRG -saName

# $rgName = "teodiorg"

# Manage-ResourceGroup -createordestroy $CreateOrDestroy -rgName $rgName -Location $location

