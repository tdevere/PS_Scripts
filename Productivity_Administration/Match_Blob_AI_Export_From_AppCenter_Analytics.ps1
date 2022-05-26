#Match AI and Blob Export Data AppCenter
Clear-Host

$RunOnce =  $true #$false #     # Initial Setup

if ($RunOnce)
{             
    $blobFilePath = '' #use the raw data
    $aiFilePath = '' #use the .CSV export (if not this script won't work)
    $BlobRaw = Get-Content $blobFilePath | ConvertFrom-Json #script won't work if you don't convert from json or if this step fails
    $AIRaw = Import-Csv $aiFilePath
}

Function MatchDataParallel
{
    #This method is not as performant as the serial method; not entirelly sure why   
    $BloblAICompareTable = New-Object 'Collections.Generic.List[PSCustomObject]'
    
    $AIRaw | ForEach-Object -Parallel {        
        $stopwatch = [System.Diagnostics.Stopwatch]::startNew();       
        $AIOperationId = $_.operation_Id        
        $BlobMatch = $using:BlobRaw | Where-Object { $_.CorrelationId -eq $AIOperationId }

        if ($BlobMatch.Length -le 0)
        {   #AI Operation ID Not found in Blob Export
            
            $NewResultsObject = New-Object -TypeName psobject -Property @{
                MatchStatus = $false; 
                AI_OperationId = $AIOperationId;
                Blobl_CorrelationId = $null;
                BlobMatch = $null;
                AIMatch = $_
            }

            ($using:BloblAICompareTable).Add($NewResultsObject)
        }
        else
        {#AI Operation ID WAS found in Blob Export    
            
            $NewResultsObject = New-Object -TypeName psobject -Property @{
                MatchStatus = $true; 
                AI_OperationId = $AIOperationId;
                Blobl_CorrelationId = $BlobMatch.CorrelationId;
                BlobMatch = $BlobMatch;
                AIMatch = $_                
            }
            ($using:BloblAICompareTable).Add($NewResultsObject)
        }
        
        if ((($using:BloblAICompareTable).Count % 100) -eq 0) 
        { 
            Write-Host ($using:BloblAICompareTable).Count ":" $stopwatch.Elapsed.Milliseconds -ForegroundColor Green 
        }
    }

    Write-Host "Completed: " $stopwatch.Elapsed -ForegroundColor Red
    return $BloblAICompareTable
}

Function MatchData
{   
    $BloblAICompareTable = New-Object 'Collections.Generic.List[PSCustomObject]'
    
    $AIRaw | ForEach-Object {        
        $stopwatch = [System.Diagnostics.Stopwatch]::startNew();       
        $AIOperationId = $_.operation_Id        
        $BlobMatch = $BlobRaw | Where-Object { $_.CorrelationId -eq $AIOperationId }

        if ($BlobMatch.Length -le 0)
        {   #AI Operation ID Not found in Blob Export
            
            $NewResultsObject = New-Object -TypeName psobject -Property @{
                MatchStatus = $false; 
                AI_OperationId = $AIOperationId;
                Blobl_CorrelationId = $null;
                BlobMatch = $null;
                AIMatch = $_
            }

            ($BloblAICompareTable).Add($NewResultsObject)
        }
        else
        {#AI Operation ID WAS found in Blob Export    
            
            $NewResultsObject = New-Object -TypeName psobject -Property @{
                MatchStatus = $true; 
                AI_OperationId = $AIOperationId;
                Blobl_CorrelationId = $BlobMatch.CorrelationId;
                BlobMatch = $BlobMatch;
                AIMatch = $_                
            }
            ($BloblAICompareTable).Add($NewResultsObject)
        }
        
        if ((($BloblAICompareTable).Count % 100) -eq 0) 
        { 
            Write-Host ($BloblAICompareTable).Count ":" $stopwatch.Elapsed.Milliseconds -ForegroundColor Green 
        }
    }

    Write-Host "Completed: " $stopwatch.Elapsed -ForegroundColor Red
    return $BloblAICompareTable
}

MatchData