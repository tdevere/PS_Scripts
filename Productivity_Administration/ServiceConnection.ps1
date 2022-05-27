$AppCenterAPI = $env:appcenterapi #Protected Key; https://docs.microsoft.com/en-us/appcenter/api-docs/#creating-an-app-center-app-api-token


function Get-ServiceConnections
{
    param 
    (
        [string] $storeName
    )

    $headers = @{    
        "X-API-Token" = $AppCenterAPI
    }

    Invoke-WebRequest -Method Get -Uri "https://api.appcenter.ms/v0.1/user/serviceConnections?serviceType=$storeName&credentialType=credentials" -Headers $headers -ContentType "application/json" | ConvertFrom-Json  
}

Get-ServiceConnections -storeName "apple"
Get-ServiceConnections -storeName "googleplay"
