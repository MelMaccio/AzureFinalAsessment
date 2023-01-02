#params

param(

    [Parameter(Mandatory)]$rgName,
    [Parameter(Mandatory)]$location,
    [Parameter(Mandatory)]$AZURE_USER,
    [Parameter(Mandatory)]$AZURE_SECRET,
    [Parameter(Mandatory)]$AZURE_TENANT,
    [Parameter(Mandatory)]$AZURE_SUBSCRIPTIONS
)

# [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

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
    
    $sec = $AZURE_SECRET | ConvertTo-SecureString -AsPlainText -Force
   $credential = New-Object System.Management.Automation.PSCredential ($AZURE_USER, $sec)
   $conn = connect-AzAccount -Credential $credential -TenantId $AZURE_TENANT
   Set-azcontext -Subscriptionid $AZURE_SUBSCRIPTIONS
}
    catch {
        
    Throw "Azure Auth failed: $_"
}


#Find existingRG or create new

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