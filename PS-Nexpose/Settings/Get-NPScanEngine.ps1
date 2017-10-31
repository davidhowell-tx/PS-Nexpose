function Get-NPScanEngine {
    <#
	.SYNOPSIS
		Retrieve scan engines from the Nexpose Console.

	.PARAMETER Session
		Session Object returned from Connect-NPConsole command
	#>
	[CmdletBinding()]Param(
		[Parameter(Mandatory=$True)]
		$Session
    )

    # Generate the Scan Engine request
    $ScanEngineForm = @{
        sort = "-1"
        dir = "-1"
        startIndex = "-1"
        results = "-1"
        "table-id" = "engine-listing"
    }
    $ScanEngineHeaders = @{
        Referer = "$($Session.baseuri)/admin/engine/listing.jsp"
        nexposeCCSessionID = ($Session.websession.Cookies.GetCookies("$($Session.baseuri)") | Where-Object { $_.Name -eq "nexposeCCSessionID" } | Select-Object -ExpandProperty Value)
    }
    $ScanEngineResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/engines/") -WebSession $Session.websession -Method Post -Body $ScanEngineForm -Headers $ScanEngineHeaders

    if ($ScanEngineResponse.StatusCode -ne 200) {
        Write-Error -Message "Failed to retrieve scan engine list"
    } else {
        $ScanEngines = $ScanEngineResponse.Content | ConvertFrom-Json

        $ScanEngineResults = @()
        ForEach ($ScanEngine in $ScanEngines.records) {
            $ScanEngineResults += [PSCustomObject]@{
                PSTypeName = "Nexpose.ScanEngine"
                name = $ScanEngine.name
                id = $ScanEngine.id
                status = $ScanEngine.status
                address = $ScanEngine.address
                port = $ScanEngine.port
                os = $ScanEngine.os
                scope = $ScanEngine.scope
                engineVersion = $ScanEngine.engineVersion
                lastRefreshTime = ConvertTo-DateTime $ScanEngine.lastRefreshTime -MS
                lastUpdateDate = ConvertTo-DateTime $ScanEngine.lastUpdateDate -MS
                engineContentUpdateData = $ScanEngine.engineContentUpdateData
                engineProductUpdateData = $ScanEngine.engineProductUpdateData
                engineDynamicContentUpdateData = $ScanEngine.engineDynamicContentUpdateData
                siteCount = $ScanEngine.siteCount
                hostedEngine = $ScanEngine.hostedEngine
            }
        }

        return $ScanEngineResults
    }
}