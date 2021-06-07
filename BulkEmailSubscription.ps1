Clear-Host

#Protecting API token - Get your own
$appCenterApi = $env:appcenterapi

#note: gmail accounts can be used for test purpose
# {baseEmailAddress}+{NewID}@gmail.com
# messages will be received at {baseEmailAddress}@gmail.com

$baseEmail = "" #Replace with your own gmail for this test to work
$owner_name = "" #Replace with your Org/Owner Name
$app_name = "" #Replace with your App Name
$distribution_group = "" #Replace with your Distribution Group name
$invitationList = New-Object 'Collections.Generic.List[string]'

function GenerateSampleEmails {
    #Otherwise, supply your own values
    for ($i = 1; $i -le 10; $i++) 
    {
        $invitationList.Add("$baseEmail+$i@gmail.com")        
    }
}

GenerateSampleEmails

#https://openapi.appcenter.ms/#/account/distributionGroups_addUser
#Adds the members to the specified distribution group
# Example

$curlUrl = 'https://api.appcenter.ms/v0.1/apps/' + $owner_name + '/' + $app_name + '/distribution_groups/' + $distribution_group + '/members'


foreach ($email in $invitationList)
{     
    $emailList = '"{\"user_emails\":[\"' + $email + '\"]}"' #| ConvertFrom-Json
    $emailList    
    $curlUrl
    curl -X POST $curlUrl -H "Content-Type: application/json" -H "accept: application/json" -H "X-API-Token: $appCenterApi" -d $emailList
}

