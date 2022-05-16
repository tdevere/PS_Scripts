Clear-Host

#Protecting API token - Get your own
$appCenterApi = $env:appcenterapi
$owner_name = "" #Replace with your Org/Owner Name
$app_name = "" #Replace with your App Name
$distribution_group = "" #Replace with your Distribution Group 
$exclude_pending_invitations = $true #Keeping Default; If false, included pending invites

function GetDistributionGroupMembers_Org
{
    param ([Parameter(Mandatory)]
        [string]$owner_name,
        [Parameter(Mandatory)]
        [string]$distribution_group)

        $curlUrl = 'https://api.appcenter.ms/v0.1/orgs/' + $owner_name + '/distribution_groups/' + $distribution_group + '/members'

        $results = curl -X GET $curlUrl -H "Content-Type: application/json" -H "accept: application/json" -H "X-API-Token: $appCenterApi" | ConvertFrom-Json

        return $results
}

function GetDistributionGroupMembers_App
{
    param ([Parameter(Mandatory)]
        [string]$owner_name,
        [Parameter(Mandatory)]
        [string]$app_name,
        [Parameter(Mandatory)]
        [string]$distribution_group,

        #$exclude_pending_invitations If false, included pending invites

        [string]$exclude_pending_invitations)

        $curlUrl = 'https://api.appcenter.ms/v0.1/apps/' + $owner_name + "/" + $app_name + '/distribution_groups/' + $distribution_group + '/members?exclude_pending_invitations=' + $exclude_pending_invitations

        $results = curl -X GET $curlUrl -H "Content-Type: application/json" -H "accept: application/json" -H "X-API-Token: $appCenterApi" | ConvertFrom-Json

        return $results
}


write-host "GetDistributionGroupMembers_Org" -ForegroundColor Red
$DistributionGroupMembers = GetDistributionGroupMembers_Org -owner_name "Portal_Issues" -distribution_group "SampleDistributionGroup"
$DistributionGroupMembers

write-host "GetDistributionGroupMembers_App" -ForegroundColor Blue
$DistributionGroupMembers = GetDistributionGroupMembers_App -owner_name "Portal_Issues" -app_name "DeletingUsersPortal" -distribution_group "SampleDistributionGroup" -exclude_pending_invitations $true
$DistributionGroupMembers 
