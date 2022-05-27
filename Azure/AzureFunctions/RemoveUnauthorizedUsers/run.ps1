# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

Write-Host "START TIME: $currentUTCtime"

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

#Protecting API token - Get your own
$appCenterApi = $env:APIKEY
$Organization_Name = $env:Organization_Name
$ValidEmailDomain = $env:ValidEmailDomain
$GeneralHeaders = @{}
$GeneralHeaders.Add("X-API-Token", $appCenterApi)
$GeneralHeaders.Add("Content-Type", "application/json")
$GeneralHeaders.Add("accept", "application/json")

#AppCenter Analytics
$apiUri = "https://in.appcenter.ms/logs?api-version=1.0.0"
$sid = $env:SID #This is the identifier for the new session
$AppSecret = $env:AzureSecurityCheck #App Center Secret
$InstallID = $env:InstallID #Device Install ID

Write-Host "Organization Name: $Organization_Name and valid email domain: $ValidEmailDomain"

function Get-OrganizationUserList
{

    #https://openapi.appcenter.ms/#/account/users_listForOrg
    #Returns a list of users that belong to an organization
    Param(
            [Parameter(Mandatory = $true, HelpMessage="Send string list")]
            [ValidateNotNullOrEmpty()]
            [string] $orgname
        )
    
    #Write-Host "GeneralHeaders"
    #Write-Host $GeneralHeadersasJson

    $curlUrl = 'https://api.appcenter.ms/v0.1/orgs/' + $Organization_Name + '/users'

    $userList = New-Object 'Collections.Generic.List[string]'

    #$userList = curl -X GET $curlUrl -H "Content-Type: application/json" -H "accept: application/json" -H "X-API-Token: $appCenterApi" | ConvertFrom-Json

    Write-Host "Calling $curlUrl"
    
    $userList = Invoke-WebRequest -Method Get -Uri $curlUrl -Headers @{'Accept' = 'application/json'; 'Content-Type' = 'application/json'; 'X-API-Token' = $appCenterApi } | ConvertFrom-Json

    Write-Host "Result"
    Write-Host $userList

    Send-Event -EventName "Get-OrganizationUserList"

    return $userList
}

function SecurityCheck_IsAuthorizedEmail
{    
    #Validate Users Email Account
    Param(
            [Parameter(Mandatory = $true, HelpMessage="Send string list")]
            [ValidateNotNullOrEmpty()]
            [string[]] $Users,
            [string] $ValidEmailDomain
        )

    Send-Event -EventName "SecurityCheck_IsAuthorizedEmail"

    $RemoveList = @{}

    foreach ($user in $Users)
    {   
        $AtIndex = $user.ToString().IndexOf('@')
        $email_domain = $user.ToString().Remove(0, $AtIndex+1)
        
        if ($email_domain.ToString().ToLower() -ne $ValidEmailDomain.ToString().ToLower()) 
        {       
            $userDetails = $CurrentListOfOrgUsers | Where-Object { $_.email -eq $user } | Select-Object email, name
            $RemoveList.Add($userDetails.name, $userDetails.email)
            Write-Host "Security Alert - $user registered email is not a member of $ValidEmailDomain" #-ForegroundColor Red
            Send-Event -EventName "Security_Alert_UnAuthorized_User"
            Send-Event -EventName "Removed_$userDetails.email"
        }
    }

    return $RemoveList
}

function RemoveUnauthorizedUsersFromOrg
{
    #https://openapi.appcenter.ms/#/account/users_removeFromOrg
    #Removes a user from an organization.    

    Param(
        [Parameter(Mandatory = $true, HelpMessage="Send string list")]
        [ValidateNotNullOrEmpty()]
        $RemoveUserList,
        [string] $orgname
    )
        
    $curlUrl = 'https://api.appcenter.ms/v0.1/orgs/' + $Organization_Name + '/users/'

    #$constent =  'N' #Permission to remove user; No By Default

    foreach ($userName in $RemoveUserList.Keys)
    {

        # $constent = Read-Host -Prompt "Remove $userName from $orgname? Y|N|A"

        # if (($constent -ne 'A') -or ($constent -ne 'Y'))
        # {
        #     #Do not remove user
        #     Write-Host "You have opted to keep $userName active in $orgname."
        # }
        # else
        # {
        #     #Try to remove User
        #     Write-Host "You have opted to remove $userName active in $orgname."
        #     $curlUrl = 'https://api.appcenter.ms/v0.1/orgs/' + $Organization_Name + '/users/' + $userName
        #     curl -X DELETE $curlUrl -H "Content-Type: application/json" -H "accept: application/json" -H "X-API-Token: $appCenterApi" | ConvertFrom-Json
        # }

        #Try to remove User
        Write-Host "You have opted to remove $userName active in $orgname."
        $curlUrl = 'https://api.appcenter.ms/v0.1/orgs/' + $Organization_Name + '/users/' + $userName
        #curl -X DELETE $curlUrl -H "Content-Type: application/json" -H "accept: application/json" -H "X-API-Token: $appCenterApi" | ConvertFrom-Json
        Invoke-WebRequest -Method Delete -Uri $curlUrl -Headers  @{'Accept' = 'application/json'; 'Content-Type' = 'application/json'; 'X-API-Token' = $appCenterApi } | ConvertFrom-Json
        Send-Event -EventName "Security_Alert_UnAuthorized_User_Removed"
    }
}


function  Start_Security_Check
{
    #Returns a list of users that belong to an organization
    $CurrentListOfOrgUsers = Get-OrganizationUserList -orgname $Organization_Name
    #Validate Users Email Account
    if ($CurrentListOfOrgUsers.Count -ge 1)
    {
        $RemoveUsersList = SecurityCheck_IsAuthorizedEmail -Users $CurrentListOfOrgUsers.email -ValidEmailDomain $ValidEmailDomain
    }
    #Remove Unauthorized Users
    if ($RemoveUsersList.Count -ge 1)
    {
        RemoveUnauthorizedUsersFromOrg -RemoveUserList $RemoveUsersList -orgname $Organization_Name
    }
}




function Start-Session
{

    $date = Get-Date -UFormat '+%Y-%m-%dT%H:%M:%S.000Z'

$json = 
@"
{
    "logs": [
        {
            "timestamp": "$date",
            "sid": "$sid",
            "device": {
              "sdkName": "appcenter.winforms",
              "sdkVersion": "4.2.0",
              "model": "$model",
              "oemName": "HP",
              "osName": "WINDOWS",
              "osVersion": "10.0.19042",
              "osBuild": "10.0.19042.928",
              "locale": "en-US",
              "timeZoneOffset": -360,
              "screenSize": "3440x1440",
              "appVersion": "1.0.0.0",
              "appBuild": "1.0.0.0",
              "appNamespace": "AppCenter_WinForm"
            },
            "type": "startSession"
        }
        ]
}
"@

    $startSession = Invoke-WebRequest -Uri $apiUri -Method Post -Body ($json) -Headers @{'Accept' = 'application/json'; 'Content-Type' = 'application/json'; 'App-Secret' = $AppSecret; 'Install-ID' = $InstallID } -ContentType "application/json" | ConvertFrom-Json  
    Write-Output "Start-Session result $startSession.status"

}

function Send-Event
{
    Param([string]$EventName) #end param

    if ($EventName -ne "")
    {   
        $id = [Guid]::NewGuid()
        $Global:id = $id
        $Global:timestamp = Get-Date -UFormat '+%Y-%m-%dT%H:%M:%S.000Z'
        $timestamp = $Global:timestamp
$json = 
@"
{
    "logs": [
        {
            "id": "$id",
            "name": "$EventName",
            "timestamp": "$timestamp",
            "sid": "$sid ",
            "device": {
              "sdkName": "appcenter.winforms",
              "sdkVersion": "4.2.0",
              "model": "$model",
              "oemName": "HP",
              "osName": "WINDOWS",
              "osVersion": "10.0.19042",
              "osBuild": "10.0.19042.928",
              "locale": "en-US",
              "timeZoneOffset": -360,
              "screenSize": "3440x1440",
              "appVersion": "1.0.0.0",
              "appBuild": "1.0.0.0",
              "appNamespace": "AppCenter_WinForm"
            },
            "type": "event"
          }
        ]
}
"@

    $sendEventResults = Invoke-WebRequest -Uri $apiUri -Method Post -Body ($json) -Headers @{'Accept' = 'application/json'; 'Content-Type' = 'application/json'; 'App-Secret' = $AppSecret; 'Install-ID' = $InstallID } -ContentType "application/json" | ConvertFrom-Json 
    Write-Output "Send-Event result $sendEventResults"

    }
}

Write-Host "Start-Session"
Start-Session
Send-Event -EventName "Start_Security_Check"
Start_Security_Check
Send-Event -EventName "Start_Security_Check_END"



