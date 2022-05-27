# Distribution Sample Scripts

### [Click here](/README.md) for a refresher for purpose, prerequisties, and how to get support.

## [Get List of Distribution Group Members](/Distribution/GetDistributionGroupMembers.ps11)
* Sample script showing how to Get List of Distribution Group Members

## [Generate List of Download Links to Each App Release](/Distribution/GetAllReleaseDownloadLinks.ps1)
* On occasion the install.appcenter.ms portal may not display releases is a useful way. Some views my prevent you from finding the download link for a particular release. This script will help you discover the download link for all available releases.

## [Disable Old Releases](/Distribution/DisableOldReleases.ps1)
* As releases pile up you may begin to notice timeouts when accessing the install.appcenter.ms portal. There is no pagination when pulling results for releases in AppCenter, therefore some odd behavior can pop up when you begin to have a large result set from this data. One workaround to this behavior would be to disable older releases.