function Connect-NPConsole {
<#
.SYNOPSIS
	Authenticates to Nexpose and returns a session object

.DESCRIPTION
	Establishes an encrypted channel to the Nexpose console, authenticates, and returns an object containing session IDs for the v1 and v2 API.
#>

[CmdletBinding()]Param(
	[Parameter(Mandatory=$False)]
	[String]
	$URI,

	[Parameter(Mandatory=$False)]
	[System.Management.Automation.PSCredential]
	[System.Management.Automation.Credential()]
	$Credentials
)

# Following code block required to ignore SSL Certificate errors
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

# If Credentials or a URI are not supplied, check for a local configuration in the user profile
if (-not $URI -and -not $Credentials) {
    Write-Verbose -Message "Checking for configuration file to import settings."

    # If configuration file also doesn't exist there is nothing to do
    if (-not (Test-Path -Path "$Env:AppData\PS-Nexpose.conf")) {
        Write-Error -Message "No local configuration file found."
		Write-Error -Message "Please supply both URI and Credentials, or save this information in a local configuration using Set-NPConfig."
        return
    }

    Write-Verbose -Message "Importing configuration file from $Env:AppData\PS-Nexpose.conf"
    [XML]$ConfigObject = Get-Content -Path "$Env:AppData\PS-Nexpose.conf"
}

if (-not $URI) {
	Write-Verbose -Message "No URI supplied. Checking local configuration for URI."
	if (-not ($ConfigObject.Configuration.URI)) {
        Write-Error -Message "No URI found in local configuration file."
		Write-Error -Message "A URI must be provided in order to connect to Nexpose."
		return
    }
    
    $URI = $ConfigObject.Configuration.URI
}

# Generate the Nexpose Session environment variable
$NexposeSession = [PSCustomObject]@{
	PSTypeName = "Nexpose.Session"
	baseuri = $URI
}


# Generate a Web Session to manage Cookies and Login
$LoginPage = Invoke-WebRequest -Uri $URI -SessionVariable WebSession
if ($Credentials) {
	$LoginPage.Forms[0].Fields.nexposeccusername = $Credentials.Username
	$LoginPage.Forms[0].Fields.nexposeccpassword = $Credentials.GetNetworkCredential().Password
} else {
	$LoginPage.Forms[0].Fields.nexposeccusername = $ConfigObject.Configuration.Username
	$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR(($ConfigObject.Configuration.Password | ConvertTo-SecureString))
	$Password = ([System.Runtime.InteropServices.marshal]::PtrToStringAuto($BSTR))
	[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
	$LoginPage.Forms[0].Fields.nexposeccpassword = $Password
}

# Login
$LoginResponse = Invoke-WebRequest -Uri ($URI + "/data/user/login") -WebSession $WebSession -Body $LoginPage -Method Post

# Verify authentication success/failure
if ($LoginResponse.StatusCode -ne 200) {
    Write-Error -Message "Login attempt failed."
    return
}

Add-Member -InputObject $NexposeSession -MemberType NoteProperty -Name websession -Value $WebSession
Add-Member -InputObject $NexposeSession -MemberType NoteProperty -Name sessionCreated -Value (Get-Date)
return $NexposeSession
}