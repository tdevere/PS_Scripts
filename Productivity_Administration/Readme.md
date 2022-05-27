# Productivity and Administration Sample Scripts

### [Click here](/README.md) for a refresher for purpose, prerequisties, and how to get support.

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
