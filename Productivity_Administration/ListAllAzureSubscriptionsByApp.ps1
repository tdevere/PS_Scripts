#{{baseUrl}}/v0.1/apps/:owner_name/:app_name/azure_subscriptionsOrgAppListrgAppListFilter 
Clear-Host

#Summary: Useful script to build a collection of all your Org/App connections
# Use this to make changes to all or portions of several Apps. Might be considered a base template for greater automation work

function Setup
{
    #Global Variable Section
    $Global:appCenterApi = $env:appcenterapi #Protecting API token - Get your own
    $Global:OrgAppList = New-Object 'Collections.Generic.List[string]' #Variable storing Orgs and Apps list
    $Global:OrgAppListFilter = New-Object 'Collections.Generic.List[string]' #Use this to filter only specific Orgs/Apps
    $Global:AzureOrgAppList = New-Object 'Collections.Generic.Dictionary[string, Collections.Generic.List[string]]' #Variable containing list of All Azure Subscriptions
    [bool]$CacheResults = $true #Save Results to local file to avoid expensive lookups
    $Global:cacheFileName = 'OrgAppList.log' #CacheFile name
    $Global:cacheFolder = (Get-Location).Path #CacheFile localation
    $Global:cacheFile = Join-Path -Path $Global:cacheFolder -ChildPath $Global:cacheFileName #Complete CacheFilePath
    $Global:AzureOrgAppcacheFileName = 'AzureOrgAppList.log' #CacheFile name
    $Global:AzureOrgAppcacheFolder = (Get-Location).Path #CacheFile localation
    $Global:AzureOrgAppcacheFile = Join-Path -Path $Global:AzureOrgAppcacheFolder -ChildPath $Global:AzureOrgAppcacheFileName #Complete CacheFilePath
}

function BuildOrgAppList
{
    param ([string]$api = $Global:appCenterApi)

    $Uri = "https://api.appcenter.ms/v0.1/orgs"
    $Global:OrgAppList = New-Object 'Collections.Generic.List[string]'
    [bool]$bContinue =  $true

    $results = curl -X GET $Uri -H "Content-Type: application/json" -H "accept: application/json" -H "X-API-Token: $api" | ConvertFrom-Json

    if ($results.Length -eq 0)
    {
        return "Failed to get results."
        $bContinue =  $false
    }
    
    if ($bContinue)
    {
        if (Test-Path -Path $Global:cacheFile)
        {
            #Remove-Item -Path $Global:cacheFile

            foreach ($Org in $results)
            {        
                $Apps = Get-AppList -OrgName $Org.Name
                foreach ($App in $Apps)
                {
                    
                    if (FoundInGlobalFilter -filter $App.Name)
                    {
                        $msg = $Org.Name + "/" + $App.Name
                        $Global:OrgAppList.Add($msg)
                        write-host "Added $msg" -ForegroundColor Green
                    }
                }
            }
        }

        if ($CacheResults)
        {
            $Global:OrgAppList | Out-File -FilePath $Global:cacheFileName
        }
    }

    return $results

}

function Get-AppList
{
    param ([string]$api = $Global:appCenterApi,
    [Parameter(Mandatory)]
    [string]$OrgName)    

    $Uri = 'https://api.appcenter.ms/v0.1/apps?$orderBy=name'

    $results = curl -X GET $Uri -H "Content-Type: application/json" -H "accept: application/json" -H "X-API-Token: $api" | ConvertFrom-Json

    return $results
}

function ListOrgAndApps
{    
    param ([bool]$useCacheIfEnabled = $true)

    if ($useCacheIfEnabled)
    {
        if (Test-Path $Global:cacheFile)
        {
            $Global:OrgAppList = Get-Content -Path $Global:cacheFile
            return $Global:OrgAppList
        }
    }
    else
    {
        BuildOrgAppList
    }

    return $Global:OrgAppList
}

function BuildAzureSubscriptionList
{
    param ([string]$api = $Global:appCenterApi,
    [string]$owner_app)   

    $Uri = "https://api.appcenter.ms/v0.1/apps/$owner_app/azure_subscriptions"

    if ((FoundInGlobalFilter -filter $owner_app))
    {
        $results = curl -X GET $Uri -H "Content-Type: application/json" -H "accept: application/json" -H "X-API-Token: $api" | ConvertFrom-Json
        
        if ([string]::IsNullOrEmpty($results.statusCode))
        {
            $properties = @{subscription_id="$results.subscription_id"; subscription_name="$results.subscription_name"; tenant_id=$results.tenant_id; created_at=$results.created_at}
            $sb = New-Object 'System.Text.StringBuilder'
            $sb.Append("subscription_id" + $results.subscription_id + ";")
            $sb.Append("subscription_name" + $results.subscription_name + ";")
            $sb.Append("tenant_id" + $results.tenant_id + ";")
            $sb.Append("created_at" + $results.created_at)
            $Global:AzureOrgAppList.Add($owner_app.ToString(), $sb.ToString())            
            write-host "Added: $owner_app : $results"   
        }
    }
}

function ListAzureSubscriptionByOrgApp
{
    param ([bool]$useCacheIfEnabled = $true)

    $bContinue = $false
    if ($useCacheIfEnabled)
    {
        if (Test-Path $Global:AzureOrgAppcacheFile)
        {
            $Global:AzureOrgAppList = Get-Content -Path $Global:AzureOrgAppcacheFile
            return $Global:AzureOrgAppList 
        }

        $bContinue = $true #Path didn't exist, we'll need to build the content again

    }
    
    if ($bContinue)
    {
        ListOrgAndApps #Make sure this OrgAppList is ready

        foreach ($app in $Global:OrgAppList)
        {   
            BuildAzureSubscriptionList -owner_app $app
        }
    }

    return $Global:AzureOrgAppList 

}

function FoundInGlobalFilter
{
    param 
    (
        [Parameter(Mandatory)]
        [string]$filter
    )

    [bool]$Global:Found = $false

    Foreach ($item in $Global:OrgAppListFilter)
    { 
        if ($item -match $filter)
        {
            $Global:Found = $true
            break 
        }
    }

    return $Global:Found
}

function AddOrgAppFilter
{
    param 
    (
        [Parameter(Mandatory)]
        [string]$filter
    )

    write-host "Clearing Global:OrgAppListFiter"
    $Global:OrgAppListFilter.Clear()
    #Ignore everything else but this Org/App Filter
    if ($Global:OrgAppList.Count -eq 0)
    {
        ListOrgAndApps
    }

    foreach ($item in $Global:OrgAppList)
    {   
        if ($item -match $filter)
        {
            $Global:OrgAppListFilter.Add($item)
            write-host "Added Filter: $item"
            break
        }
    }
}



#General Instructions
Setup #Run once and any time you need to refresh global variables
AddOrgAppFilter -filter "Examples/Android_Xamarin" #Useful if you want to limit processing to only those found in the filter. #Use the AddOrgAppFilter to create a filter to avoid running your commands against all org/apps and restrict to only those found in this list
ListOrgAndApps #Lists all your Org and App connections to the API used in the global variable section
BuildAzureSubscriptionList # -api $Global:appCenterApi -owner_app "Examples/Android_Xamarin"
ListAzureSubscriptionByOrgApp