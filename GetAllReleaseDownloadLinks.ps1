Clear-Host
$apitoken = '"X-API-Token: ' + $env:appcenterapi + '"' #You need your own Token Here
$owner_name = "Examples"
$app_name = "ThreeAmigos_Android"
$scope = "tester"
$published_only = "true"
$FinalReleaseList = New-Object System.Collections.Generic.Dictionary"[String,String]"

function GetReleaseDetails 
{
       param (
        [Parameter(Mandatory,ParameterSetName = "Release_ID")]
        [string]$release_id
        )

    $appUri = 'https://api.appcenter.ms/v0.1/apps/' + $owner_name + '/' + $app_name + '/releases/' + $release_id   
    $release_detail = curl.exe -X GET $appUri -H "accept: application/json" -H $apitoken | ConvertFrom-Json    
    $FinalReleaseList.Add($release_id, $release_detail.download_url)
    
}

function GetReleases
{
    #Open API https://openapi.appcenter.ms/#/distribute/releases_list
    $appUri = 'https://api.appcenter.ms/v0.1/apps/' + $owner_name + '/' + $app_name + '/releases?published_only=' + $published_only + '&scope=' + $scope
    $releases = curl.exe -X GET $appUri -H "accept: application/json" -H $apitoken | ConvertFrom-Json

    foreach ($release in $releases)
    {
        $release.id
        GetReleaseDetails -release_id $release.id
    }
}

GetReleases

$FinalReleaseList | Format-List
