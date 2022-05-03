#This sample shows how you can determine which build repo connections are not currently valid. 

Clear-Host

#Protecting API token - Get your own
$appCenterApi = $env:appcenterapi
$owner_name = ""
$app_name = ""
$uri = "https://appcenter.ms/api/v0.1/apps/$owner_name/$app_name/branches"

function IsRepoConnectionValid
{
    param (
        [string]
        $owner,
        [string]
        $name
    )

    $IsValid = $true
    $bContinue = $true
    
    $uri = "https://appcenter.ms/api/v0.1/apps/$owner/$name/branches"
    
    $branches = curl -X GET $uri -H  "accept: application/json" -H  "X-API-Token: $appCenterApi" | ConvertFrom-Json

    if ($null -ne $branches.statusCode)
    {
        Write-Host $branches
        $bContinue = $false
        $IsValid = $false
    }

    if ($bContinue)
    {
        foreach ($branch in $branches)
        {
            if ($null -ne $branch.message)
            {
                if ($branch.message.ToString().ToLower() -eq "Not Found")
                {
                    Write-Host "Needs Reconnection -> " $branches[0] -ForegroundColor Red
                    $IsValid = $false
                }
            }
        }
    }

    return $IsValid
}

IsRepoConnectionValid -owner $owner_name -name $app_name 
