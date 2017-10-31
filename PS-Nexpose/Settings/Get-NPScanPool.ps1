function Get-NPScanPool {
    <#
	.SYNOPSIS
		Retrieve scan pools from the Nexpose Console.

	.PARAMETER Session
		Session Object returned from Connect-NPConsole command
	#>
	[CmdletBinding()]Param(
		[Parameter(Mandatory=$True)]
		$Session
    )

    # Generate the Scan Pool request
    $ScanPoolForm = @{
        sort = "-1"
        dir = "-1"
        startIndex = "-1"
        results = "-1"
        "table-id" = "engine-pool-listing"
    }
    $ScanPoolHeaders = @{
        Referer = "$($Session.baseuri)/admin/engine/listing.jsp"
        nexposeCCSessionID = ($Session.websession.Cookies.GetCookies("$($Session.baseuri)") | Where-Object { $_.Name -eq "nexposeCCSessionID" } | Select-Object -ExpandProperty Value)
    }
    $ScanPoolResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/engine/pools") -WebSession $Session.websession -Method Post -Body $ScanPoolForm -Headers $ScanPoolHeaders

    if ($ScanPoolResponse.StatusCode -ne 200) {
        Write-Error -Message "Failed to retrieve scan pool list"
    } else {
        $ScanPools = $ScanPoolResponse.Content | ConvertFrom-Json

        $ScanPoolResults = @()
        ForEach ($ScanPool in $ScanPools.records) {
            $Object = [PSCustomObject]@{
                PSTypeName = "Nexpose.ScanPool"
                name = $ScanPool.name
                id = $ScanPool.id
                engineCount = $ScanPool.engineCount
                siteCount = $ScanPool.siteCount
                scope = $ScanPool.scope
            }

            $ScanPoolInfoResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/engine/pools/$($Object.id)") -WebSession $Session.websession

            if ($ScanPoolInfoResponse.StatusCode -ne 200) {
                Write-Error -Message "Failed to retrieve scan engine information"
            } else {
                $ScanPoolInfo = $ScanPoolInfoResponse.Content | ConvertFrom-Json
                $ScanPoolEngines = @()
                ForEach ($ScanPoolEngine in $ScanPoolInfo.engines) {
                    $ScanPoolEngines += [PSCustomObject]@{
                        id = $ScanPoolEngine.id
                        name = $ScanPoolEngine.name
                    }
                }
                Add-Member -InputObject $Object -MemberType NoteProperty -Name scanEngines -Value $ScanPoolEngines
            }
            $ScanPoolResults += $Object
        }
        return $ScanPoolResults
    }
}