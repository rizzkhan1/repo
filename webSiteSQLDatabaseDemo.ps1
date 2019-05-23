<# 
    Define variables below for resource group name, location etc...
    Replace the path to TemplateFile and TeplateParametersFile to where the json files will be located.
    Remove the remark from the select subscription if needed to work on the context of a subscription.
    In the event of not having a key vault, remove the reference of the key vault from the parameters file, 
    when the script is run, password for the sql login will be prompted.
#>

Param(
    [string] $ResourceGroupLocation = 'uksouth',
    [string] $ResourceGroupName = 'webSiteSQLDatabase-rg',
    [string] $TemplateFile = '.\webSiteSQLDatabase.json',
    [string] $TemplateParametersFile = '.\webSiteSQLDatabase.parameters.json',
    [string] $resourceDeployment = ((Get-ChildItem $TemplateFile).BaseName + '-' + ((Get-Date).ToUniversalTime()).ToString('dd-MM-yyyy')),
    [switch] $ValidateOnly
)

$ErrorActionPreference = 'Stop'

# Login to Azure
#Login-AzureRmAccount

# Select a Subscription to work with on this context of PowerShell.
#Select-AzureRmSubscription -SubscriptionId #input here the subscriptionID

# Create resource group if it doesn't already exist
if ((Get-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Verbose -ErrorAction SilentlyContinue) -eq $null) {
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Verbose -Force -ErrorAction Stop
}

if ($ValidateOnly) {
    $ErrorMessages = Format-ValidationOutput (Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
                                                                                  -TemplateFile $TemplateFile `
                                                                                  -TemplateParameterFile $TemplateParametersFile `
                                                                                  @OptionalParameters)
    if ($ErrorMessages) {
        Write-Output '', 'Validation returned the following errors:', @($ErrorMessages), '', 'Template is invalid.'
    }
    else {
        Write-Output '', 'Template is valid.'
    }
}
else {

    # Deploy resources to Azure
    New-AzureRmResourceGroupDeployment -Name $resourceDeployment `
                                           -ResourceGroupName $ResourceGroupName `
                                           -TemplateFile $TemplateFile `
                                           -TemplateParameterFile $TemplateParametersFile `
                                           -Verbose `
                                           -Force `
			                               -ErrorVariable ErrorMessages
      if ($ErrorMessages) {
        Write-Output '', 'Template deployment returned the following errors:', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") })
    }
}                                  

