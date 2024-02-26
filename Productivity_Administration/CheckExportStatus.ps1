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

function Get-AppCenterAppsByOrg
{
    param ([string] $ApiUserToken,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]    
        [string]$OrgName)    

    #https://openapi.appcenter.ms/#/account/apps_listForOrg
    $Uri = "https://api.appcenter.ms/v0.1/orgs/$OrgName/apps"

    $results = curl.exe -X GET $Uri -H 'Content-Type: application/json' -H 'accept: application/json' -H "X-API-Token: $ApiUserToken" | ConvertFrom-Json

    if ($results.psobject.properties.match('statusCode').Count)
    {
        Write-Host "Error: $results"
    }
    
    return $results
}

#Protecting API token - Get your own
$appCenterApi = ""

#https://openapi.appcenter.ms/#/account/apps_listForOrg
$allOrgApps = Get-AppCenterAppsByOrg -ApiUserToken $appCenterApi -OrgName 'examples'
$exportDetails = $allOrgApps | % { export_configurations -owner_name $_.owner.name -app_name $_.name }
$exportDetails | ? { $_.values | select -Property export_configurations }
