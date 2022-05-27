# Build Sample Scripts

### [Click here](/README.md) for a refresher for purpose, prerequisties, and how to get support.

## [Auto Renew Disabled Exports in App Center](/Build/ExportConfigNotification.ps1)
* Export of Analytic Data was Disabled - You find your analytics export data was disabled recently. Although you can reenable, you need a way to auto enable if this condition happens or you risk losing Analytic data. Although App Center provides no automatic notification you can use the https://openapi.appcenter.ms/#/export/ExportConfigurations_Get API and query on a schedule to check the status. If it is disabled, you can take restoration action. This script is provided to assist you with this effort. [Auto Renew Disabled Exports in App Center](/ExportConfigNotification.ps1)
* 10/2/2021 - App Center has a known issue which is yet to be fixed. When the automatic disable event occurs, re-enabling export does not backfill data as the documentation suggests happens when you initially setup export. The only way as of today to get backfill data, is to delete the export and then create the export again. ``` Warning there is no system in place to prevent duplicate data if you restore the connection to the same App Insights Instance or Blob Storage account. ``` 
* If you are using this script or similar approach, you are less impacted as the only data lost would be between the time the export was disabled and when the script enables export again. 

## [Clone Branch Confiruation](/Build/CloneBranchBuildConfig.ps1)
* Perhaps you need to modify the branch configuration for a large number of Apps. The portal is not the best tool for this job. Instead, check out this script for an example on how to:
    1. Clone an existing branch
    2. Set a branch configuration on a new branch