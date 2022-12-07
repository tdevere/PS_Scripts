function Get-BranchConfiguration 
{
    #https://openapi.appcenter.ms/#/build/branchConfigurations_get
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

    Invoke-WebRequest -Uri $uri -Method GET -Headers $headers | ConvertFrom-Json -Depth 6

}

function Set-BranchConfiguration
{
    #https://openapi.appcenter.ms/#/build/branchConfigurations_create

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

    #$BranchConfig.branch = $Branch #Change this if you want to update a new branch
    
    $BranchConfig = $BranchConfig | ConvertTo-Json

    #Write-Host $BranchConfig
    
    Invoke-WebRequest -Uri $uri -Method POST -Headers $headers -Body $BranchConfig | ConvertFrom-Json -Depth 6

}

#SETUP INSTRUCTIONS
#Get your App Center API Key
$AppCenterAPI = #Protected Key; https://docs.microsoft.com/en-us/appcenter/api-docs/#creating-an-app-center-app-api-token

#USE THE CONFIG FROM A WORKING EXAMPLE; you mentioned befor that you could create the app connection to the repository
#so use that app to get a template for the next app
$Owner_Name = "Examples"
$App_Name = "Clone_Example"
$branch = "Master"

#Pull the existing branch configuration.
$BranchConfiguration = Get-BranchConfiguration -Branch $branch -Owner $Owner_Name -Application $App_Name -Token $AppCenterAPI 

#Now Create a new branch configuration by sending a POST using the old config as a template
$Owner_Name #Change if needed
$App_Name #Change if needed
$Branch_Name = "Make sure this pointing to the branch we are trying to configure using the previous config as a template"
$SetBranchConfigResults = Set-BranchConfiguration -Branch $Branch_Name -Owner $Owner_Name -Application $App_Name -Token $AppCenterAPI -BranchConfig $BranchConfiguration
Write-Host $SetBranchConfigResults 

#Please share details if this fails