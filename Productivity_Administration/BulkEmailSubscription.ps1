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
$UseBulkProcessing = $true #Send mulitple emails at the same time
$bulkBuffer = 10 #Not sure what the limit is on ingestion side 
$FinalEmailList = New-Object 'Collections.Generic.List[string]'

function GenerateSampleEmails {
    #Otherwise, supply your own values; this is for sample purposes only
    for ($i = 1; $i -le 13; $i++)
    {
        $invitationList.Add("$baseEmail+$i@gmail.com")        
    }
}

function GetBatchRange
{
    #Method to create string of emails for batch invite
    Param(
            [Parameter(Mandatory = $true, HelpMessage="Send string list")]
            [ValidateNotNullOrEmpty()]
            [string[]] $range
        )

        $range

        if ($range.Count -gt 0)
        {
            $batches = New-Object 'System.Text.StringBuilder'

            $counter = 1
            foreach ($email in $range)
            {   
                $email

                if ($counter -eq $range.Count)
                {                    
                    $batches.Append('\"' + $email + '\"')
                }
                else
                {
                    $batches.Append('\"' + $email + '\",')
                }
                
                $counter++
            }

            $FinalEmailList.Add($batches.ToString())
            $FinalEmailList
        }

        
        
}

GenerateSampleEmails #Enabled for sample only;

#https://openapi.appcenter.ms/#/account/distributionGroups_addUser
#Adds the members to the specified distribution group
# Example

$curlUrl = 'https://api.appcenter.ms/v0.1/apps/' + $owner_name + '/' + $app_name + '/distribution_groups/' + $distribution_group + '/members'


if ($UseBulkProcessing)
{
    $bulkEmailList = New-Object 'Collections.Generic.List[string]'    
    $startCount = $invitationList.Count    
    $wholePart = [System.Math]::Truncate(($startCount / $bulkBuffer))
    $remainder = ($startCount % $bulkBuffer)

    $rangeRemainder = $invitationList.GetRange(0, $remainder) #grab the remainder first in bulk
    foreach ($r in $rangeRemainder)
    {
        $r
        GetBatchRange -range $r
    }
    
    $startIndex = $remainder
    for ($i = 1; $i -le $wholePart; $i++) #stop when we hit that number
    {
        Write-Host $startIndex":"$bulkBuffer
        $wholeRemainder = $invitationList.GetRange($startIndex, $bulkBuffer)
        Write-Host "Whole Remainder: " $wholeRemainder.Count
        GetBatchRange -range $wholeRemainder
        $startIndex = $startIndex+$bulkBuffer  #incrmenet count by $bulkBuffer
    }

    foreach ($email in $FinalEmailList)
    {     
        $emailList = '"{\"user_emails\":[' + $email + ']}"' #| ConvertFrom-Json
        $emailList    
        $curlUrl
        curl -X POST $curlUrl -H "Content-Type: application/json" -H "accept: application/json" -H "X-API-Token: $appCenterApi" -d $emailList
    }
}
else 
{
    #use 1 x 1 method of invite
    foreach ($email in $invitationList)
    {     
        $emailList = '"{\"user_emails\":[\"' + $email + '\"]}' #| ConvertFrom-Json
        $emailList    
        $curlUrl
        curl -X POST $curlUrl -H "Content-Type: application/json" -H "accept: application/json" -H "X-API-Token: $appCenterApi" -d $emailList
    }
}


