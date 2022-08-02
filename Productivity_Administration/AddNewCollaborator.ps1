Clear-Host
#Protecting API token - Get your own
$appCenterApi = $env:appcenterapi
$orgName = "Examples"
$AppCenterRole = "member" #Member, admin, collaborator ## Watch for capital letters
$email = "Sample@Sample.org"

function NewMemberAddToCollaborators
{
    Param([string] $orgName, [string]$AppCenterRole, [string]$email)
    #API: https://openapi.appcenter.ms/#/account/teams_addUser
    $uri = "https://appcenter.ms/api/v0.1/orgs/$orgName/invitations"

    $headers = @{    
        "X-API-Token" = $appCenterApi
    }

$json = 
@"
    {
        "user_email": "$email",
        "role": "$AppCenterRole"
    }
"@

    Invoke-WebRequest -Uri $uri -Method Post -Body $json -Headers  $headers -ContentType "application/json" | ConvertFrom-Json 

    $json 

}


NewMemberAddToCollaborators -orgName $orgName -AppCenterRole $AppCenterRole -email $email
