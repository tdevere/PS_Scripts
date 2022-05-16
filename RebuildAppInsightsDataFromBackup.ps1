Clear-Host

### Script used to measure analytic performance. 
### We start a session, register our PowerShell Script, then send a start/end event
### After, we ask App Center for the log_flow details and when we see the event id for END, we stop and measure the time of the event and real time
### To use this, replace your Owner and App name to fit your organization. Also, I use a API key stored  in system environment variables

$firstRun = $true

if ($firstRun)
{
    $apiUri = "https://in.appcenter.ms/logs?api-version=1.0.0"
    $sid = [Guid]::NewGuid() #This is the identifier for the new sessions
    $AppSecret = "549c3db4-f00b-434b-8c66-24f7c340c920" #https://appcenter.ms/orgs/Examples/apps/ThreeAmigos_Android
    $InstallID = 'f2f23826-266b-4a34-8a99-f27be9d26f53' #[Guid]::NewGuid() #'f2f23826-266b-4a34-8a99-f27be9d26f53' Static GUID for RebuildOperations
}

$Global:id >$null 2>&1
$Global:timestamp >$null 2>&1

$model = "PowerShell Script" #Name Your Application

$headers = @{    
    "App-Secret" = "549c3db4-f00b-434b-8c66-24f7c340c920" #Not the API Token
    "Install-ID" = $InstallID
}

function Start-Session
{

    $date = Get-Date -UFormat '+%Y-%m-%dT%H:%M:%S.000Z'

$json = 
@"
{
    "logs": [
        {
            "timestamp": "$date",
            "sid": "$sid",
            "device": {
              "sdkName": "appcenter.winforms",
              "sdkVersion": "4.2.0",
              "model": "$model",
              "oemName": "HP",
              "osName": "WINDOWS",
              "osVersion": "10.0.19042",
              "osBuild": "10.0.19042.928",
              "locale": "en-US",
              "timeZoneOffset": -360,
              "screenSize": "3440x1440",
              "appVersion": "1.0.0.0",
              "appBuild": "1.0.0.0",
              "appNamespace": "AppCenter_WinForm"
            },
            "type": "startSession"
        }
        ]
}
"@
    
    $startSession = Invoke-WebRequest -Uri $apiUri -Method Post -Body ($json) -Headers $headers -ContentType "application/json" | ConvertFrom-Json  
    Write-Output "Start-Session result $startSession.status"

}

function Send-Event-Old
{
    Param([string]$EventName) #end param

    if ($EventName -ne "")
    {   
        $id = [Guid]::NewGuid()
        $Global:id = $id
        $Global:timestamp = Get-Date -UFormat '+%Y-%m-%dT%H:%M:%S.000Z'
            $timestamp = $Global:timestamp
$json = 
@"
{
    "logs": [
        {
            "id": "$id",
            "name": "$EventName",
            "timestamp": "$timestamp",
            "sid": "$sid ",
            "device": {
              "sdkName": "appcenter.winforms",
              "sdkVersion": "4.2.0",
              "model": "$model",
              "oemName": "HP",
              "osName": "WINDOWS",
              "osVersion": "10.0.19042",
              "osBuild": "10.0.19042.928",
              "locale": "en-US",
              "timeZoneOffset": -360,
              "screenSize": "3440x1440",
              "appVersion": "1.0.0.0",
              "appBuild": "1.0.0.0",
              "appNamespace": "AppCenter_WinForm"
            },
            "type": "event"
          }
        ]
}
"@


    Invoke-WebRequest -Uri $apiUri -Method Post -Body ($json) -Headers $headers -ContentType "application/json" -Proxy 'http://127.0.0.1:8888' | ConvertFrom-Json 
    #$sendEventResults = Invoke-WebRequest -Uri $apiUri -Method Post -Body ($json) -Headers $headers -ContentType "application/json" | ConvertFrom-Json 
    #Write-Output "Send-Event result $sendEventResults"
    }
}

function Send-Event
{
    Param($EventData)

    #($EventData | ConvertTo-Json)

    Invoke-WebRequest -Uri $apiUri -Method Post -Body ($EventData | ConvertTo-Json) -Headers $headers -ContentType "application/json" -Proxy 'http://127.0.0.1:8888' | ConvertFrom-Json 
    #$sendEventResults = Invoke-WebRequest -Uri $apiUri -Method Post -Body ($json) -Headers $headers -ContentType "application/json" | ConvertFrom-Json 
    #Write-Output "Send-Event result $sendEventResults"
    
}

function Get-LogFlow
{
    Write-Host "Begining Event Lookup"

    $APIKey = $env:appcenterapi
    $OwnerName = "Examples"
    $App_Name = "PowerShell"
    $LogFlowURI = "https://api.appcenter.ms/v0.1/apps/$OwnerName/$App_Name/analytics/log_flow"

    $headers = @{    
        "X-API-Token" = "$APIKey"
        "Accept" = "application/json"
    }

    $a = 0
    $bContinue = $true
    
    DO
    {
        $results = Invoke-WebRequest -Uri $LogFlowURI -Method Get -Headers $headers -ContentType "application/json" | ConvertFrom-Json
        
        Write-Host ([System.string]::Format("Results Count: {0}" , $results.logs.Count))

        foreach ($log in $results.logs) 
        {
            if ($sid -eq $log.session_id)
            {
                                if ($Global:id -eq $log.id)
                {
                    if ($log.name -eq "POWERSHELL-END")
                    {
                        Write-Host ([System.string]::Format("Session Match: {0}", $log.session_id))
                        Write-Host ([System.string]::Format("ID Match: {0}", $log.id))
                        $t = $log.timestamp | Get-Date -UFormat '+%Y-%m-%dT%H:%M:%S.000Z'
                        Write-Host ([System.string]::Format("Name Match: {0} Time: {1}" , $log.name, $t)) 
                        $diff = New-TimeSpan -Start $Global:timestamp -End $t          
                        Write-Output "Analytic Performance / Time Difference: $diff"                       
                        $diff = New-TimeSpan -Start $Global:timestamp -End (Get-Date -UFormat '+%Y-%m-%dT%H:%M:%S.000Z')
                        Write-Output "Real Time Difference From Now: $diff"   
                        $bContinue = $false
                    }
                }
            }

            if (-not($bContinue))
            {
                break
            }            
        }

        if (-not($bContinue))
        {
            break
        }

        $a++
        [System.Threading.Thread]::Sleep(5000)

    } Until ($a -eq 10)

    

    Write-Host "Event Lookup Exit"
}


function Get-AIData
{
    Param([string]$EventName) #end param

}


#$aiFilePath = 'C:\temp\AI_Export.csv'
#$AIRaw = Import-Csv $aiFilePath
#$customDimensionsList = $AIRaw | Select-Object customDimensions
#Send-Event ($AIRaw | Select-Object -First 1 | ConvertTo-Json)
$sampleJson = Get-Content 'C:\temp\sample3.json' | ConvertFrom-Json

$sampleJson = 
@"
{
	"logs": [
		{
			"id": "82651e57-7dbe-4f0f-9de6-4bd066ec7483",
			"name": "SAMPLE",
			"properties": {
				"UserId": "tdevere",
				"0": "Zero",
				"1": "One",
				"2": "Two",
				"3": "Three",
				"4": "Boom"
			},
			"timestamp": "2022-04-13T00:36:35.6656794Z",
			"device": {
				"sdkName": "appcenter.uwp",
				"sdkVersion": "4.4.0",
				"model": "HP Z230 Tower Workstation",
				"oemName": "Hewlett-Packard",
				"osName": "WINDOWS",
				"osVersion": "10.0.19044",
				"osBuild": "10.0.19044.1586",
				"locale": "en-US",
				"timeZoneOffset": -360,
				"screenSize": "2560x1440",
				"appVersion": "1.0.0.0",
				"appBuild": "1.0.0.0",
				"appNamespace": "a09e14ce-766e-4ebc-b476-cdf8cd64d293"
			},
			"type": "event"
		}
	]
}
"@

Send-Event-Old "Old Event"
Send-Event ($sampleJson | ConvertFrom-Json)
#Send-Event ($sampleJson | ConvertTo-Json)
#Send-Event ($AIRaw | Select-Object -First 1 | ConvertTo-Json)
#$customDimensionsList | ForEach-Object { Send-Event $_ }