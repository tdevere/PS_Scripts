Clear-Host

#Protecting API token - Get your own
$appCenterApi = $env:appcenterapi

#https://openapi.appcenter.ms/#/export/ExportConfigurations_List
#List export configurations.

$owner_name = "" #Replace with your Org/Owner Name
$app_name = "" #Replace with your App Name

$EnableAppInsightsIfDisabled = $true
$EnableBlobStorageIfDisabled = $true
$ExportWasDisabled = $false #place holder for the script do not change

function CoreFunctionByUri
{
    param (
        [string]
        $URI,
        [string]
        $Method        

    )

    #All the changes for these calls is the URI
    curl.exe -X $Method $URI -H  "accept: application/json" -H  "X-API-Token: $appCenterApi" | ConvertFrom-Json
}

function export_configurations
{
    param (
        [string] $owner_name,    
        [string] $app_name )

        $uri = 'https://api.appcenter.ms/v0.1/apps/' + $owner_name + '/' + $app_name + '/export_configurations'

        CoreFunctionByUri -URI $uri -Method "GET"
}

function enable_export_configurations
{
    param (
        [string] $owner_name,    
        [string] $app_name,
        [string] $export_configuration_id)
        
        $uri = 'https://api.appcenter.ms/v0.1/apps/' + $owner_name + '/' + $app_name + '/export_configurations/' + $export_configuration_id + '/enable'

        CoreFunctionByUri -URI $uri -Method "POST"
}

#Get Export Config
$export_configs = export_configurations -owner_name $owner_name -app_name $app_name 

#Determine if it any part was disabled

if ("Disabled" -match ($export_configs.values.state | Select-String -SimpleMatch Disabled))
{
    Write-Host "Export was disabled"
    $ExportWasDisabled = $true
} 

#if it any part was disabled, enable if you choose

if ($ExportWasDisabled)
{
    #enable_export_configurations
    #https://openapi.appcenter.ms/#/export/ExportConfigurations_Enable

    foreach ($export in $export_configs.values)
    {
        if ($export.export_type -eq 'AppInsights')
        {
            if ($EnableAppInsightsIfDisabled)
            {
                if ($export.state -eq "Disabled")
                {
                    enable_export_configurations -owner_name $owner_name -app_name $app_name -export_configuration_id $export.id
                    Write-Host "AppInsights Export was enabled"
                }
                
            }
        }

        if ($export.export_type -eq 'BlobStorage')
        {
            if ($EnableAppInsightsIfDisabled)
            {
                if ($export.state -eq "Disabled")
                {
                    enable_export_configurations -owner_name $owner_name -app_name $app_name -export_configuration_id $export.id
                    Write-Host "BlobStorage Export was enabled"
                }                
            }
        }
    }
}



