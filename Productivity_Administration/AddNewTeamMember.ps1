Clear-Host
#Protecting API token - Get your own
$appCenterApi = $env:appcenterapi
$orgName = "Examples"
$teamName = "Team-A"
$email = "Sample@Sample.org"

function NewMemberToTeam
{
    Param([string] $orgName, [string]$teamName, [string]$email)
    #API: https://openapi.appcenter.ms/#/account/teams_addUser
    $uri = "https://appcenter.ms/api/v0.1/orgs/$orgName/teams/$teamName/users"

    $headers = @{    
        "X-API-Token" = $appCenterApi
    }

$json = 
@"
    {
        "user_email": "$email"
    }
"@

    Invoke-WebRequest -Uri $uri -Method Post -Body $json -Headers  $headers -ContentType "application/json" | ConvertFrom-Json 

}


NewMemberToTeam -orgName $orgName -teamName $teamName -email $email
