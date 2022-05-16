Clear-Host

#Protecting API token - Get your own
$appCenterApi = $env:appcenterapi

function GetPendingInvites_Orgs
{
    param ([Parameter(Mandatory)]
        [string]$owner_name)

        Write-Host "GetPendingInvites_Orgs for $owner_name" -ForegroundColor Blue

        $curlUrl = 'https://api.appcenter.ms/v0.1/orgs/' + $owner_name + '/invitations'

        $curlUrl
    
        $results = curl -X GET $curlUrl -H "Content-Type: application/json" -H "accept: application/json" -H "X-API-Token: $appCenterApi" | ConvertFrom-Json

        return $results

}

function ResendInvite_Org
{
    param ([Parameter(Mandatory)]
    [string]$owner_name,        
    [Parameter(Mandatory)]
    [string]$email)
    
    $curlUrl = 'https://api.appcenter.ms/v0.1/orgs/' + $owner_name + '/invitations/' + $email + '/resend'

    Write-Host "ResendInvite_Org to $email for $owner_name" -ForegroundColor Blue

    $results = curl -X POST $curlUrl -H "Content-Type: application/json" -H "accept: application/json" -H "X-API-Token: $appCenterApi" -Body | ConvertFrom-Json

    return $results
}

function RevokeInvitation_Org
{
    param ([Parameter(Mandatory)]
    [string]$owner_name,
    [Parameter(Mandatory)]
    [string]$email)

    $curlUrl = 'https://api.appcenter.ms/v0.1/orgs/' + $owner_name + '/invitations/' + $email + '/revoke'

    Write-Host "Revoking Invite for $email for $owner_name" -ForegroundColor Blue


    $results = curl -X POST $curlUrl -H "Content-Type: application/json" -H "accept: application/json" -H "X-API-Token: $appCenterApi" | ConvertFrom-Json

    return $results
}

function InviteUser_Org
{
    param ([Parameter(Mandatory)]
    [string]$owner_name,
    [Parameter(Mandatory)]
    [string]$email,
    [Parameter(Mandatory)]
    [string]$role)

    $body = '{\"user_email\":\"'+$email+'\",\"role\":\"'+$role+'\"}' | ConvertTo-Json
    $converted = $body | ConvertFrom-Json

    $curlUrl = 'https://api.appcenter.ms/v0.1/orgs/' + $owner_name + '/invitations/'

    Write-Host "Inviting $email to  $owner_name" -ForegroundColor Blue


    $results = curl -X POST $curlUrl -H "Content-Type: application/json" -H "accept: application/json" -H "X-API-Token: $appCenterApi" -d $converted | ConvertFrom-Json

    return $results

}


#Get List of Pending Invites
$PendingInvites_InputObject = GetPendingInvites_Orgs -owner_name "Portal_Issues"

#Invite User
InviteUser_Org -owner_name "Portal_Issues" -email "sample@emailtest.com" -role "member"

#Rsend Invites
#$PendingInvites_InputObject.email | ForEach-Object { if ($_ -ne $null) { ResendInvite_Org -owner_name "Portal_Issues" -email $_ } }

#Revoke Invites
$PendingInvites_InputObject.email | ForEach-Object { if ($_ -ne $null) { RevokeInvitation_Org -owner_name "Portal_Issues" -email $_ } }

#Updated List of Pending Invites
$PendingInvites_SideIndicator = GetPendingInvites_Orgs -owner_name "Portal_Issues"

Write-Host "Original invite list on the left. Updated list on the right. If both contain the same data, no change." -ForegroundColor Blue
Compare-Object $PendingInvites $UpdatePendingInvites