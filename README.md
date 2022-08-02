[[_TOC_]]

# PowerShell_Scripts - App Center Samples

## Purpose and Prerequisites

Here you will find a collection of scripts developed for customer situations which might be benefical to others facing the similar concerns. 

Review [PowerShell](https://docs.microsoft.com/en-us/powershell/) and [App Center Open API](https://openapi.appcenter.ms/#/account), if you are unfamilar with these subjects - both are prequisets for using these scripts. 

Also, each script requires that you have access to an [App Center API Token](https://docs.microsoft.com/en-us/appcenter/api-docs/#creating-an-app-center-app-api-token) along with basic details like Owner and App Name. Finally, if you plan on using the Azure related samples, you'll clearly need an Azure subscription to work out these samples. 

## Support Information
The scripts found here no doubt could be improved, so please make recommendations and we'll work to get these incorporated where it makes sense. None of these are offically supported solutions via App Center. However, if you run into general issues that simply need review, I'll be happy to help - just open a bug and I'll get to this as fast as I can.

## Script Index

<details>

  <summary>Analytics</summary>

# [Analytics Scripts](/Analytics/Readme.md)
  
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

</details>

<details>

  <summary>Build</summary>
  
## [Build Scripts](/Build/Readme.md)

## [Auto Renew Disabled Exports in App Center](/Build/ExportConfigNotification.ps1)
* Export of Analytic Data was Disabled - You find your analytics export data was disabled recently. Although you can reenable, you need a way to auto enable if this condition happens or you risk losing Analytic data. Although App Center provides no automatic notification you can use the https://openapi.appcenter.ms/#/export/ExportConfigurations_Get API and query on a schedule to check the status. If it is disabled, you can take restoration action. This script is provided to assist you with this effort. [Auto Renew Disabled Exports in App Center](/ExportConfigNotification.ps1)
* 10/2/2021 - App Center has a known issue which is yet to be fixed. When the automatic disable event occurs, re-enabling export does not backfill data as the documentation suggests happens when you initially setup export. The only way as of today to get backfill data, is to delete the export and then create the export again. ``` Warning there is no system in place to prevent duplicate data if you restore the connection to the same App Insights Instance or Blob Storage account. ``` 
* If you are using this script or similar approach, you are less impacted as the only data lost would be between the time the export was disabled and when the script enables export again. 

## [Clone Branch Confiruation](/Build/CloneBranchBuildConfig.ps1)
* Perhaps you need to modify the branch configuration for a large number of Apps. The portal is not the best tool for this job. Instead, check out this script for an example on how to:
    1. Clone an existing branch
    2. Set a branch configuration on a new branch

</details>

<details>

  <summary>Distribution</summary>

# [Distribution Scripts](/Distribution/Readme.md)

## [Get List of Distribution Group Members](/Distribution/GetDistributionGroupMembers.ps11)
* Sample script showing how to Get List of Distribution Group Members

## [Generate List of Download Links to Each App Release](/Distribution/GetAllReleaseDownloadLinks.ps1)
* On occasion the install.appcenter.ms portal may not display releases is a useful way. Some views my prevent you from finding the download link for a particular release. This script will help you discover the download link for all available releases.

## [Disable Old Releases](/Distribution/DisableOldReleases.ps1)
* As releases pile up you may begin to notice timeouts when accessing the install.appcenter.ms portal. There is no pagination when pulling results for releases in AppCenter, therefore some odd behavior can pop up when you begin to have a large result set from this data. One workaround to this behavior would be to disable older releases.

</details>

<details>

<summary> Productivity and Administration </summary>

## [Productivity and Administration](/Productivity_Administration/Readme.md)

## [Your Apple Store Credentials are no longer valid. Please re-authenticate](/Productivity_Administration/ServiceConnection.ps1)
* Apple Store connections are set to expire (policy enforced by Apple) about every 30 days. When this happens, the original App Center account which configured the store connection must be available and ready to respond to reconnect request. MFA is also no required (policy enforced by Apple) and therefore, this account must also be able to fullfill the MFA request at the same time.
 
### Recommendation: Prepare A Plan Before the Situation Occurs
* [Create a generic App Center account](https://docs.microsoft.com/en-us/appcenter/general/account) 
   * Account needs access to utilize the store connection and administer the App Center Org/Apps using the connection. 
   * This account should be accessible to a team of people who can also respond to the MFA request associated with the reconnection effort. 
* [Monitor Repo Connection State](/Productivity_Administration/IsRepoConnectionValid.ps1)
   * Notify responsible parties early on when the connection state is failed. Do this rather than wait for your build team to notify you when builds/distribution begins to fail. 
* [Pre-Notify Team of Expiring Connection](/Productivity_Administration/ServiceConnection.ps1)
* Schedule maintainance window with knowledge of the token expiration date. It's possible the token gets exipired before hand but otherwise, you'll be ready on the date of the expiration.

### FAQ - Your Apple Store Credentials are no longer valid
* Can I have multiple trusted devices associated with one Apple ID?
   * ``` Yes. You can sign in to multiple devices with your developer Apple ID using two-factor authentication. ```
* Can I have multiple trusted phone numbers associated with one Apple ID?
   *  ``` Yes. You can manage your trusted phone numbers, trusted devices, and other account information on your Apple ID account page. You can also manage your trusted phone numbers in the Apple ID security setting on your trusted devices. ```
* Can I use the same trusted phone number for multiple Apple IDs?
   *  ``` Yes. You can assign the same trusted phone number to multiple Apple IDs that you use. ```

### References:
* [Apple provides a mechanism to generate and validate tokens](https://developer.apple.com/documentation/sign_in_with_apple/generate_and_validate_tokens)
* [Apple Token Expiration](https://developer.apple.com/support/authentication) 

## [Get List of Testers](/Productivity_Administration/GetAllTesters.ps1)
* Sample script showing how to get a list of all testers

## [Get List of Pending Invites](/Productivity_Administration/GetPendingInvites.ps1)
* Sample script showing how to Get List of Pending Invites

## [Is Repo Connection Valid](/Productivity_Administration/IsRepoConnectionValid.ps1)
* If you use App Center for build services, occassionally your repo connection may become invalid. At that time, you cannot view build configuration or branch information from the App Center portal. You will see a reconnection notice banner and an error indicating there was an error loading branches. Typically you find this after learning of a build failure. If you wanted to get an early warning, try scheduling a azure function app using this sample and setup your own notification process when a connection goes down for any reason.

</details>

<details>
<summary>Org, App, and Team Email Administration</summary>

App Center has a number of missing features regarding management of collaborators. 

1. No Domain Restriction/Validation - we cannot limit the user to a specific domain.
2. AAD Group membership applies to distributions groups alone. We do not support using AAD Groups for App Collaborators. However, unless the AAD group memebers are individually added to the group, they may not see availble releases. In generall, this feature doesn't work as you might expect or hope.  ``` [As of 8/1/2022]```
3. The Portal behaves oddly if you have a bulk set of emails to add. 

The following scripts may be useful to you when working with collaborators. 

## [Validate Organization Members Email](/Productivity_Administration/Membership_Security.ps1)
* ``` [As of 3/21/2022] ``` App Center does not provide security features such as account membership restriction based on Identity Provider or email domain restrictions. This script demonstrates how to query the Organization members and evaluate if their account was created using an email which resided within their respective domain/identity provider.
* To Automate this script to run every minute, take a look at [the following Sample](/Azure/AzureFunctions/RemoveUnauthorizedUsers/readme.md) which uses an Azure Function Proxy triggered by a timer, and removes unauthorized users from your Organization.

## [Send Invitations to Distribution Group in Bulk](/Productivity_Administration/BulkEmailSubscription.ps1)
* If you have 100's or more testers to add to a distribution group, the web portal for App Center may block bulk add operations with an error like “Too many request”
* Use a script to more efficiently add accounts to distribution groups
    * Lacks true bulk operations; currently only iterates over a list
    * Lack any exception handling; may be difficult if some operations fail; should put in a retry list

## [Add New Collaborator to Organization](/Productivity_Administration/AddNewCollaborator.ps1)
* App Center does not currently support adding AAD Groups at the organization level see [Extend AAD groups support to Org level #448](https://github.com/microsoft/appcenter/issues/448)
* User this script along with [Send Invitations to Distribution Group in Bulk](/Productivity_Administration/BulkEmailSubscription.ps1) to add new users to your App Center Organization

## [Add New Member to an App Center Team](/Productivity_Administration/AddNewTeamMember.ps1)
* See [Add New Collaborator to Organization](/Productivity_Administration/AddNewCollaborator.ps1) - this is an example only

</details>
