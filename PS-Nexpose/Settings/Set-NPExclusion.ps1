function Set-NPExclusion {
	<#
    .SYNOPSIS
        Used to change the global exclusion list to the provided list.  To add a single exclusion use New-NPExclusion

	.PARAMETER Session
		Session Object returned from Connect-NPConsole command
	#>
	[CmdletBinding()]Param(
		[Parameter(Mandatory=$True)]
        $Session,
        
        [Parameter(Mandatory=$True,ParameterSetName="FilePath")]
        [String]
        $Path,

        [Parameter(Mandatory=$True,ParameterSetName="Default")]
        [String[]]
        $InputObject
	)
	
	$GlobalSettingsResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/admin/global-settings") -WebSession $Session.websession
	
	if ($GlobalSettingsResponse.StatusCode -ne 200) {
		Write-Error -Message "Failed to retrieve Nexpose Global Settings"
	} else {
		[XML]$GlobalSettingsXML = $GlobalSettingsResponse.Content

		$AssetExclusions = @()

		# Process Address Ranges
		if ($GlobalSettingsXML.GlobalSettings.ExcludedHosts.range) {
			ForEach ($Range in $GlobalSettingsXML.GlobalSettings.ExcludedHosts.range) {
				if ($Range.to) {
					$AssetExclusions += "$($Range.from) - $($Range.to)"
				} else {
					$AssetExclusions += $Range.from
				}
			}
		}

		# Process Host entries
		if ($GlobalSettingsXML.GlobalSettings.ExcludedHosts.host) {
			ForEach ($Host in $GlobalSettingsXML.GlobalSettings.ExcludedHosts.host) {
				$AssetExclusions += $Host
			}
		}

		# Process unknown entry types
		if ($GlobalSettingsXML.GlobalSettings.ExcludedHosts | Get-Member -MemberType Property | Where-Object { $_.name -ne "range" -and $_.name -ne "host" }) {
			$GlobalSettingsXML.GlobalSettings.ExcludedHosts | Get-Member -MemberType Property | Where-Object { $_.name -ne "range" -and $_.name -ne "host" } | ForEach-object {
				ForEach ($Entry in $GlobalSettingsXML.GlobalSettings.ExcludedHosts.$_) {
					$AssetExclusions += $Entry
				}
			}
		}

		return $AssetExclusions
	}
}