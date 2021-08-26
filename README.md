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
* Export of Analytic Data was Disabled - You find your analytics export data was disabled recently. Although you can reenable, you need a way to auto enable if this condition happens or you risk losing Analytic data. Although App Center provides no automatic notification you can use the https://openapi.appcenter.ms/#/export/ExportConfigurations_Get API and query on a schedule to check the status. If it is disabled, you can take restoration action. This script is provide to assist you with this effort. [Auto Renew Disabled Exports in App Center](/ExportConfigNotification.ps1)

## [Generate List of Download Links to Each App Release](/GetAllReleaseDownloadLinks.ps1)
* On occasion the install.appcenter.ms portal may not display releases is a useful way. Some views my prevent you from finding the downoload link for a particular release. This script will help you discover the download link for all available releases.
