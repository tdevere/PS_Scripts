# Productivity and Administration Sample Scripts

``` [Click here](https://vscode.dev/github/tdevere/PS_Scripts/blob/d051f7cab10b856ef77c191a163fe1f28ce55dd8/README.md#L1) for a refresher for purpose, prerequisties, and how to get support. ```


## [Your Apple Store Credentials are no longer valid. Please re-authenticate](/Productivity_Administration/ServiceConnection.ps1)
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

## [Is Repo Connection Valid](/Productivity_Administration/IsRepoConnectionValid.ps1)
* If you use App Center for build services, occassionally your repo connection may become invalid. At that time, you cannot view build configuration or branch information from the App Center portal. You will see a reconnection notice banner and an error indicating there was an error loading branches. Typically you find this after learning of a build failure. If you wanted to get an early warning, try scheduling a azure function app using this sample and setup your own notification process when a connection goes down for any reason.

## [Validate Organization Members Email](/Productivity_Administration/Membership_Security.ps1)
* As of 3/21/2022 App Center does not provide security features such as account membership restriction based on Identity Provider or email domain restrictions. This script demonstrates how to query the Organization members and evaluate if their account was created using an email which resided within their respective domain/identity provider.
* To Automate this script to run every minute, take a look at [the following Sample](/AzureFunctions/RemoveUnauthorizedUsers/readme.md) which uses an Azure Function Proxy triggered by a timer, and removes unauthorized users from your Organization.

## [Send Invitations to Distribution Group in Bulk](/Productivity_Administration/BulkEmailSubscription.ps1)
* If you have 100's or more testers to add to a distribution group, the web portal for App Center may block bulk add operations with an error like “Too many request”
* Use a script to more efficiently add accounts to distribution groups
    * Lacks true bulk operations; currently only iterates over a list
    * Lack any exception handling; may be difficult if some operations fail; should put in a retry list