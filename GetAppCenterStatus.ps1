Clear-Host

[bool]$global:FirstRun = $false
$global:AllApiStatusList

#May do this later
#Backup Your Results?
#[bool]$enableLocalCache = $true

#https://status.appcenter.ms/api

function ApiStatusCall
{
    param (
        [Parameter(Mandatory)]
        [string] $apiLink)

    $results = curl -X GET $apiLink -H "Content-Type: application/json" -H "accept: application/json" | ConvertFrom-Json
    return $results
}

function AppCenterApiStatusLinks
{      
    return New-Object -TypeName PSObject -Property @{     
        'summaryApi' = 'https://status.appcenter.ms/api/v2/summary.json'
        'statusApi' = "https://status.appcenter.ms/api/v2/status.json"
        'componentsApi' = "https://status.appcenter.ms/api/v2/components.json"
        'unresolvedIncidentsApi' = "https://status.appcenter.ms/api/v2/incidents/unresolved.json"
        'allIncidents' = "https://status.appcenter.ms/api/v2/incidents.json"
        'upcomingScheduledMaintenances' = "https://status.appcenter.ms/api/v2/scheduled-maintenances/upcoming.json"
        'activeScheduledMaintenances' = "https://status.appcenter.ms/api/v2/scheduled-maintenances/active.json"
        'allScheduledMaintenances' = "https://status.appcenter.ms/api/v2/scheduled-maintenances.json"
    }
}

function PopulateCurrentApiStatus
{
    #Create Api Reference Object
    $global:apiObj = AppCenterApiStatusLinks

    $ApiStatus = New-Object -TypeName PSObject -Property @{
        'ThisReportWasCreatedOn' = (Get-Date)     
        'summaryApi' = (ApiStatusCall -apiLink $global:apiObj.summaryApi)
        'statusApi' = (ApiStatusCall -apiLink $global:apiObj.statusApi)
        'componentsApi' = (ApiStatusCall -apiLink $global:apiObj.componentsApi)
        'unresolvedIncidentsApi' = (ApiStatusCall -apiLink $global:apiObj.unresolvedIncidentsApi)
        'allIncidents' = (ApiStatusCall -apiLink $global:apiObj.allIncidents)
        'upcomingScheduledMaintenances' = (ApiStatusCall -apiLink $global:apiObj.upcomingScheduledMaintenances)
        'activeScheduledMaintenances' = (ApiStatusCall -apiLink $global:apiObj.activeScheduledMaintenances)
        'allScheduledMaintenances' = (ApiStatusCall -apiLink $global:apiObj.allScheduledMaintenances)
    }

    if ($enableLocalCache)
    {
        #Saving this history can help you connect issues to service outages. Consider adding to your build best practices
        # $cacheFileName = 'AppCenterStatusApi_' + (Get-Date).Ticks + '.log' #CacheFile name
        # $cacheFolder = (Get-Location).Path #CacheFile localation
        # $cacheFile = Join-Path -Path $cacheFolder -ChildPath $cacheFileName #Complete CacheFilePath        
        # $obj | Out-File -FilePath $cacheFileName
        # write-host "Saved Results"
    }

    return $ApiStatus 
}

function Setup
{
    param([bool]$override = $FirstRun)

    if ($override)
    {
        $global:AllApiStatusList = PopulateCurrentApiStatus
    }
    elseif ($null -eq $global:AllApiStatusList) 
    {
        $global:AllApiStatusList = PopulateCurrentApiStatus
    }

    return $global:AllApiStatusList
}

#Start up by running setup. Then make sure to remove the override or start using $false
Setup #-override $true
write-host "This report was collected on " $global:AllApiStatusList.ThisReportWasCreatedOn -ForegroundColor Green
$global:AllApiStatusList.allIncidents.incidents | Select-Object -Property Name | Group-Object -Property Name,resolved_at -NoElement | Sort-Object -Property Count -Descending | Format-Table -AutoSize
