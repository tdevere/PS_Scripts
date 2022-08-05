Clear-Host

### LOG FLOW PERFORMANCE TEST

$APIKey = $env:appcenterapi #Plug your own in here
$OwnerName = "Examples" #Plug your own in here
$App_Name = "Android_Xamarin" #Plug your own in here
$apiUri = "https://in.appcenter.ms/logs?api-version=1.0.0"
$sid = [Guid]::NewGuid() #This is the identifier for the new session. Just keeps this unique. It will be used to pull out only relevant data from logflow
$AppSecret = "43448a3c-1a36-493e-bdc0-4eefed484e19"#$env:AppCenterPowerShell #Plug your own in here
$InstallID = [Guid]::NewGuid() #'d5cd012b-a97e-483d-8a1f-b67d5b707e64'
$Global:id >$null 2>&1
$Global:date

$headers = @{    
    "App-Secret" = $AppSecret
    "Install-ID" = $InstallID
}

function ReturnAppCenterDateFormation
{
    return Get-Date -UFormat '+%Y-%m-%dT%H:%M:%S.000Z'
}

function Start-Session
{
    $Global:date = ReturnAppCenterDateFormation
    
    Write-Host "Start_Session_ID=$sid; Date=$Global:date"

$json = 
@"
{
    "logs": [
        {
            "type": "startSession",
            "timestamp": "$Global:date",
            "sid": "$sid",
            "device": {
              "wrapperSdkVersion": "4.2.0",
              "wrapperSdkName": "appcenter.xamarin",
              "wrapperRuntimeVersion": "12.3.3.3",
              "sdkName": "appcenter.android",
              "sdkVersion": "4.1.1",
              "model": "sdk_gphone64_x86_64",
              "oemName": "Google",
              "osName": "Android",
              "osVersion": "12",
              "osBuild": "SE1A.211012.001",
              "osApiLevel": 31,
              "locale": "en_US",
              "timeZoneOffset": -300,
              "screenSize": "1080x2208",
              "appVersion": "1.2",
              "carrierName": "T-Mobile",
              "carrierCountry": "us",
              "appBuild": "22",
              "appNamespace": "com.companyname.AndroidXamarin.tdevere"
            }
        }
    ]
}
"@
    
    $startSession = Invoke-WebRequest -Uri $apiUri -Method Post -Body ($json) -Headers $headers -ContentType "application/json" | ConvertFrom-Json  
    Write-Output "Start-Session result $startSession.status"
}


function Measure-LogFLowPerformance
{
    Param([int]$loopCount=10, [int]$delayInMilliseconds=5000) #end param
    $LogFlowURI = "https://api.appcenter.ms/v0.1/apps/$OwnerName/$App_Name/analytics/log_flow"

    $headers = @{    
        "X-API-Token" = "$APIKey"
        "Accept" = "application/json"
    }
   
    Write-Host "Measure-LogFLowPerformance Start"
    $a = 0 #Counter
    DO
    {
        $results = Invoke-WebRequest -Uri $LogFlowURI -Method Get -Headers $headers -ContentType "application/json" | ConvertFrom-Json

        if ($results.logs.Count -ge 1)
        {
            $MatchedLog = $results.logs | Where-Object { $_.session_id -eq $sid }

            if ($null -ne $MatchedLog)
            {
                $currentTime = ReturnAppCenterDateFormation
                Write-Host ([System.string]::Format("Session Matched: {0}",  $MatchedLog.session_id))               
                $TotallTimeDiff = New-TimeSpan -Start $Global:date -End $currentTime
                Write-Host ([System.string]::Format("TestStartTime: {0} - IngressTime {1} - LogFlowReceivedTime {2}", $Global:date, $MatchedLog.timestamp, $currentTime))    
                Write-Host "TOTAL TIME DIFF (h/m/s) = $TotallTimeDiff"        
                break
            }
        }

        $a++
        [System.Threading.Thread]::Sleep($delayInMilliseconds)

    } Until ($a -eq $loopCount)

    Write-Host "Measure-LogFLowPerformance Exit"
}

Start-Session               #Start the Sesssion
Measure-LogFLowPerformance  #Monitor the LogFlow

