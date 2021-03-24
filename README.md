# Under development

# PS-Nexpose PowerShell Module

## Table of Contents

* [Overview](#overview)
* [Installation and Removal](#installation-and-removal)
* [Configuration](#configuration)
* [Capability](#capability)

----------
## Overview

This is a PowerShell script module that provides command-line interaction and automation using the Nexpose REST API.

Development is ongoing, with the goal to add support for the majority of the API set, and an attempt to provide examples for various capabilities.

----------
## Installation and Removal

Installation of this module currently consists of a pair of scripts that will copy the module to the first of the PowerShell module paths, and check PowerShell module paths to remove it.

**Install**
```PowerShell
.\Install-Module.ps1
```

**Uninstall**
```PowerShell
.\Uninstall-Module.ps1
```

If you don't want to install the module to your PSModulePath, you can simply import it by running
```PowerShell
PS > Import-Module .\PS-Nexpose\PS-Nexpose.psm1
```

----------
## Configuration

PS-Nexpose includes commandlets to configure information specific to your environment, such as the URI of your Nexpose console, and your access credentials.

You may choose to cache this information for the current session, or save the information to disk. Saved credentials are protected by using secure strings.

### In Session Configuration

Set the base URI for your console and your credentials for this session
```PowerShell
PS > Set-NPModuleConfiguration -URI "https://nexpose.domain.local:3780" -Credentials (Get-Credential)
```

Check the settings in the current session
```PowerShell
PS > Get-NPModuleConfiguration

Name                           Value
----                           -----
ManagementURL                  https://nexpose.domain.local:3780
UserName                       testing
Password                       ...
ConfPath                       C:\Users\<username>\AppData\Local\PS-Nexpose\config.json
```
### Persisted Configuration

Save to disk the URI for your Nexpose console and your credentials
```PowerShell
PS > Set-NPModuleConfiguration -URI "https://nexpose.domain.local:3780" -Credentials (Get-Credential) -Persist
```

Review any settings saved to disk
```PowerShell
PS > Get-NPModuleConfiguration -Persisted
```

Import settings saved to disk into the current session
```PowerShell
PS > Get-NPModuleConfiguration -Persisted -Cache
```

Saved settings do not need to be manually imported into the current session. If there are settings saved to disk and the current session has none configured, the module will automatically import the saved settings when running your first commandlet that requires them. You can test this by doing the following
```PowerShell
PS > Import-Module .\PS-Nexpose.psm1
PS > Get-NPModuleConfiguration
Name                           Value
----                           -----
ConfPath                       C:\Users\<username>\AppData\Local\PS-Nexpose\config.json

PS > Get-NPSite
<OUTPUT REMOVED>

PS > Get-NPModuleConfiguration

Name                           Value
----                           -----
ManagementURL                  https://nexpose.domain.local:3780
UserName                       testing
Password                       ...
ConfPath                       C:\Users\<username>\AppData\Local\PS-Nexpose\config.json
```

----------
## General Architecture of Module
The module is designed for the core interaction with the API is abstracted away into a central core function, **Invoke-NPQuery**. This function is meant to build the Web Request, add authentication headers, add parameters or query string filters, and handle pagination or recursion through results.

The rest of the module is designed to build a query for specific APIs and call the  **Invoke-NPQuery** function.  If a commandlet doesn't exist that is supported by the API, it should be possible to utilize **Invoke-NPQuery** to query the API "manually"

----------
## Capability

* Asset Groups
  * Get-NPAssetGroup
* Assets
  * Get-NPAsset
* Sites
  * Get-NPSite
* Tags
  * Get-NPTag

### Asset Groups
#### Get All Asset Groups
```PowerShell
PS > Get-NPAssetGroup
```

#### Get Asset Group by ID
```PowerShell
PS > Get-NPAssetGroup -ID <id>
```

### Assets
#### Get All Assets
```PowerShell
PS > Get-NPAsset
```
#### Get Asset by ID
```PowerShell
PS > Get-NPAsset -ID <id>
```
### Sites
#### Get All Sites
```PowerShell
PS > Get-NPSite
```
#### Get Site by ID
```PowerShell
PS > Get-NPSite -ID <id>
```

### Tags
#### Get All Tags
```PowerShell
PS > Get-NPTag
```
#### Get Tag by ID
```PowerShell
PS > Get-NPTag -ID <id>
```