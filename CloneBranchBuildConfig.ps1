$AppCenterAPI = $env:appcenterapi #Protected Key; https://docs.microsoft.com/en-us/appcenter/api-docs/#creating-an-app-center-app-api-token
$branch = "Master"
$Owner_Name = "Examples"
$App_Name = "Android_Xamarin"

function Get-BranchConfiguration 
{
    param
    (
        [Parameter(Mandatory)]
        [String]
        $Branch,
        [String]
        $Owner,
        [String]
        $Application,
        [String]
        $Token        
    )    

    $uri = "https://api.appcenter.ms/v0.1/apps/$Owner/$Application/branches/$Branch/config"
    
    $headers = @{
        "accept" = "application/json"
        "X-API-Token" = "$token"
    }

    Invoke-WebRequest -Uri $uri -Method GET -Headers $headers | ConvertFrom-Json 

}

function Set-BranchConfiguration
{
    param
    (
        [Parameter(Mandatory)]
        [String]
        $Branch,
        [String]
        $Owner,
        [String]
        $Application,
        [String]
        $Token,
        $BranchConfig        
    )    

    $uri = "https://api.appcenter.ms/v0.1/apps/$Owner/$Application/branches/$Branch/config"
    
    $headers = @{
        "accept" = "application/json"
        "Content-Type" = "application/json"
        "X-API-Token" = "$token"
    }

    $BranchConfig.branch = $Branch #Change this if you want to update a new branch
    
    $BranchConfig = $BranchConfig | ConvertTo-Json
    
    Invoke-WebRequest -Uri $uri -Method POST -Headers $headers -Body $BranchConfig | ConvertFrom-Json 

}

function Get-EncodedKeystore {
    param
    (
        [Parameter(Mandatory)]
        [String]
        $KeystorePath
    )    

    if (Test-Path $KeystorePath)
    {
        $keystore = Get-Content $KeystorePath
        $bytes = [System.Text.Encoding]::Unicode.GetBytes($keystore)
        $EncodedText = [Convert]::ToBase64String($bytes)
    }

    return $EncodedText 
}



#Step 1: Pull the existing branch configuration.
$BranchConfiguration = Get-BranchConfiguration -Branch $branch -Owner $Owner_Name -Application $App_Name -Token $AppCenterAPI 

#Step 2: Modify any specific elements. In this example, we clone the branch and only change the branch name. You can change any property you wish.

#Step 3: POST the new branch configuration
Set-BranchConfiguration -Branch NewFeature -Owner $Owner_Name -Application $App_Name -Token $AppCenterAPI -BranchConfig $BranchConfiguration