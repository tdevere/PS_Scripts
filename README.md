# PowerShell_Scripts

## [Analytic Performance](/AnalyticPerformance.ps1)
* Script used to measure analytic performance. 
* We start a session, register our PowerShell Script, then send a start/end event
* After, we ask App Center for the log_flow details and when we see the event id for END, we stop and measure the time of the event and real time
* To use this, replace your Owner and App name to fit your organization. Also, I use a API key stored in system environment variables

## [Analytic Portal Custom Version Sorting](/AnalyticPortalCustomVersionSorting.ps1)
* [App Center Analytic Portal](https://docs.microsoft.com/en-us/appcenter/analytics/overview#active-users-per-version) sort uses the name of the version to determine the latest version. This alphabetical sorting may impact
the ability to determine the correct "latest version". 
*  If this is inconvenient you may pull the all version data from the API into JSON results and then use custom sorting.

## [Send Invitations to Distribution Group in Bulk](/BulkEmailSubscription.ps1)
* If you have 100's or more testers to add to a distribution group, the web portal for App Center may block bulk add operations with an error like “Too many request”
* Use a script to more efficiently add accounts to distribution groups
    * Lacks true bulk operations; currently only iterates over a list
    * Lack any exception handling; may be difficult if some operations fail; should put in a retry list

## [Auto Renew Disabled Exports in App Center](/ExportConfigNotification.ps1)
* Export of Analytic Data was Disabled - You find your analytics export data was disabled recently. Although you can reenable, you need a way to auto enable if this condition happens or you risk losing Analytic data. Although App Center provides no automatic notification you can use the https://openapi.appcenter.ms/#/export/ExportConfigurations_Get API and query on a schedule to check the status. If it is disabled, you can take restoration action. This script is provided to assist you with this effort. [Auto Renew Disabled Exports in App Center](/ExportConfigNotification.ps1)
* 10/2/2021 - App Center has a known issue which is yet to be fixed. When the automatic disable event occurs, re-enabling export does not backfill data as the documentation suggests happens when you initially setup export. The only way as of today to get backfill data, is to delete the export and then create the export again. ``` Warning there is no system in place to prevent duplicate data if you restore the connection to the same App Insights Instance or Blob Storage account. ``` 
* If you are using this script or similar approach, you are less impacted as the only data lost would be between the time the export was disabled and when the script enables export again. 

## [Generate List of Download Links to Each App Release](/GetAllReleaseDownloadLinks.ps1)
* On occasion the install.appcenter.ms portal may not display releases is a useful way. Some views my prevent you from finding the download link for a particular release. This script will help you discover the download link for all available releases.

## [Clone Branch Confiruation](/CloneBranchBuildConfig.ps1)
* Perhaps you need to modify the branch configuration for a large number of Apps. The portal is not the best tool for this job. Instead, check out this script for an example on how to:
    1. Clone an existing branch
    2. Set a branch configuration on a new branch

## [Disable Old Releases](/DisableOldReleases.ps1)
* As releases pile up you may begin to notice timeouts when accessing the install.appcenter.ms portal. There is no pagination when pulling results for releases in AppCenter, therefore some odd behavior can pop up when you begin to have a large result set from this data. One workaround to this behavior would be to disable older releases. 

## [Compare AI to Blob Export data from AppCenter Analytic Data](/Match_Blob_AI_Export_From_AppCenter_Analytics.ps1)
* Are you concerned that the data from App Center Export is consistent between AI and Blob storage? Using Export Data, we can pull out a list of Blob.CorrelationId and pull out matching values within AI.operation_Id and build a combined view to better understand this relationship.

## [Validate Organization Members Email](/Membership_Security.ps1)
* As of 3/21/2022 App Center does not provide security features such as account membership restriction based on Identity Provider or email domain restrictions. This script demonstrates how to query the Organization members and evaluate if their account was created using an email which resided within their respective domain/identity provider. 