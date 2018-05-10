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

# Remember URI and Credentials
If you don't want to provide URI and Credentials for every commandlet, you can save them to the hard drive.
NOTE: Passwords are saved in an encrypted standard string by using the ConvertFrom-SecureString commandlet.

```
PS > Set-NPConfig -URI "https://nexpose.domain.local:3780" -Credentials (Get-Credential)
```

View the saved configuration
```
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
PS > $SearchCriteria | Add-NPSearchTerm -IPAddress -Is "192.168.1.50"
```

Create a new asset group with the search criteria. The returned integer is the id of the new asset group
```
PS > New-NPAssetGroup -Name "ACME Servers" -Description "ACME Servers" -SearchCriteria $SearchCriteria -Type dynamic
1
```

## Change an existing Asset Group

Change the name
```
PS > Set-NPAssetGroup -ID 1 -Name "ACME Windows Servers"
```

Change the description
```
PS > Set-NPAssetGroup -ID 1 -Description "Windows Servers for ACME Corporation"
```

Change the search criteria
```
PS > $SearchCriteria = New-NPSearchCriteria -Operator Any
PS > $SearchCriteria | Add-NPSearchTerm -IPAddress -IsInTheRangeOf -Lower "192.168.1.1" -Upper "192.168.1.254
PS > Set-NPAssetGroup -ID 1 -SearchCriteria $SearchCriteria
```
