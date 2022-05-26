# PowerShell_Scripts - App Center Samples

## Purpose and Prerequisites
This repo is a collection of scripts developed for specific customer situations which might be benefical to others facing the same issues. Take a look at [PowerShell](https://docs.microsoft.com/en-us/powershell/) and [App Center Open API](https://openapi.appcenter.ms/#/account), if you are unfamilar with these subjects. Also, each script requires that you have access to an [App Center API Token](https://docs.microsoft.com/en-us/appcenter/api-docs/#creating-an-app-center-app-api-token) along with basic details like Owner and App Name. Finally, if you plan on using the Azure related samples, you'll clearly need an Azure subscription to work out these samples. 

## Support 
The scripts found here no doubt could be improved, so please make recommendations and we'll work to get these incorporated where it makes sense. None of these are offically supported solutions via App Center. However, if you run into general issues that simply need review, I'll be happy to help - just open a bug and I'll get to this as fast as I can. 

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
* To Automate this script to run every minute, take a look at [the following Sample](/AzureFunctions/RemoveUnauthorizedUsers/readme.md) which uses an Azure Function Proxy triggered by a timer, and removes unauthorized users from your Organization.

## [Is Repo Connection Valid](/IsRepoConnectionValid.ps1)
* If you use App Center for build services, occassionally your repo connection may become invalid. At that time, you cannot view build configuration or branch information from the App Center portal. You will see a reconnection notice banner and an error indicating there was an error loading branches. Typically you find this after learning of a build failure. If you wanted to get an early warning, try scheduling a azure function app using this sample and setup your own notification process when a connection goes down for any reason.

## [Your Apple Store Credentials are no longer valid. Please re-authenticate](/ServiceConnection.ps1)
* Apple Store connections are set to expire (policy enforced by Apple) about every 30 days. When this happens, the original App Center account which configured the store connection must be available and ready to respond to reconnect request. MFA is also no required (policy enforced by Apple) and therefore, this account must also be able to fullfill the MFA request at the same time. 
* What happens if they are not available? Your options are limited.
    * If you replace the connection, you lose build history and configurations - forever. This is not recoverable and most often not preferred.
    * You might open a support case with App Center support and request the connection be replaced with the credentials of another App Center user, who has access to utilize the store connection and administer the connection via App Center. This is a good option but it takes time for support to process the request.
    * Avoid the situation altogether - this is the best option. To that end, to prevent this situation completely, you will want to manage the lifecycle of the connection. To that end, please consider the following approach
* Avoidance - not great for relationships but useful in managing not so great CI/CD process out of our control...
    * Get the existing expiration date using the script found in this section
    * This gets you the expiration for the token. You can use this to automate some notification, or configure a reminder for responsible parties to be available to make the reconnection attempt. 
    * If waiting to find the problem is a concern (taking too long) consider using the [Is Repo Connection Valid](/IsRepoConnectionValid.ps1) found in this repo. If the connection is faulted, you can automate a notification process and signal the correct team to update the connection. 
    * Create a generic App Center account which also has access to utilize the store connection and administer the App Center Org/Apps using the connection. This account should be accessible to a team of people who can also respond to the MFA request associated with the reconnection effort. 
