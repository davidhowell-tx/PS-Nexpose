function Get-NPAsset {
	<#
	.SYNOPSIS
		Retrieve asset information from the Nexpose Console.

	.PARAMETER Session
		Session Object returned from Connect-NPConsole command
	#>
	[CmdletBinding()]Param(
		[Parameter(Mandatory=$True)]
		$Session,

		[Parameter(Mandatory=$False)]
		[uint32]
        $ID,
        
        [Parameter(Mandatory=$True,ParameterSetName="Trend")]
        [ValidateSet("day","week","month")]
        [String]
        $Trend="week"
    )

    $DevicesResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/sites/") -WebSession $Session.websession
    $Sites = $SitesResponse.Content | ConvertFrom-Json

    $Results = @()
    ForEach ($Site in $Sites) {
        $Results += [PSCustomObject]@{
            PSTypeName = "Nexpose.Site"
            name = $Site.name
            id = $Site.id
            description = $Site.tag
            assetCount = $Site.assetCount
            riskFactor = $Site.riskFactor
            riskScore = $Site.riskScore
            moderateVulns = $Site.moderateVulns
            criticalVulns = $Site.criticalVulns
            severeVulns = $Site.severeVulns
            totalVulns = $Site.totalVulns
        }
    }

    # If a name filter was supplied, filter results
    if ($Name) {
        $Results = $Results | Where-Object { $_.name -like $Name }
    }

    # If Site Configuration was requested, pull additional data
    if ($Config) {
        ForEach ($Site in $Results) {
            $SiteConfigResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/scan/config/$($Site.id)") -WebSession $Session.websession
            $SiteConfig = $SiteConfigResponse.Content | ConvertFrom-Json
            Add-Member -InputObject $Site -MemberType NoteProperty -Name organization -Value $SiteConfig.organization
            Add-Member -InputObject $Site -MemberType NoteProperty -Name userIDs -Value $SiteConfig.userIDs
            Add-Member -InputObject $Site -MemberType NoteProperty -Name includedTargets -Value $SiteConfig.includedTargets
            Add-Member -InputObject $Site -MemberType NoteProperty -Name excludedTargets -Value $SiteConfig.excludedTargets
            Add-Member -InputObject $Site -MemberType NoteProperty -Name scanEngineID -Value $SiteConfig.engineID
            Add-Member -InputObject $Site -MemberType NoteProperty -Name scanCredentials -Value $SiteConfig.credentialsConfig
            Add-Member -InputObject $Site -MemberType NoteProperty -Name webCredentials -Value $SiteConfig.webCredentials
            Add-Member -InputObject $Site -MemberType NoteProperty -Name scanTemplate -Value $SiteConfig.configName
            Add-Member -InputObject $Site -MemberType NoteProperty -Name scanTemplateID -Value $SiteConfig.templateID
            Add-Member -InputObject $Site -MemberType NoteProperty -Name scanSchedule -Value $SiteConfig.scanSchedule
            Add-Member -InputObject $Site -MemberType NoteProperty -Name scanBlackout -Value $SiteConfig.scanBlackout
            Add-Member -InputObject $Site -MemberType NoteProperty -Name alertConfigs -Value $SiteConfig.alertConfigs
        }
    }

    return $Results
}