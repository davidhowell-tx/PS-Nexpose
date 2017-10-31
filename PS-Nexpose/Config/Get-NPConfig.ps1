function Get-NPConfig {
	<#
	.SYNOPSIS
		Checks for Nexpose Module Configuration file and returns any saved values
	
	.PARAMETER ShowPassword
		Decrypts the password to be displayed for you to review. Not recommended as a screen scraper could then steal the password that was otherwise encrypted
	#>
	[CmdletBinding()]Param(
		[Parameter(Mandatory=$False)]
		[Switch]
		$ShowPassword
    )
    
    Write-Verbose -Message "Checking for configuration file to import settings."
	if (-not (Test-Path -Path "$Env:AppData\PS-Nexpose.conf")) {
        Write-Error -Message "$Env:AppData\PS-Nexpose.conf not found."
		return
    }

	# Initialize an empty Configuration object
	$Configuration = [PSCustomObject]@{
		PSTypeName = "Nexpose.Configuration"
	}
    
    [XML]$ConfigObject = Get-Content -Path "$Env:AppData\PS-Nexpose.conf"

	if ($ConfigObject.Configuration.Username) {
		Add-Member -InputObject $Configuration -MemberType NoteProperty -Name Username -Value $ConfigObject.Configuration.Username
	}

	if ($ConfigObject.Configuration.Password) {
		if ($ShowPassword) {
			$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR(($ConfigObject.Configuration.Password | ConvertTo-SecureString))
			Add-Member -InputObject $Configuration -MemberType NoteProperty -Name Password -Value ([System.Runtime.InteropServices.marshal]::PtrToStringAuto($BSTR))
			[System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
		} else {
			Add-Member -InputObject $Configuration -MemberType NoteProperty -Name Password -Value ($ConfigObject.Configuration.Password | ConvertTo-SecureString)
		}
	}

	if ($ConfigObject.Configuration.URI) { 
		Add-Member -InputObject $Configuration -MemberType NoteProperty -Name URI -Value $ConfigObject.Configuration.URI
	}

	return $Configuration
}