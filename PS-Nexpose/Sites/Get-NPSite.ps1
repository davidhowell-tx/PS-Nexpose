function Get-NPSite {
	<#
	.SYNOPSIS
		Get the Sites listing from the Nexpose Console.

	.PARAMETER Session
		Session Object returned from Connect-NPConsole command
    
    .PARAMETER ID
        Used to specify a Site ID to filter upon.
    
	.PARAMETER Name
		Used to specify a Site name to filter upon. Accepts wild cards.
	
	.PARAMETER Config
        Switch used to include site configuration information in the response
    
    .PARAMETER ResolveUserID
        Resolve user IDs to account information
    
	.EXAMPLE
		Get a full list of all sites with their configurations
		Get-NPSite -Session $Session -Config
	#>
	[CmdletBinding(DefaultParameterSetName="Default")]Param(
		[Parameter(Mandatory=$True)]
		$Session,

        [Parameter(Mandatory=$False)]
        [uint32]
        $ID,

        [Parameter(Mandatory=$False)]
		[String]
        $Name,
        
        [Parameter(Mandatory=$False,ParameterSetName="Default")]
        [Parameter(Mandatory=$True,ParameterSetName="Config")]
        [Switch]
        $Config,

        [Parameter(Mandatory=$False,ParameterSetName="Config")]
        [Switch]
        $ResolveUserID
    )

    $SitesResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/sites/") -WebSession $Session.websession

    if ($SitesResponse.StatusCode -ne 200) {
        Write-Error -Message "Failed to retrieve sites list"
    } else {
        $Sites = $SitesResponse.Content | ConvertFrom-Json

        if (-not $Sites) {
            Write-Error -Message "Retrieved sites list is empty"
            return
        }

        # If an ID filter was supplied, filter results
        if ($ID) {
            $Sites = $Sites | Where-Object { $_.id -like $ID }

            if (-not $Sites) {
                Write-Error -Message "ID filter returned no results."
                return
            }
        }

        # If a name filter was supplied, filter results
        if ($Name) {
            $Sites = $Sites | Where-Object { $_.name -like $Name }

            if (-not $Sites) {
                Write-Error -Message "Name filter returned no results."
                return
            }
        }

        $Results = @()
        ForEach ($Site in $Sites) {
            $Results += [PSCustomObject]@{
                PSTypeName = "Nexpose.Site"
                name = $Site.name
                id = $Site.id
                description = $Site.tag
                assets = $Site.assetCount
                riskFactor = $Site.riskFactor
                riskScore = $Site.riskScore
                moderateVulns = $Site.moderateVulns
                criticalVulns = $Site.criticalVulns
                severeVulns = $Site.severeVulns
                totalVulns = $Site.totalVulns
            }
        }

        # If Site Configuration was requested, pull additional data
        if ($Config) {
            ForEach ($Site in $Results) {
                $SiteConfigResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/scan/config/$($Site.id)") -WebSession $Session.websession

                if ($SiteConfigResponse.StatusCode -ne 200) {
                    Write-Error -Message "Failed to retrieve site configuration"
                } else {
                    $SiteConfig = $SiteConfigResponse.Content | ConvertFrom-Json
                    Add-Member -InputObject $Site -MemberType NoteProperty -Name organization -Value $SiteConfig.organization
                    Add-Member -InputObject $Site -MemberType NoteProperty -Name includedTargets -Value $SiteConfig.includedTargets
                    Add-Member -InputObject $Site -MemberType NoteProperty -Name excludedTargets -Value $SiteConfig.excludedTargets
                    Add-Member -InputObject $Site -MemberType NoteProperty -Name scanEngineID -Value $SiteConfig.engineID
                    Add-Member -InputObject $Site -MemberType NoteProperty -Name scanCredentials -Value $SiteConfig.credentialsConfig
                    Add-Member -InputObject $Site -MemberType NoteProperty -Name webCredentials -Value $SiteConfig.webCredentials
                    Add-Member -InputObject $Site -MemberType NoteProperty -Name scanTemplate -Value $SiteConfig.configName
                    Add-Member -InputObject $Site -MemberType NoteProperty -Name scanTemplateID -Value $SiteConfig.templateID
                    Add-Member -InputObject $Site -MemberType NoteProperty -Name scanBlackout -Value $SiteConfig.scanBlackout
                    Add-Member -InputObject $Site -MemberType NoteProperty -Name alertConfigs -Value $SiteConfig.alertConfigs

                    # Format Scan Schedules
                    $ScanSchedule = @()
                    ForEach ($Schedule in $SiteConfig.scanSchedule.repeaters.repeater) {
                        $ScanSchedule += ConvertFrom-NPRepeater -InputObject $Schedule
                    }
                    Add-Member -InputObject $Site -MemberType NoteProperty -Name scanSchedule -Value $ScanSchedule

                    if ($ResolveUserID -and $Users) {
                        $ResolvedUsers = @()
                        $Users | Where-Object { $_.userID -in $SiteConfig.userIDs } | ForEach-Object {
                            $ResolvedUsers += [PSCustomObject]@{
                                PSTypeName = "Nexpose.User"
                                id = $_.userID
                                userName = $_.username
                                fullName = $_.fullName
                                email = $_.email
                                role = $_.role
                            }
                        }
                        Add-Member -InputObject $Site -MemberType NoteProperty -Name users -Value $ResolvedUsers
                    } else {
                        Add-Member -InputObject $Site -MemberType NoteProperty -Name users -Value $SiteConfig.userIDs
                    }
                }
            }
        }

        return $Results
    }
}