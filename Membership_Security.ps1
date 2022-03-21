Clear-Host

#Protecting API token - Get your own
$appCenterApi = $env:appcenterapi
$Organization_Name = "Examples"
$ValidEmailDomain = "microsoft.com"

function Get-OrganizationUserList
{
    #https://openapi.appcenter.ms/#/account/users_listForOrg
    #Returns a list of users that belong to an organization
    Param(
            [Parameter(Mandatory = $true, HelpMessage="Send string list")]
            [ValidateNotNullOrEmpty()]
            [string] $orgname
        )
        
    $curlUrl = 'https://api.appcenter.ms/v0.1/orgs/' + $Organization_Name + '/users'

    $userList = New-Object 'Collections.Generic.List[string]'

    $userList = curl -X GET $curlUrl -H "Content-Type: application/json" -H "accept: application/json" -H "X-API-Token: $appCenterApi" | ConvertFrom-Json
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

    $NotAuthorizedUserList = New-Object 'Collections.Generic.List[string]'
    $RemoveList = @{}

    foreach ($user in $Users)
    {   
        $AtIndex = $user.ToString().IndexOf('@')
        $email_domain = $user.ToString().Remove(0, $AtIndex+1)
        
        if ($email_domain.ToString().ToLower() -ne $ValidEmailDomain.ToString().ToLower()) 
        {
            $NotAuthorizedUserList.Add($user)            
            $userDetails = $CurrentListOfOrgUsers | Where-Object { $_.email -eq $user } | Select-Object email, name
            $RemoveList.Add($userDetails.name, $userDetails.email)
            Write-Host "Security Alert - $user registered email is not a member of $ValidEmailDomain" -ForegroundColor Red
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

    $constent =  'N' #Permission to remove user; No By Default
    foreach ($userName in $RemoveUserList.Keys)
    {

        $constent = Read-Host -Prompt "Remove $userName from $orgname? Y|N|A"

        if (($constent -ne 'A') -or ($constent -ne 'Y'))
        {
            #Do not remove user
            Write-Host "You have opted to keep $userName active in $orgname."
        }
        else
        {
            #Try to remove User
            Write-Host "You have opted to remove $userName active in $orgname."
            $curlUrl = 'https://api.appcenter.ms/v0.1/orgs/' + $Organization_Name + '/users/' + $userName
            curl -X DELETE $curlUrl -H "Content-Type: application/json" -H "accept: application/json" -H "X-API-Token: $appCenterApi" | ConvertFrom-Json
        }
    }
}


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
