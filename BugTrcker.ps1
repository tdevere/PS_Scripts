Clear-Host
#Only Run Once per session to avoid duplicated calls
$runOncePerSession = $true #Set to true to initialize values; while working with script can change to false

#Protecting API token - Get your own
$appCenterApi = $env:appcenterapi

#Limit Results to these ORGs
$LimitOrg = $true #Set true to limit script to specific Orgs
$OrgLimitList = [System.Collections.ArrayList]@("Examples")

#Limit Results to these Apps
$LimitApps = $true #Set true to limit script to specific Apps
$AppLimitList = [System.Collections.ArrayList]@("Android_Xamarin", "AppCenter_WinForm", "ThreeAmigos_Android") 

#Location of All errorGroups
$CompleteErrorGroupsList = New-Object 'Collections.Generic.List[PSCustomObject]'
$CompleteErrorGroupIdsList = New-Object 'Collections.Generic.List[PSCustomObject]'
$FinalProduct = New-Object 'Collections.Generic.List[PSCustomObject]' #App;Org;ErrorIds


#List Of Orgs
#https://openapi.appcenter.ms/#/account/organizations_list
#Returns a list of organizations the requesting user has access to
if ($runOncePerSession)
{
    $OrgList = [System.Collections.ArrayList]::new()

    $CompleteOrgList = curl.exe -X GET "https://api.appcenter.ms/v0.1/orgs" -H  "accept: application/json" -H  "X-API-Token: $appCenterApi" | ConvertFrom-Json 
    
    if ($LimitOrg)
    {
        $OrgList.Add(($CompleteOrgList | Select-Object name | Where-Object {$OrgLimitList.Contains($_.name)}).name)        
    }
    else
    {
        $OrgList.AddRange(($CompleteOrgList | Select-Object name).name) 
    }

    $OrgList | Sort-Object
}

#Get List of Apps
#https://openapi.appcenter.ms/#/account/apps_listForOrg
#Returns a list of apps for the organization
if ($runOncePerSession)
{
    $AppList = [System.Collections.ArrayList]::new()        
    $FinalOrgAppList = [System.Collections.Specialized.StringCollection]::new()

    foreach ($org in $OrgList) 
    {
        Write-Host "Searching $org for Apps"
        $uri = 'https://api.appcenter.ms/v0.1/orgs/' + $org + '/apps'

        $CompleteAppList = curl.exe -X GET $uri -H "accept: application/json" -H "X-API-Token: $appCenterApi" | ConvertFrom-Json

        Write-Host "Found " $CompleteAppList.Count " Apps"
        if ($LimitApps)
        {
            Write-Host "Limiting App Selection"
            $TempAppList = ($CompleteAppList | Select-Object name) | Where-Object {$AppLimitList.Contains($_.name)} 
            if ($TempAppList.Count -eq 1)
            {
                $AppList.Add($TempAppList)
            }
            elseif ($TempAppList.Count -ge 1)
            {
                $AppList.AddRange($TempAppList)                
            }       
        }
        else
        {
            Write-Host "Searching for All Apps"
            $TempAppList = ($CompleteAppList | Select-Object name)

            if ($TempAppList.Count -eq 1)
            {
                $AppList.Add($TempAppList)
            }
            elseif ($TempAppList.Count -ge 1)
            {
                $AppList.AddRange($TempAppList)                
            } 
        }

        if ($AppList.Count -ge 0)
        {
            foreach ($app in $AppList)
            {             
                $app         
                $FinalOrgAppList.Add([string]::Format("{0}/{1}", $org, $app.name))
            }  
        }
        else
        {
            Write-Host "No Apps Found"
        }
                    
    }

    $FinalOrgAppList | Sort-Object #http friendly formatted list of the org/apps we want to focus on

}

function Get-ErrorGroups
{
    param
    (
        [Parameter(Mandatory)]
        [String]$OrgName,
        [Parameter(Mandatory)]
        [String]$AppName,
        [Parameter(Mandatory=$false)]
        [String]$StartDateTime= (Get-Date (Get-Date).ToUniversalTime().AddDays(-90) -UFormat '+%Y-%m-%dT%H:%M:%S.000Z').ToString(), #Start date time in data in ISO 8601 date time format
        [Parameter(Mandatory=$false)]
        [String]$Top='0', #The maximum number of results to return. (0 will fetch all results till the max number.)
        [Parameter(Mandatory=$false)]
        [String]$Token=$appCenterApi        
    )  

    #https://openapi.appcenter.ms/#/errors/Errors_GroupList
    #List of error groups  
    Write-Host "Checking for Error Groups for" $OrgName"/"$AppName
    $uri = [string]::Format('https://api.appcenter.ms/v0.1/apps/{0}/{1}/errors/errorGroups?start={2}&%24orderby=count%20desc&%24top={3}', $AppName, $OrgName, $StartDateTime, $Top)       
    $errGroups = curl.exe -X GET $uri -H  "accept: application/json" -H  "X-API-Token: $appCenterApi" | ConvertFrom-Json    
    if ($errGroups.errorGroups.Count -ne "0")
    {
        Write-Host "Results Found"
        $UpdatedDetails = New-Object 'Collections.Generic.List[PSCustomObject]'
        $UpdatedDetails += New-Object -TypeName psobject -Property @{OrgName=$OrgName; AppName=$AppName; errorGroups=$errGroups.errorGroups}        
        $CompleteErrorGroupsList.Add($UpdatedDetails)         
        
    }
}

function Get-All-ErrorGroups
{
    param
    (
        [Parameter(Mandatory=$false)]
        [String]$AppOrgList=$FinalOrgAppList     
    )  

    if ($FinalOrgAppList.Count -ge 0)
    {
        foreach ($app in $FinalOrgAppList)
        {
            $split = $app.ToString().Split("/")
            Get-ErrorGroups -AppName $split[0] -OrgName $split[1] -Token $appCenterApi
        }
    }
}

function Get-ErrorId
{
    param
    (
        [Parameter(Mandatory)]
        [String]$errorGroupId,
        [Parameter(Mandatory)]
        [String]$OrgName,
        [Parameter(Mandatory)]
        [String]$AppName,
        [Parameter(Mandatory=$false)]
        [String]$StartDateTime= (Get-Date (Get-Date).ToUniversalTime().AddDays(-90) -UFormat '+%Y-%m-%dT%H:%M:%S.000Z').ToString(), #Start date time in data in ISO 8601 date time format
        [Parameter(Mandatory=$false)]
        [String]$Top='0', #The maximum number of results to return. (0 will fetch all results till the max number.)
        [Parameter(Mandatory=$false)]
        [String]$Token=$appCenterApi        
    )  

    #https://openapi.appcenter.ms/#/errors/Errors_ListForGroup
    #Get all errors for group 
    Write-Host "Checking for Error Groups for" $OrgName"/"$AppName
    $uri = [string]::Format('https://api.appcenter.ms/v0.1/apps/{0}/{1}/errors/errorGroups/{2}/errors?start={3}&%24top={4}', $AppName, $OrgName, $errorGroupId, $StartDateTime, $Top)        
    [PSCustomObject]$errIdGroup = curl.exe -X GET $uri -H  "accept: application/json" -H  "X-API-Token: $appCenterApi" | ConvertFrom-Json

    if ($errIdGroup.Count -ne "0")
    {
        Write-Host "Results Found"
        $UpdatedDetails = New-Object 'Collections.Generic.List[PSCustomObject]'
        foreach ($item in $errIdGroup.errors)
        {   
            $UpdatedDetails += New-Object -TypeName psobject -Property @{OrgName=$OrgName; AppName=$AppName; ErrorGroupId=$errorGroupId; ErrorIDs=$item.errorId}              
            #$CompleteErrorGroupIdsList.Add($item.errorId)            
        }

        #add the complete list to $CompleteErrorGroupsList            
        $CompleteErrorGroupIdsList.Add($UpdatedDetails)                  
        #$CompleteErrorGroupIdsList | Format-Table -Wrap
    }
}
function Get-All-ErrorIds
{
    param
    (
        [Parameter(Mandatory=$false)]
        [PSCustomObject]$errorGroupIdList=[PSCustomObject]$CompleteErrorGroupsList,
        [Parameter(Mandatory=$false)]
        [String]$Token=$appCenterApi    
    )

    if ($errorGroupIdList.Count -ne "0")
    {
        foreach ($item in $errorGroupIdList)
        {            
            [PSCustomObject]$appName = $item | Select-Object -Property AppName   
            [PSCustomObject]$OrgName = $item | Select-Object -Property OrgName
            [PSCustomObject]$errGroup = $item | Select-Object -Property errorGroups

            foreach ($id in $errGroup)
            {
                $errorGroupId = $id.errorGroups | Select-Object -Property errorGroupId
                Get-ErrorId -errorGroupId $errorGroupId.errorGroupId -AppName $appName.AppName -OrgName $OrgName.OrgName -Token $appCenterApi
            }
        }
    }
}
function Get-StackTrace
{
    param
    (
        [Parameter(Mandatory)]
        [String]$OrgName,
        [Parameter(Mandatory)]
        [String]$AppName,
        [Parameter(Mandatory)]
        [String]$ErrorGroupId,
        [Parameter(Mandatory)]
        [String]$ErrorId,  
        [Parameter(Mandatory=$false)]
        [String]$Token=$appCenterApi        
    )  

    #https://openapi.appcenter.ms/#/errors/Errors_ErrorStackTrace
    #Error Stacktrace details. 
    Write-Host "Checking for Error Groups for" $OrgName"/"$AppName
    $uri = [string]::Format('https://api.appcenter.ms/v0.1/apps/{0}/{1}/errors/errorGroups/{2}/errors/{3}/stacktrace', $AppName, $OrgName, $ErrorGroupId, $ErrorId)    
    $uri 
    Write-Host "https://api.appcenter.ms/v0.1/apps/Examples/Android_Xamarin/errors/errorGroups/4107427461u/errors/2517652796888849999-8d88e378-17c9-4936-8557-6131dace02b1/stacktrace"

    $StackTrace = curl.exe -X GET $uri -H  "accept: application/json" -H  "X-API-Token: $appCenterApi" | ConvertFrom-Json
    
    
    $UpdatedDetails = New-Object 'Collections.Generic.List[PSCustomObject]'
    $UpdatedDetails += New-Object -TypeName psobject -Property @{OrgName=$OrgName; AppName=$AppName; ErrorGroupID=$ErrorGroupId; ErrorId=$ErrorId; StackTrace=$StackTrace}       

    $FinalProduct.Add($UpdatedDetails)
    
}
function Get-All-StackTraces
{
    param
    (
        [Parameter(Mandatory=$false)]
        [PSCustomObject]$errorGroupIdList=[PSCustomObject]$CompleteErrorGroupIdsList,
        [Parameter(Mandatory=$false)]
        [String]$Token=$appCenterApi       
    )

    if ($errorGroupIdList.Count -ne "0")
    {
        foreach ($GroupID in $errorGroupIdList)
        {
            foreach ($item in $GroupID)
            {                
                $item.ErrorIDs
                Get-StackTrace -AppName $item.AppName -OrgName $item.OrgName -ErrorGroupId $item.ErrorGroupId -ErrorId $item.ErrorIDs
            }
        }
    }
}

#Flow of calls which leads to grouping of stacktraces for your future analysis
Get-All-ErrorGroups #To View Results, examine $CompleteErrorGroupsList
#$CompleteErrorGroupsList | Format-Table -Wrap
Get-All-ErrorIds #To View Results, examine $CompleteErrorGroupIdsList
#$CompleteErrorGroupIdsList | Format-Table -Wrap
Get-All-StackTraces #To View Results, examine $CompleteStackTrace
#$FinalProduct | Format-Table -Wrap

$stacks = $FinalProduct | ForEach-Object { $_ | Select-Object -Property StackTrace }

foreach ($bug in $FinalProduct)
{
    Write-Host "App Name:" $bug[0].AppName -ForegroundColor Blue
    Write-Host "OrgName:" $bug[0].OrgName -ForegroundColor Blue
    Write-Host "ErrorGroupID:" $bug[0].ErrorGroupID -ForegroundColor Blue
    Write-Host "Title:" $bug[0].StackTrace.title -ForegroundColor Red
    Write-Host "Raw Frames"  -ForegroundColor Blue
    $bug[0].StackTrace.exception.frames.code_raw
}



