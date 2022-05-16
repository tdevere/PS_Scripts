Clear-Host

#Protecting API token - Get your own
$appCenterApi = $env:appcenterapi
$owner_name = "" #Replace with your Org/Owner Name
$app_name = "" #Replace with your App Name
$distribution_group = "" #Replace with your Distribution Group name
$invitationList = New-Object 'Collections.Generic.List[string]'

function GetAllTesters_Org
{
    param ([Parameter(Mandatory)]
    [string]$owner_name)

    $curlUrl = 'https://api.appcenter.ms/v0.1/orgs/' + $owner_name + '/invitations'

    $results = curl -X GET $curlUrl -H "Content-Type: application/json" -H "accept: application/json" -H "X-API-Token: $appCenterApi" | ConvertFrom-Json

    return $results
}

function GetAllTesters_App
{
    param ([Parameter(Mandatory)]
    [string]$owner_name,
    [string]$app_name)

    $curlUrl = 'https://api.appcenter.ms/v0.1/orgs/' + $owner_name + '/invitations'
    
    $results = curl -X GET $curlUrl -H "Content-Type: application/json" -H "accept: application/json" -H "X-API-Token: $appCenterApi" | ConvertFrom-Json

    return $results
}

GetAllTesters_Org -owner_name "Portal_Issues"

GetAllTesters_App -owner_name "Portal_Issues" -app_name "DeletingUsersPortal"