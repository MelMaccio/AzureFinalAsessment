#params

param(

    [Parameter(Mandatory)]$rgName,
    [Parameter(Mandatory)]$location,
    [Parameter(Mandatory)]$vnName,
    [Parameter(Mandatory)]$snetName,
    [Parameter(Mandatory)]$saName,
    [Parameter(Mandatory)]$kvName

)

#Log Function (create folder)

New-Item -Path 'c:\temp' -ItemType Directory -force | Out-Null

function CustomLog ($message) {

    $date = Get-Date

    Write-Verbose "$date | $message" -Verbose

    "$date | $message" | Out-File 'C:\temp\mylog.txt' -Append

    Write-Output "#################"

    Write-Output "$message"

    Write-Output "#################"

}

#Connect to Az Account

try {
    
    connect-AzAccount
    
}
    catch {
        
    Throw "Azure Auth failed: $_"
}


#Find existingRG or create new

$existingRG = Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -eq $rgName}

if(!$existingRG){

    CustomLog("Getting Resourcegroup details")

    try {

        New-AzSubscriptionDeployment -name $rgName -Location $location -TemplateFile ".\RGdeployment.json"
        
        if($existingRG){
           CustomLog("Resourcegroup created succesfully")
        }

    }

    catch {

         Throw "Deployment failed: $_"

    }
}

#Virtual Network Deployment

if($existingRG){

    CustomLog("Creating Virtual Network")

    try {
        New-AzResourceGroupDeployment -ResourceGroupName $existingRG.ResourceGroupName -vnName $vnName -snetName $snetName -TemplateFile ".\VNDeployment.json"

        $newVN = Get-AzVirtualNetwork -Name $vnName -ResourceGroupName $existingRG.ResourceGroupName

        if($newVN){
            CustomLog("Virtual Network created succesfully")
        }

    }
    catch {
        Throw "Deployment failed: $_"
    }
}

# Storage Account Deployment


if($existingRG){

    CustomLog("Getting StorageAccount details")

    try {

        #New-AzResourceGroup -Name $rgName -Location $location

        New-AzResourceGroupDeployment -ResourceGroupName $existingRG.ResourceGroupName -location $location -storageAccountName $saName  -TemplateFile ".\StorageAccount.json"

        $newSA = Get-AzStorageAccount -ResourceGroupName $existingRG.ResourceGroupName -Name $saName

        if($newSA){
            CustomLog("Storage account created succesfully")
        }

    }

    catch {

         Throw "Deployment failed: $_"

    }
}

#Find a Key Vault or create a new one

$existingKV = Get-AzKeyVault | Where-Object {$_.Name -eq $kvName}

if(!$existingKV){

    CustomLog("Getting KeyVault details")

    try{

        New-AzResourceGroupDeployment -ResourceGroupName $existingRG.ResourceGroupName -location $location -kvName $kvName  -TemplateFile ".\KVDeployment.json"

        CustomLog("KeyVault created succesfully")
    }
   
    catch{

        Throw "Deployment failed: $_"

    }
}
