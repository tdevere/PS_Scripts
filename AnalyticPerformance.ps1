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
    $AppSecret = $env:AppCenterPowerShell
    $InstallID = [Guid]::NewGuid() #'d5cd012b-a97e-483d-8a1f-b67d5b707e64'
}

$Global:id >$null 2>&1
$Global:timestamp >$null 2>&1

$model = "PowerShell Script" #Name Your Application

$headers = @{    
    "App-Secret" = $AppSecret
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

function Send-Event
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

    $sendEventResults = Invoke-WebRequest -Uri $apiUri -Method Post -Body ($json) -Headers $headers -ContentType "application/json" | ConvertFrom-Json 
    Write-Output "Send-Event result $sendEventResults"
    }
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



Start-Session
Send-Event -EventName "POWERSHELL-START"
Send-Event -EventName "POWERSHELL-END"
Write-Host "Sent End Event " $Global:timestamp
Write-Output "End-Event-ID: $Global:id"
Get-LogFlow #Pools until Event is matched

