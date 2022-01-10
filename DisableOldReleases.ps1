Clear-Host
$apitoken = '"X-API-Token: ' + $env:appcenterapi + '"' #You need your own Token Here
$owner_name = "Examples"
$app_name = "ThreeAmigos_Android"
$scope = #"tester" #Blank if all userse
$published_only = "false" #include published only?
$DisableReleasesOnAndBefore = (Get-Date).AddDays(-180) #6 months or older; disable
$Messages = New-Object System.Collections.Generic.List"[String]"

function UpdateRelease 
{
    #https://openapi.appcenter.ms/#/distribute/releases_updateDetails
    param (        
    [string]$release_id,
    [string]$owner_name,
    [string]$app_name)
    
    $disableReleaseJson = '"{\"enabled\": false}"' 
    $appUri = 'https://api.appcenter.ms/v0.1/apps/' + $owner_name + '/' + $app_name + '/releases/' + $release_id       
    $release_detail = curl.exe -X PUT $appUri -H $apitoken -H "Content-Type: application/json" -H "accept: application/json" -d $disableReleaseJson | ConvertFrom-Json    
    #Write-Host $owner_name'/'$app_name'/releases/'$release_id'/status:'($release_detail.enabled)
    $msg = $owner_name + '/' + $app_name + '/releases/' + $release_id + '/status:'+ $release_detail.enabled
    $Messages.Add($msg )
}


function Disable-ReleasesOnOrBeforeDate
{#Open API https://openapi.appcenter.ms/#/distribute/releases_list
    param (
        [Parameter(Mandatory=$false)]
        [DateTime]$DisableReleasesOnAndBefore = (Get-Date).AddDays(-180)
        )
    
    $appUri = 'https://api.appcenter.ms/v0.1/apps/' + $owner_name + '/' + $app_name + '/releases?published_only=' + $published_only + '&scope=' + $scope
    $releases = curl.exe -X GET $appUri -H "accept: application/json" -H $apitoken | ConvertFrom-Json

    $releases | ForEach-Object { 
        if ($_.enabled -eq $true) 
        {   
            [DateTime]$uploadedDateTime = $_.uploaded_at #$DisableReleasesOnAndBefore
            
            if ((Get-Date $uploadedDateTime) -le (Get-Date $DisableReleasesOnAndBefore))
            {
               $msg = $owner_name + '/' + $app_name + '/releases/' + $_.id + '/status:'+ $_.enabled
               $Messages.Add($msg)
               $Messages.Add("Release is older than " + $DisableReleasesOnAndBefore + " attempting to disable.")
               UpdateRelease -release_id $_.id -owner_name $owner_name -app_name $app_name
            }
        }
        else
        {   
            $msg = $owner_name + '/' + $app_name + '/releases/' + $_.id + '/status:'+ $_.enabled
            $Messages.Add($msg)
        } 
    }
}

#Pass in DateTime value to select which releases are disabled
Disable-ReleasesOnOrBeforeDate -DisableReleasesOnAndBefore (Get-Date).AddDays(-180)

#List Results 
$Messages



