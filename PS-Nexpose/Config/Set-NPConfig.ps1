function Set-NPConfig {
	<#
	.SYNOPSIS
		Used to save configuration options in the current user profile.

	.PARAMETER URI
		Used to save the URI of the Nexpose console.
	
	.PARAMETER Credentials
		Used to store an encrypted version of your credentials. Encryption uses the Windows Data Protect API, and can only be decrypted on the same computer by the same username when it was encrypted.
	
	.PARAMETER RemoveConfig
		Used to delete the configuration file currently saved under the user's profile
	
	.EXAMPLE
		Saves a Nexpose URI and prompts for Credentials to the "nxadmin" account to be encrypted with the config.
		Set-NPConfig -URI "https://nexpose.acme.com:3780" -Credenials nxadmin

	.EXAMPLE
		Remove the currently saved configuration
		Set-NPConfig -RemoveConfig
	#>
	[CmdletBinding()]Param(
		[Parameter(Mandatory=$False,ParameterSetName="SetConfig")]
		[String]
		$URI,

		[Parameter(Mandatory=$False,ParameterSetName="SetConfig")]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.Credential()]
		$Credentials,
		
		[Parameter(Mandatory=$True,ParameterSetName="RemoveConfig")]
		[Switch]
		$RemoveConfig
	)

	if ($PSCmdlet.ParameterSetName -eq "SetConfig") {
		# If a configuration file already exists, import it. Otherwise, create one from scratch.
        Write-Verbose -Message "Checking for configuration file."
        
		if (Test-Path -Path "$Env:APPDATA\PS-Nexpose.conf") {
			Write-Verbose -Message "Configuration file found, importing to make changes."
			[XML]$ConfigObject = Get-Content -Path "$Env:APPDATA\PS-Nexpose.conf"
			$ConfigurationElement = $ConfigObject.ChildNodes | Where-Object { $_.Name -eq "Configuration" }
		} else {
			Write-Verbose -Message "Configuration file not found, creating one."
			$ConfigObject = New-Object System.Xml.XmlDocument
			$ConfigurationElement = $ConfigObject.CreateElement("Configuration")
			$ConfigObject.AppendChild($ConfigurationElement) | Out-Null
		}

		if ($URI) {
			Write-Verbose -Message "Adding Nexpose console URI to saved configuration."
			if (-not $ConfigObject.Configuration.URI) {
				$ConfigurationElement.SetAttribute("URI",$URI) | Out-Null
			} else {
				$ConfigObject.Configuration.URI = $URI
			}
		}

		if ($Credentials) {
			Write-Verbose -Message "Adding Credentials to saved configuration."
			if (-not $ConfigObject.Configuration.Username) {
				$ConfigurationElement.SetAttribute("Username",$Credentials.UserName)
			} else {
				$ConfigObject.Configuration.Username = $Credentials.UserName
			}

			if (-not $ConfigObject.Configuration.Password) {
				$ConfigurationElement.SetAttribute("Password", (ConvertFrom-SecureString -SecureString $Credentials.Password))
			} else {
				$ConfigObject.Configuration.Password = (ConvertFrom-SecureString -SecureString $Credentials.Password)
			}
		}

		Try {
			Write-Verbose -Message "Saving configuration to $Env:AppData\PS-Nexpose.conf"
			$ConfigObject.Save("$Env:AppData\PS-Nexpose.conf")
		} Catch {
			Write-Verbose -Message "Error received when attempting to save the configuration to $Env:AppData\PS-Nexpose.conf"
			Write-Error -Message "Error received when attempting to save configuration to $Env:AppData\PS-Nexpose.conf"
		}
	}
	
	if ($PSCmdlet.ParameterSetName -eq "RemoveConfig") {
		if (Test-Path -Path "$Env:APPDATA\PS-Nexpose.conf") {
			Write-Verbose -Message "Deleting the configuration file from $Env:AppData\PS-Nexpose.conf"
			Remove-Item -Path "$Env:AppData\PS-Nexpose.conf" -Force
		}
	}
}