# Analytic Sample Scripts

### [Click here](/README.md) for a refresher for purpose, prerequisties, and how to get support.

## [Analytic Performance](/Analytics/AnalyticPerformance.ps1)
* Script used to measure analytic performance. 
* We start a session, register our PowerShell Script, then send a start/end event
* After, we ask App Center for the log_flow details and when we see the event id for END, we stop and measure the time of the event and real time
* To use this, replace your Owner and App name to fit your organization. Also, I use a API key stored in system environment variables

## [Analytic Portal Custom Version Sorting](/Analytics/AnalyticPortalCustomVersionSorting.ps1)
* [App Center Analytic Portal](https://docs.microsoft.com/en-us/appcenter/analytics/overview#active-users-per-version) sort uses the name of the version to determine the latest version. This alphabetical sorting may impact
the ability to determine the correct "latest version". 
*  If this is inconvenient you may pull the all version data from the API into JSON results and then use custom sorting.

## [Compare AI to Blob Export data from AppCenter Analytic Data](Analytics/Match_Blob_AI_Export_From_AppCenter_Analytics.ps1)
* Are you concerned that the data from App Center Export is consistent between AI and Blob storage? Using Export Data, we can pull out a list of Blob.CorrelationId and pull out matching values within AI.operation_Id and build a combined view to better understand this relationship.
* This is a work in progress. Needs an update (5/26) - there are limits on what can be done here. Also, there are things you can check to rule out some common scenarios, for example, distinct custom events exceeding 200 daily limits. If this happens, there will be differences in data between App Center and Export (AI/Blob)