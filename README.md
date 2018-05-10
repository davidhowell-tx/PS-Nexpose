# PS-Nexpose
PowerShell module used to interact with various Nexpose APIs

This module is currently being converted to use the v3 API introduced in version 6.5 (January 10, 2018)

# Install/Uninstall
If you want this module to load every time you start PowerShell, use the install scripts
```
PS > .\Install-Module.ps1
```
If you want to remove it, run the uninstall script or simply delete it from your PSModulePath
```
PS > .\Uninstall-Module.ps1
```

# Importing Module
If you don't want to install the module to your PSModulePath, you can simply import it by running
```PowerShell
PS > Import-Module .\PS-Nexpose\PS-Nexpose.psm1
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



# Asset Groups
## Retrieving Asset Groups
Search for an asset group
```
PS > Get-NPAssetGroup -Name "ACME"
```

Return a specific asset group by ID
```
PS > Get-NPAssetGroup -ID {id}
```

Return a list of all asset groups
```
PS > Get-NPAssetGroup -All
```

## Creating a New Asset Group
Generate the search criteria
```
PS > $SearchCriteria = New-NPSearchCriteria -Operator Any
```

Add search terms to the criteria
```
PS > $SearchCriteria | Add-NPSearchTerm -AssetName -Is "ACME"
```
```
PS > $SearchCriteria | Add-NPSearchTerm -IPAddress -Is "192.168.1.50"
```

Create a new asset group with the search criteria
```
PS > New-NPAssetGroup -Name "ACME Servers" -Description "ACME Servers" -SearchCriteria $SearchCriteria -Type dynamic
```
