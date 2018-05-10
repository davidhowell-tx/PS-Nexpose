# PS-Nexpose
PowerShell module used to interact with various Nexpose APIs

This module is currently being converted to use the v3 API introduced in version 6.5 (January 10, 2018)

# Getting Started
## Install/Uninstall
I've provided some simple scripts to aid installing and uninstalling the module so that it is loaded when you start PowerShell.
Just execute Install-Module.ps1 or Uninstall-Module.ps1.  These scripts just add or remove the module to your PSModulePath.

## Importing Module
If you don't want to install the module to your PSModulePath, you can simply import it by running
```PowerShell
PS > Import-Module .\PS-Nexpose.psm1
```

# Saving Nexpose Configuration
It's annoying to specify the Nexpose URI and credentials every time you interact with the API.  If you wish, you can choose to save this configuration to disk.
NOTE: Passwords are saved in an encrypted standard string by using the ConvertFrom-SecureString commandlet.

Below is an example of saving your configuration. You will be prompted for the credentials so that you don't have to type them in clear text into PowerShell.
```PowerShell
PS > Set-NPConfig -URI "https://nexpose.domain.local:3780" -Credentials (Get-Credential)
```

View the saved configuration
```PowerShell
PS > Get-NPConfig

Credentials                               URI
-----------                               ---
System.Management.Automation.PSCredential https://nexpose.domain.local:3780
```

Remove the saved configuration with the below
```
Set-NPConfig -RemoveConfig
```

# API - Commandlet Mapping
Name | API URI | Commandlet
--- | --- | ---
Assets | GET /api/3/assets | `Get-NPAsset`
Assets | POST /api/3/sites/{id}/assets |
Asset Search | POST /api/3/assets/search |
Asset | GET /api/3/assets/{id} | `Get-NPAsset -ID {id}`
Asset | DELETE /api/3/assets/{id} |
Asset Databases | GET /api/3/assets/{id}/databases | `Get-NPAsset -ID {id} -Properties Databases`<br>`Get-NPAsset -Properties Databases`<br>`Get-NPAsset -Properties All`
Asset Files | GET /api/3/assets/{id}/files | `Get-NPAsset -ID {id} -Properties Files`<br>`Get-NPAsset -Properties Files`<br>`Get-NPAsset -Properties All`
Asset Services | GET /api/3/assets/{id}/services | `Get-NPAsset -ID {id} -Properties Services`<br>`Get-NPAsset -Properties Services`<br>`Get-NPAsset -Properties All`
Asset Service | GET /api/3/assets/{id}/services/<br>{protocol}/{port} | 
Asset Service Configurations | GET /api/3/assets/{id}/services/<br>{protocol}/{port}/configurations |
Asset Service Databases | GET /api/3/assets/{id}/services/<br>{protocol}/{port}/databases |
Asset Service User Groups | GET /api/3/assets/{id}/services/<br>{protocol}/{port}/user_groups |
Asset Service Users | GET /api/3/assets/{id}/services/<br>{protocol}/{port}/users |
Asset Service Web Applications | GET /api/3/assets/{id}/services/<br>{protocol}/{port}/web_applications |
Asset Service Web Application | GET /api/3/assets/{id}/services/<br>{protocol}/{port}/web_applications/<br>{webApplicationId} |
Asset Software | GET /api/3/assets/{id}/software | `Get-NPAsset -ID {id} -Properties Software`<br>`Get-NPAsset -Properties Software`<br>`Get-NPAsset -Properties All`
Asset Tags | GET /api/3/assets/{id}/tags | `Get-NPAsset -ID {id} -Properties Tags`<br>`Get-NPAsset -Properties Tags`<br>`Get-NPAsset -Properties All`
Asset Tag | PUT /api/3/assets/{id}/tags/{tagId} | 
Asset Tag | DELETE /api/3/assets/{id}/tags/{tagId} |
Asset User Groups | GET /api/3/assets/{id}/user_groups | `Get-NPAsset -ID {id} -Properties 'User Groups'`<br>`Get-NPAsset -Properties 'User Groups'`<br>`Get-NPAsset -Properties All`
Asset Users | GET /api/3/assets/{id}/users | `Get-NPAsset -ID {id} -Properties Users`<br>`Get-NPAsset -Properties Users`<br>`Get-NPAsset -Properties All`
Operating Systems | GET /api/3/operating_systems | `Get-NPOperatingSystem`
Operating System | GET /api/3/operating_systems/{id} | `Get-NPOperatingSystem -ID {id}`
Software | GET /api/3/software | `Get-NPSoftware`
Software | GET /api/3/software/{id} | `Get-NPSoftware -ID {id}`
Discovery Connections | GET /api/3/discovery_connections | `Get-NPDiscoveryConnection`
Discovery Connection | GET /api/3/discovery_connections/{id} | `Get-NPDiscoveryConnection -ID {id}`
Discovery Connection Reconnect | POST /api/3/discovery_connections/{id}/<br>connect | 
Sonar Queries | GET /api/3/sonar_queries | `Get-NPSonarQuery`
Sonar Queries | POST /api/3/sonar_queries |
Sonar Queries | POST /api/3/sonar_queries/search |
Sonar Query | GET /api/3/sonar_queries/{id} | `Get-NPSonarQuery -ID {id}`
Sonar Query | PUT /api/3/sonar_queries/{id} |
Sonar Query | DELETE /api/3/sonar_queries/{id} |
Sonar Query Assets | GET /api/3/sonar_queries/{id}/assets |
Asset Groups | GET /api/3/asset_groups | `Get-NPAssetGroup`
Asset Groups | POST /api/3/asset_groups |
Asset Group | GET /api/3/asset_groups/{id} | `Get-NPAssetGroup -ID {id}`
Asset Group | PUT /api/3/asset_groups/{id} |
Asset Group | DELETE /api/3/asset_groups/{id} |
Asset Group Assets | GET /api/3/asset_groups/{id}/assets | `Get-NPAssetGroup -ID {id} -Properties 'Asset Group Assets'`<br>`Get-NPAssetGroup -Properties 'Asset Group Assets'`<br>`Get-NPAssetGroup -Properties All`
Asset Group Assets | PUT /api/3/asset_groups/{id}/assets |
Asset Group Assets | DELETE /api/3/asset_groups/{id}/assets |
Asset Group Asset | PUT /api/3/asset_groups/{id}/assets/{assetId} |
Asset Group Asset | DELETE /api/3/asset_groups/{id}/assets/{assetId} |
Asset Group Search Criteria | GET /api/3/asset_groups/{id}/search_criteria |
Asset Group Search Criteria | PUT /api/3/asset_groups/{id}/search_criteria |
Asset Group Tags | GET /api/3/asset_groups/{id}/tags | `Get-NPAssetGroup -ID {id} -Properties 'Asset Group Tags'`<br>`Get-NPAssetGroup -Properties 'Asset Group Tags'`<br>`Get-NPAssetGroup -Properties All`
Asset Group Tags | PUT /api/3/asset_groups/{id}/tags |
Asset Group Tags | DELETE /api/3/asset_groups/{id}/tags |
