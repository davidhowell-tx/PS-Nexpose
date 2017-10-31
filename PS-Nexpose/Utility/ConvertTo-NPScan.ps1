function ConvertTo-NPScan {
    [CmdletBinding()]Param(
        [Parameter(Mandatory=$True)]
        $InputObject,

        [Parameter(Mandatory=$True,ParameterSetName="History")]
        [Switch]
        $History
    )
    switch ($PSCmdlet.ParameterSetName) {
        "History" {
            return [PSCustomObject]@{
                PSTypeName = "Nexpose.Scan"
                siteID = $InputObject.siteID
                siteName = $InputObject.siteName
                scanID = $InputObject.scanID
                scanName = $InputObject.scanName
                status = switch ($InputObject.status) { "C" { "Completed" } "S" { "Stopped" } "E" { "Failed" } "P" { "Paused" } Default { $InputObject.Status } }
                riskScore = $InputObject.riskScore
                assets = $InputObject.liveHosts
                vulnerabilities = $InputObject.vulnerabilityCount
                severeVulnerabilities = $InputObject.vulnSevereCount
                moderateVulnerabilities = $InputObject.vulnModerateCount
                criticalVulnerabilities = $InputObject.vulnCriticalCount
                scanType = if ($InputObject.startedByCD -eq "S") { "Scheduled" } elseif ($InputObject.startedByCD -eq "A") { "Manual" } else { $InputObject.startedByCD }
                scanEngine = $InputObject.scanEngineName
                startTime = ConvertTo-DateTime -InputObject $InputObject.startTime -MS
                endTime = ConvertTo-DateTime -InputObject $InputObject.endTime -MS
                duration = [System.TimeSpan]::FromMilliseconds($InputObject.duration)
                activeDuration = [System.TimeSpan]::FromMilliseconds($InputObject.activeDuration)
                scanEngineName = $InputObject.scanEngineName
                scanEngineID = $InputObject.scanEngineID
                totalEngines = $InputObject.totalEngines
                reason = $InputObject.reason
                username = $InputObject.username
            }
        }
    }
}