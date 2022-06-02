Clear-Host

#Summary: Useful script to build a collection of all your Org/App connections
# Use this to make changes to all or portions of several Apps. Might be considered a base template for greater automation work

#Global Variable Section
$appCenterApi = $env:appcenterapi #Protecting API token - Get your own
$OrgAppList = New-Object 'Collections.Generic.List[string]' #Variable storing Orgs and Apps list
[bool]$CacheResults = $true #Save Results to local file to avoid expensive lookups
$cacheFileName = 'OrgAppList.log' #CacheFile name
$cacheFolder = (Get-Location).Path #CacheFile localation
$cacheFile = Join-Path -Path $cacheFolder -ChildPath $cacheFileName #Complete CacheFilePath

function BuildOrgAppList
{
    param ([string]$api = $appCenterApi)

    $Uri = "https://api.appcenter.ms/v0.1/orgs"
    $OrgAppList = New-Object 'Collections.Generic.List[string]'
    [bool]$bContinue =  $true

    $results = curl -X GET $Uri -H "Content-Type: application/json" -H "accept: application/json" -H "X-API-Token: $api" | ConvertFrom-Json

    if ($results.Length -eq 0)
    {
        return "Failed to get results."
        $bContinue =  $false
    }
    
    if ($bContinue)
    {
        if (Test-Path -Path $cacheFile)
        {
            Remove-Item -Path $cacheFile
            foreach ($Org in $results)
            {        
                $Apps = Get-AppList -OrgName $Org.Name
                foreach ($App in $Apps)
                {   
                    $msg = $Org.Name + "/" +$App.Name
                    $OrgAppList.Add($msg)
                    write-host "Added $msg" -ForegroundColor Green
                }
            }
        }

        if ($CacheResults)
        {
            $OrgAppList | Out-File -FilePath $cacheFile
        }
    }

    return $results

}

function Get-AppList
{
    param ([string]$api = $appCenterApi,
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
        if (Test-Path $cacheFile)
        {
            $OrgAppList = Get-Content -Path $cacheFile
            return $OrgAppList
        }
    }
    else
    {
        BuildOrgAppList
    }

    return $OrgAppList
}

ListOrgAndApps #Lists all your Org and App connections to the API used in the global variable section

