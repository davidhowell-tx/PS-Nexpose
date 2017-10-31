# PS-Nexpose
Interacts with various Nexpose APIs

I found the APIs provided by Nexpose to be lacking in information, so decided to analyze the calls made by the browser when using the application. This module utilizes the same APIs the web application uses rather than the XML API.

# STILL IN PROGRESS
This module is nowhere near complete and is severely lacking.Time doesn't allow me to sit and fill in all the gaps, so development will be slow and as needed for my own means. A lot of the code is still being refined, and you may find some functions not yet exported by the module (as these are still being worked on).

Testing has been minimal and only with my own use cases.

Documentation for this module is also still in progress.

# Getting Started
Import the Module
```
Import-Module .\PS-Nexpose.psm1
```

### Configuration File / Saved Settings
Save the URI to a local conf file (stored in User's AppData)
```
Set-NPConfig -URI "https://Nexpose.URL.Or.IP:3780"
```

Check the saved URI
```
Get-NPConfig

URI
---
https://Nexpose.URL.Or.IP:3780
```

Optionally, prompt for and save credentials to a local conf file.

**WARNING**: Saving credentials to disk is not recommend as it is a security risk to do so.

I utilize the ConvertFrom-SecureString commandlet to store the password in an encrypted format to mitigate the risk, but this still isn't recommended.

https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.security/convertfrom-securestring?view=powershell-5.1
```
Set-NPConfig -Credentials (Get-Credential)
```

Check the saved configuration
```
Get-NPConfig | Format-List

Username : test
Password : System.Security.SecureString
URI      : https://Nexpose.URL.Or.IP:3780
```

### Session
Establish a Session with saved URI and Credentials
```
$Session = Connect-NPConsole
```

Establish a Session, prompt for Credentials
```
$Session = Connect-NPConsole -URI "https://Nexpose.URL.Or.IP:3780" -Credentials (Get-Credential)
```

### Sites
Get a Quick Site Listing.  Runs a single query to pull a small amount of information about all sites, as if you were navigating to the /site/listing.jsp page.
```
Get-NPSite -Session $Session
```

Get a verbose Site Listing.  Runs an additional query for every site in the context, as if you were navigating to every site's page at site.jsp?siteid=26, and clicking on the "manage site" button to view full information.
```
Get-NPSite -Session $Session -Config
```

Limit the context by specifying a site name filter.  Uses the -like switch, so wild cards do work.
```
Get-NPSite -Session $Session -Name "*Test*" -Config
```

Limit the context to a specific site ID.
```
Get-NPSite -Session $Session -ID 1 -Config
```
