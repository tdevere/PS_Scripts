Clear-Host
#Only Run Once per session to avoid duplicated calls
$runOncePerSession = $false #Set to true to initialize values

#Protecting API token - Get your own
$appCenterApi = $env:appcenterapi


#List Of Orgs
#https://openapi.appcenter.ms/#/account/organizations_list
#Returns a list of organizations the requesting user has access to
if ($runOncePerSession)
{
    $OrgList = curl.exe -X GET "https://api.appcenter.ms/v0.1/orgs" -H  "accept: application/json" -H  "X-API-Token: $appCenterApi" | ConvertFrom-Json
    $OrgList | Select-Object name
}
#Get List of Apps
#https://openapi.appcenter.ms/#/account/apps_listForOrg
#Returns a list of apps for the organization
if ($runOncePerSession)
{
    $AppList = New-Object 'Collections.Generic.List[PSCustomObject]'

    foreach ($org in $OrgList) {
        $org.name
        $uri = 'https://api.appcenter.ms/v0.1/orgs/' + $org.name + '/apps'
        curl.exe -X GET $uri -H "accept: application/json" -H "X-API-Token: $appCenterApi" | Out-File 'c:\temp\sample.json'
        $apps = curl.exe -X GET $uri -H "accept: application/json" -H "X-API-Token: $appCenterApi" | ConvertFrom-Json
        $AppList.Add($apps)

    }
}

#region begin OpenApi_Accounts

#region begin GET_Requests
function CoreGETFunctionByUri
{
    param (
        [string]
        $URI        
    )

    #All the changes for these calls is the URI
    curl.exe -X GET $uri -H "accept: application/json" -H "X-API-Token: $appCenterApi" | ConvertFrom-Json
}

function GetUserMetadata
{
    #https://openapi.appcenter.ms/#/account/Users_getUserMetadata    
    $uri = 'https://api.appcenter.ms/v0.1/user/metadata/optimizely'
    CoreGETFunctionByUri -URI $uri
}

function GetSharedConnections
{
    #https://openapi.appcenter.ms/#/account/sharedconnection_Connections    
    $uri = 'https://api.appcenter.ms/v0.1/user/export/serviceConnections'    
    CoreGETFunctionByUri -URI $uri
}

function GetUser
{
    #https://openapi.appcenter.ms/#/account/users_get  
    $uri = 'https://api.appcenter.ms/v0.1/user/'    
    CoreGETFunctionByUri -URI $uri
}

function GetListOfAppsByUserName
{
    param (
        [string]
        $OrgName,
        [string]
        $UserName       
    )
    #https://openapi.appcenter.ms/#/account/users_listForOrg
    #NOTE: Use GetUser function to get name property

    $uri = 'https://api.appcenter.ms/v0.1/orgs/'+ $OrgName + '/users/' + $UserName + "/apps"
    CoreGETFunctionByUri -URI $uri
}

function GetUserByOrgName
{
    param (
        [string]
        $OrgName,
        [string]
        $UserName       
    )
    #https://openapi.appcenter.ms/#/account/users_getForOrg
    #NOTE: Use GetUser function to get name property

    $uri = 'https://api.appcenter.ms/v0.1/orgs/'+ $OrgName + '/users/' + $UserName
    CoreGETFunctionByUri -URI $uri
}

function GetListOfUsersByOrg
{
    param (
        [string]
        $OrgName    
    )
    #https://openapi.appcenter.ms/#/account/users_listForOrg
    $uri = 'https://api.appcenter.ms/v0.1/orgs/'+ $OrgName + '/users'
    CoreGETFunctionByUri -URI $uri
}

function GetListOfTestersByOrg
{
    param (
        [string]
        $OrgName    
    )
    #https://openapi.appcenter.ms/#/account/distributionGroups_listAllTestersForOrg
    #Returns a unique list of users including the whole organization members plus testers in any shared group of that org
    $uri = 'https://api.appcenter.ms/v0.1/orgs/'+ $OrgName + '/testers'
    CoreGETFunctionByUri -URI $uri
}

function GetListOfUsersByTeamName
{
    param (
        [string]
        $OrgName,
        [string]
        $TeamName     
    )
    #https://openapi.appcenter.ms/#/account/teams_getUsers
    $uri = 'https://api.appcenter.ms/v0.1/orgs/'+ $OrgName + '/teams/' + $TeamName
    CoreGETFunctionByUri -URI $uri
}

function GetListOfAppsByTeamName
{
    param (
        [string]
        $OrgName,
        [string]
        $TeamName     
    )
    #https://openapi.appcenter.ms/#/account/teams_getUsers
    $uri = 'https://api.appcenter.ms/v0.1/orgs/'+ $OrgName + '/teams/' + $TeamName + '/apps'
    CoreGETFunctionByUri -URI $uri
}

function GetTeamByName
{
    param (
        [string]
        $OrgName,
        [string]
        $TeamName     
    )
    #https://openapi.appcenter.ms/#/account/teams_getUsers
    $uri = 'https://api.appcenter.ms/v0.1/orgs/'+ $OrgName + '/teams/' + $TeamName
    CoreGETFunctionByUri -URI $uri
}

function GetListOfTeams
{
    param (
        [string]
        $OrgName    
    )
    #https://openapi.appcenter.ms/#/account/teams_listAll
    $uri = 'https://api.appcenter.ms/v0.1/orgs/'+ $OrgName + '/teams'
    CoreGETFunctionByUri -URI $uri
}

#NEXT ITEM https://openapi.appcenter.ms/#/account/orgInvitations_listPending

function GetListOfPendingInvitations
{
    param (
        [string]
        $OrgName    
    )
    #https://openapi.appcenter.ms/#/account/orgInvitations_listPending
    #Gets the pending invitations for the organization
    $uri = 'https://api.appcenter.ms/v0.1/orgs/'+ $OrgName + '/invitations'
    CoreGETFunctionByUri -URI $uri
}

function GetAppByName
{
    #https://openapi.appcenter.ms/#/account/apps_get
    Param([string]$ownerName,[string]$appName)

    $uri = "https://api.appcenter.ms/v0.1/apps/$ownerName/$appName"
    $uri
$headers = @{    
    "accept" = "application/json"    
    "X-API-Token" = $AppCenterAPI
    "Content-Type" = "application/json"
}

    $results = Invoke-WebRequest -Uri $uri -Method Get -Headers $headers | ConvertFrom-Json   

    $results
}

function GetOrgByName
{
    param (
        [string]
        $OrgName        
    )

   
}

function GetDistributionGroups
{
    param (
        [string]
        $OrgName        
    )
    #https://openapi.appcenter.ms/#/account/distributionGroups_listForOrg
    $uri = 'https://api.appcenter.ms/v0.1/orgs/' + $org.name + '/distribution_groups'
    curl.exe -X GET $uri -H  "accept: application/json" -H  "X-API-Token: $appCenterApi" | ConvertFrom-Json
}

function GetAzureSubscriptionsByOrg
{
    param (
        [string]
        $OrgName        
    )
    #https://openapi.appcenter.ms/#/account/distributionGroups_listForOrg
    $uri = 'https://api.appcenter.ms/v0.1/orgs/' + $org.name + '/azure_subscriptions'
    curl.exe -X GET $uri -H  "accept: application/json" -H  "X-API-Token: $appCenterApi" | ConvertFrom-Json
}

function GetAllInvitationsSentForUser
{
    #https://openapi.appcenter.ms/#/account/invitations_sent
    #Uses API for query
    $uri = 'https://api.appcenter.ms/v0.1/invitations/sent'
    curl.exe -X GET $uri -H  "accept: application/json" -H  "X-API-Token: $appCenterApi" | ConvertFrom-Json
}

function GetAzureSubscriptionsForUser
{
    #https://openapi.appcenter.ms/#/account/invitations_sent
    #Uses API for query
    $uri = 'https://api.appcenter.ms/v0.1/azure_subscriptions'
    curl.exe -X GET $uri -H  "accept: application/json" -H  "X-API-Token: $appCenterApi" | ConvertFrom-Json
}

#endregion

#region begin POST_Request
#First Line

function CorePOSTFunction
{
    param ([string]$URI, [string]$Body, [string]$Headers)

    #All the changes for these calls is the URI
    $results = Invoke-WebRequest -Uri "https://api.appcenter.ms/v0.1/orgs" -Method Post -Body ($body) -Headers $headers | ConvertFrom-Json   
    return $results
}

function NewAppCenter_Org
{
    Param([string]$orgname)

    #https://openapi.appcenter.ms/#/account/organizations_createOrUpdate
    #Creates a new organization and returns it to the caller
    $uri = "https://api.appcenter.ms/v0.1/orgs"

    $headers = @{    
        "X-API-Token" = $appCenterApi
        "accept" = "application/json"
        "Content-Type" = "application/json"
    }

$body = 
@"
{
    "display_name": "$orgname",
    "name": "$orgname"
  }
"@
    $results = CorePOSTFunction -URI $uri -Body ($body) -Headers $headers | ConvertFrom-Json   
    $results
}

function NewAppCenterOrg_App
{
    Param([string]$orgname, [string]$description, [string]$release_type, [string]$name, [string]$display_name, [string]$os, [string]$platform)

    #https://openapi.appcenter.ms/#/account/apps_create
    #Creates a new app and returns it to the caller
$uri = "https://api.appcenter.ms/v0.1/orgs/$orgname/apps"

$headers = @{    
    "accept" = "application/json"    
    "X-API-Token" = $AppCenterAPI
    "Content-Type" = "application/json"
}

$body = 
@"
{
    "description": "$description",
    "release_type": "$release_type",
    "display_name": "$display_name",
    "name": "$name",        
    "os": "$os",
    "platform": "$platform"
  }
"@

$results = CorePOSTFunction -URI $uri -Body ($body) -Headers $headers | ConvertFrom-Json   
$results

}

#endregion

#region begin PATCH_Request
#First Line

function CorePATCHFunction
{
    param ([string]$URI, [string]$Body, [string]$Headers)

    #All the changes for these calls is the URI
    $results = Invoke-WebRequest -Uri "https://api.appcenter.ms/v0.1/orgs" -Method Post -Body ($body) -Headers $headers | ConvertFrom-Json   
    return $results
}

function UpdateAppcenter_App
{
    #https://openapi.appcenter.ms/#/account/apps_update
    #Partially updates a single app

    Param([string]$ownerName,[string]$Existing_appName, [string]$new_display_name, [string]$new_name)

    $uri = "https://api.appcenter.ms/v0.1/apps/$ownerName/$Existing_appName"

$headers = @{    
    "accept" = "application/json"    
    "X-API-Token" = $AppCenterAPI
    "Content-Type" = "application/json"
}

#Only updating names here but you can do more. visit the open api link for more details
$body = 
@"
{
    "display_name": "$new_display_name",
    "name": "$new_name"        
}
"@

    $results = CorePATCHFunction -URI $uri -Body ($body) -Headers $headers | ConvertFrom-Json   
    $results
}


#endregion

#region begin DELETE_Request
#First Line
#endregion

#Last Line Of OpenApi_Accounts
#endregion


#GetAppByName -ApplicationName "Kent-G-UWP-Experiments"
#GetOrgByName -OrgName "Examples"
#GetDistributionGroups -OrgName "Examples"
#GetAzureSubscriptionsByOrg -OrgName "Examples"
#GetAllInvitationsSentForUser
#GetAzureSubscriptionsForUser
#GetUserMetadata
#GetSharedConnections
#GetListOfUsersByOrg -OrgName "Examples"
#GetUser
#GetListOfAppsByUserName -OrgName "Examples"  -UserName "tdevere-microsoft.com"
#GetUserByOrgName
#GetListOfTestersByOrg -OrgName "Examples"
#GetListOfTeams -OrgName "Examples"
#GetListOfPendingInvitations -OrgName "Examples"