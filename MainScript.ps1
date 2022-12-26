#params
param(
    [Parameter(Mandatory)]$rgName,
    [Parameter(Mandatory)]$location
)

#Log Function
function CustomLog ($message) {
    $date = Get-Date
    Write-Verbose "$date | $message" -Verbose
    "$date | $message" | Out-File 'C:\temp\mylog.txt' -Append
    Write-Output "#################"
    Write-Output "$message"
    Write-Output "#################"
    
}

#Connect to Az Account
Connect-AzAccount -Subscription "Visual Studio Professional Subscription"

#Buscar el Resource Group
$existingRG = Get-AzResourceGroup | Where-Object {$_.ResourceGroupName -eq $rgName}

if(!$existingRG){
    CustomLog("Getting Resourcegroup details")

    try { 

        New-AzResourceGroup -Name $rgName -Location $location
        CustomLog("Resourcegroup created succesfully") 

    }
    catch {

        Throw "Deployment failed: $_"

    }
    
}