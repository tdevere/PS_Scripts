Clear-Host
#App Center Analytic Portal sort uses the name of the version to determine the latest version. This alphabetical system may impact
#the ability to determine the correct "latest version". If this is inconvenient you may pull the version data from the API and use custom sorting
#this is a simple example of what that may look like

#Protecting API token - Get your own
$appCenterApi = $env:appcenterapi

$startDate = [System.DateTime]::Now.AddMonths(-3) # "From query parameter has to be less than 90 days old."
$startDate = (Get-Date $startDate -UFormat '+%Y-%m-%dT%H:%M:%S.000Z')
$startDate
$endDate = [System.DateTime]::Now #I'm not using this but you can limit your results
$endDate = (Get-Date $endDate -UFormat '+%Y-%m-%dT%H:%M:%S.000Z')
$endDate
$top = 0  #default is 30 but I want all versions

$owner_name = "Support_Issues" #Replace with Your Owner/org Informaiton
$app_name = "53577900036553" #replace with your App Details

$headers = @{    
    "X-API-Token" = $appCenterApi   
}

$uri = 'https://api.appcenter.ms/v0.1/apps/' + $owner_name + '/' + $app_name + '/analytics/versions?start=' + $startDate + '&%24top=' + $top 
$uri
$versions = Invoke-WebRequest -Uri $uri -Method Get -Headers $headers -ContentType "application/json" | ConvertFrom-Json   
$versions.versions | Sort-Object version -Descending #Implement your custom sorting here
