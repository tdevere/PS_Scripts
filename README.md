# PowerShell_Scripts

## [Analytic Performance](/AnalyticPerformance.ps1)
* Script used to measure analytic performance. 
* We start a session, register our PowerShell Script, then send a start/end event
* After, we ask App Center for the log_flow details and when we see the event id for END, we stop and measure the time of the event and real time
* To use this, replace your Owner and App name to fit your organization. Also, I use a API key stored  in system environment variables

## [Analytic Portal Custom Version Sorting](/AnalyticPortalCustomVersionSorting.ps1)
* [App Center Analytic Portal](https://docs.microsoft.com/en-us/appcenter/analytics/overview#active-users-per-version) sort uses the name of the version to determine the latest version. This alphabetical sorting may impact
the ability to determine the correct "latest version". 
*  If this is inconvenient you may pull the all version data from the API into JSON results and then use custom sorting.

## [Send Invitations to Distribution Group in Bulk](/BulkEmailSubscription.ps1)
* If you have 100's or more testers to add to a distribution group, the web portal for App Center may block bulk add operations wiht an error like “Too many request”
* Use a script to more efficiently add accounts to distribution groups
    * Lacks true bulk operations; currently only iterates over a list
    * Lack any exception handling; may be difficult if some operations fail; should put in a rety list

## [Auto Renew Disabled Exports in App Center](/ExportConfigNotification.ps1)
* Export of Analytic Data was Disabled - You find your analytics export data was disabled recently. Although you can reenable, these questions remain:
1. Why/Who disabled export? 
2. Can export data be restored while it was not enabled?
3. What options exist to be notified if this situation happens again? 

* Why/Who disabled analytics export?
There are two sources for disabling analytic export: user or azure driven. If App Center receives some types of failures from Azure, we may automatically disable export. This happens without notification. Otherwise, only an App Center User would disable analytics. 
* Can the missing data be restored?
** Data going to App Insights will only stay around for 48 hours. 
** If the export is reenabled within that time, data will flow with the backup. 
** Anything past 48 hours is lost • Data going to blob has 30 days 
** If the export is reenabled within that time, data will flow with the backup ○ Anything past 30 days is lost

* What options exist to be notified?
** There is no automatic notification. However, you can use the https://openapi.appcenter.ms/#/export/ExportConfigurations_Get API and query on a schedule to check the status. If it is disabled, you can take restoration action. This script is provide to assist you with this effort. [Auto Renew Disabled Exports in App Center](/ExportConfigNotification.ps1)
