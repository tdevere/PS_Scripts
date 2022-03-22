# TimerTrigger - PowerShell

The `TimerTrigger` makes it incredibly easy to have your functions executed on a schedule. This sample demonstrates a simple use case of calling your function every 1 minute.

## How it works

For a `TimerTrigger` to work, you provide a schedule in the form of a [cron expression](https://en.wikipedia.org/wiki/Cron#CRON_expression)(See the link for full details). A cron expression is a string with 6 separate expressions which represent a given schedule via patterns. The pattern we use to represent every 5 minutes is `0 */5 * * * *`. This, in plain text, means: "When seconds is equal to 0, minutes is divisible by 5, for any hour, day of the month, month, day of the week, or year".

## Learn more

## Documentation

## App Center Functions
### App Center Function Variables
* $apiUri - Standard URI to Open API Endpoint for App Center
* $sid - This is the unique identifier for the new session
* $InstallID - Device Install ID
* $AppSecret - This is the App Center application secrete used to send analytic data to App Center

### Start-Session
* Start-Session - Initializes Active Session with App Center Analytics
### Send-Event
* Send-Event - Used to send a new Event to App Center

## Security Check Functions
### Security Check Functions Variables
* $appCenterApi - App Center API Key, used to access App Center Open API
* $Organization_Name = This is used to query the users to run the security check.
* $ValidEmailDomain = This is the string used to evaluate the users emails. To ensure only users from your domain are authorized, add your @CompanyDomain.com portion of the email address.
* $GeneralHeaders = @{} - Used to supply necessary values to interact with App Center Analytic API

### Start_Security_Check
* Start_Security_Check - Starts up the process of the security check function. 
### Get-OrganizationUserList
* Get-OrganizationUserList - Returns a list of users that belong to an organization
### SecurityCheck_IsAuthorizedEmail
* SecurityCheck_IsAuthorizedEmail -  Validate Users Email Accounts against $ValidEmailDomain
### RemoveUnauthorizedUsersFromOrg
* RemoveUnauthorizedUsersFromOrg - Removes users from an organization.