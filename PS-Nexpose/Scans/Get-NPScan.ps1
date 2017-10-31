function Get-NPScan {
	<#
	.SYNOPSIS
		Retrieve scan information from the Nexpose Console.

	.PARAMETER Session
        Session Object returned from Connect-NPConsole command
    
    .PARAMETER ScanID
        Used to specify a ScanID to filter upon
    
    .PARAMETER SiteID
        Used to specify a Site ID to filter upon.
    
    .PARAMETER Status
        Used to filter scans by scan status
	#>
	[CmdletBinding(DefaultParameterSetName="Active")]Param(
		[Parameter(Mandatory=$True)]
        $Session,
        
        [Parameter(Mandatory=$True,ParameterSetName="Active")]
        [Switch]
        $Active,

        [Parameter(Mandatory=$True,ParameterSetName="HistoryAll")]
        [Parameter(Mandatory=$True,ParameterSetName="HistorySite")]
        [Switch]
        $History,

        #[Parameter(Mandatory=$True,ParameterSetName="ScanID")]
        #[uint32]
        #$ScanID,

        [Parameter(Mandatory=$True,ParameterSetName="HistorySite")]
        [uint32]
        $SiteID,

        [Parameter(Mandatory=$False,ParameterSetName="HistoryAll")]
        [Parameter(Mandatory=$False,ParameterSetName="HistorySite")]
        [uint32]
        $Count,

        [Parameter(Mandatory=$False,ParameterSetName="HistoryAll")]
        [Parameter(Mandatory=$False,ParameterSetName="HistorySite")]
        [ValidateSet("Completed", "Stopped", "Failed", "Paused")]
        [String[]]
        $Status
    )

    switch ($PSCmdlet.ParameterSetName) {
        "Active" {
            $ActiveScansResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/site/scans/dyntable?printDocType=0&tableID=siteScansTable&activeOnly=true&siteID=") -WebSession $Session.websession
            if ($ActiveScansResponse.StatusCode -ne 200) {
                Write-Error -Message "Failed to retrieve active scan list"
                return
            } else {
                [XML]$ActiveScansXML = $ActiveScansResponse.Content

                $ActiveScanHeaders = $ActiveScansXML.DynTable.MetaData.Column | Select-Object -ExpandProperty name

                $ActiveScans = @()
                # Loop through TRs in the Response
                ForEach ($Row in $ActiveScansXML.DynTable.Data.tr) {
                    $ActiveScan = [PSCustomObject]@{ PSTypeName = "Nexpose.ActiveScan" }

                    for ($i = 0; $i -lt $ActiveScanHeaders.count; $i++) {
                        switch ($ActiveScanHeaders[$i] -replace " ","") {
                            "Started" {
                                Add-Member -InputObject $ActiveScan -MemberType NoteProperty -Name startTime -Value (ConvertTo-DateTime $Row.td[$i] -MS)
                            }

                            "Elapsed" {
                                $TimeSpan = New-TimeSpan -Seconds ($Row.td[$i] / 1000)
                                $TimeSpanArray = @()
                                if ($TimeSpan.Days) {
                                    $TimeSpanArray += "$($TimeSpan.Days) Days"
                                }
                                if ($TimeSpan.Hours) {
                                    $TimeSpanArray += "$($TimeSpan.Hours) Hours"
                                }
                                if ($TimeSpan.Minutes) {
                                    $TimeSpanArray += "$($TimeSpan.Minutes) Minutes"
                                }
                                if ($TimeSpan.Seconds) {
                                    $TimeSpanArray += "$($TimeSpan.Seconds) Seconds"
                                }
                                Add-Member -InputObject $ActiveScan -MemberType NoteProperty -Name elapsedTime -Value ($TimeSpanArray -join ", ")
                            }
                            Default {
                                Add-Member -InputObject $ActiveScan -MemberType NoteProperty -Name ($ActiveScanHeaders[$i] -replace " ","") -Value $Row.td[$i]
                            }
                        }
                    }
                    $ActiveScans += $ActiveScan
                }
                return $ActiveScans
            }
        }

        "HistoryAll" {
            $ScanHistoryForm = @{ sort = "endTime"; dir = "DESC"; startIndex = "0"; results = "500"; "table-id" = "global-completed-scans" }
            $ScanHistoryHeaders = @{
                Referer = "$($Session.baseuri)/scan/global/scan-history.jsp"
                nexposeCCSessionID = ($Session.websession.Cookies.GetCookies("$($Session.baseuri)") | Where-Object { $_.Name -eq "nexposeCCSessionID" } | Select-Object -ExpandProperty Value)
            }
            # If a specific amount of results was requested, don't query for more results than necessary (reduce process time)
            if ($Count) {
                ForEach ($ResultSize in @(100,50,25,10)) {
                    if ($Count -lt $ResultSize) {
                        $ScanHistoryForm.results = $ResultSize
                    }
                }
            }

            $Results = @()
            while (-not $Done) {
                $ScanHistoryResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/scan/global/scan-history") -WebSession $Session.websession -Headers $ScanHistoryHeaders -Method Post -Body $ScanHistoryForm

                if ($ScanHistoryResponse.StatusCode -ne 200) {
                    Write-Error -Message "Failed to retrieve scan list"
                    $Done = $True
                } else {
                    $ScanCount = $ScanHistoryResponse.Content | ConvertFrom-Json | Select-Object -ExpandProperty totalRecords
                    $ScanRecords = $ScanHistoryResponse.Content | ConvertFrom-Json | Select-Object -ExpandProperty records
                    
                    if (-not $Count) {
                        $Count = $ScanCount
                    }

                    if (-not $ScanRecords) {
                        Write-Error -Message "Retrieved scan history is empty"
                        return
                    }

                    # If a Status filter was supplied, filter results
                    if ($Status) {
                        # The web JSON API returns status as letter codes. Convert status to letter codes before filtering results
                        $Status = $Status -replace "Completed","C" -replace "Stopped","S" -replace "Failed","E" -replace "Paused", "P"

                        $ScanRecords = $ScanRecords | Where-Object { $_.status -in $Status }

                        if (-not $ScanRecords) {
                            Write-Error -Message "Status filter returned no results."
                            return
                        }
                    }

                    ForEach ($ScanRecord in $ScanRecords) {
                        $Results += ConvertTo-NPScan -InputObject $ScanRecord -History
                        if ($Results.count -eq $Count) { $Done = $True; break }
                    }
                }

                # If there are more results we can parse, and we haven't hit our result count, continue querying
                if (([int]$ScanHistoryForm.results + [int]$ScanHistoryForm.startIndex) -lt $ScanCount -and $Results.count -lt $Count) {
                    $ScanHistoryForm.results = 500
                    ForEach ($ResultSize in @(500,100,50,25,10)) {
                        if (($Count - $Results.count) -lt $ResultSize) {
                            $ScanHistoryForm.results = $ResultSize
                        }
                    }
                    $ScanHistoryForm.startIndex = [int]$ScanHistoryForm.results + [int]$ScanHistoryForm.startIndex
                }
            }
            return $Results
        }

        "HistorySite" {
            $SiteScanHistoryForm = @{ sort = "endTime"; dir = "DESC"; startIndex = "0"; results = "500"; "table-id" = "site-completed-scans" }
            $SiteScanHistoryHeaders = @{
                Referer = "$($Session.baseuri)/site/scans.jsp?siteID=$SiteID"
                nexposeCCSessionID = ($Session.websession.Cookies.GetCookies("$($Session.baseuri)") | Where-Object { $_.Name -eq "nexposeCCSessionID" } | Select-Object -ExpandProperty Value)
            }
            # If a specific amount of results was requested, don't query for more results than necessary (reduce process time)
            if ($Count) {
                ForEach ($ResultSize in @(100,50,25,10)) {
                    if ($Count -lt $ResultSize) {
                        $SiteScanHistoryForm.results = $ResultSize
                    }
                }
            }

            $Results = @()
            while (-not $Done) {
                $SiteScanHistoryResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/scan/site/$SiteID") -WebSession $Session.websession -Headers $SiteScanHistoryHeaders -Method Post -Body $SiteScanHistoryForm

                
            }

            if ($SiteScanHistoryResponse.StatusCode -ne 200) {
                Write-Error -Message "Failed to retrieve scan list"
            } else {
                $SiteScans = $SiteScanHistoryResponse.Content | ConvertFrom-Json | Select-Object -ExpandProperty records

                if (-not $SiteScans) {
                    Write-Error -Message "Retrieved scan history is empty"
                    return
                }

                # If an Status filter was supplied, filter results
                if ($Status) {
                    # The web JSON API returns status as letter codes. Convert status to letter codes before filtering results
                    $Status = $Status -replace "Completed","C" -replace "Stopped","S" -replace "Failed","E" -replace "Paused", "P"

                    $SiteScans = $SiteScans | Where-Object { $_.status -in $Status }

                    if (-not $SiteScans) {
                        Write-Error -Message "Status filter returned no results."
                        return
                    }
                }

                ForEach ($Scan in $SiteScans) {
                    $Results += [PSCustomObject]@{
                        PSTypeName = "Nexpose.Scan"
                        scanID = $Scan.scanID
                        scanName = $Scan.scanName
                        status = switch ($Scan.status) { "C" { "Completed" } "S" { "Stopped" } "E" { "Failed" } "P" { "Paused" } Default { $Scan.Status } }
                        riskScore = $Scan.riskScore
                        assets = $Scan.liveHosts
                        vulnerabilities = $Scan.vulnerabilityCount
                        severeVulnerabilities = $Scan.vulnSevereCount
                        moderateVulnerabilities = $Scan.vulnModerateCount
                        criticalVulnerabilities = $Scan.vulnCriticalCount
                        scanType = if ($Scan.startedByCD -eq "S") { "Scheduled" } elseif ($Scan.startedByCD -eq "A") { "Manual" } else { $Scan.startedByCD }
                        startTime = ([DateTime]'1/1/1970').AddSeconds($Scan.startTime / 1000)
                        endTime = ([DateTime]'1/1/1970').AddSeconds($Scan.endTime / 1000)
                        duration = [System.TimeSpan]::FromMilliseconds($Scan.duration)
                        reason = $Scan.reason
                    }
                }

                return $Results
            }
        }

    }
    
    

    $ScanHistoryResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/scan/global/scan-history") -WebSession $Session.websession -Method Post -Headers $ScanHistoryHeaders -Body $ScanHistoryForm

    if ($ScanHistoryResponse.StatusCode -ne 200) {
        Write-Error -Message "Failed to retrieve scan history list"
    } else {
        $ScanHistory = $ScanHistoryResponse.Content | ConvertFrom-Json

        # If additional requests are needed for paged results, calculate the number of requests still needed
    }

    if ($SiteID) {
        $ScanResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/scan/site/$SiteID") -WebSession $Session.websession

        if ($ScanResponse.StatusCode -ne 200) {
            Write-Error -Message "Failed to retrieve scan list"
        } else {
            $ScanRecords = $ScanResponse.Content | ConvertFrom-Json | Select-Object -ExpandProperty records

            if (-not $ScanRecords) {
                Write-Error -Message "Retrieved scan list is empty"
                return
            }

            # If an Status filter was supplied, filter results
            if ($Status) {
                # The web JSON API returns status as letter codes. Convert status to letter codes before filtering results
                $Status = $Status -replace "Completed","C" -replace "Stopped","S" -replace "Failed","E" -replace "Paused", "P"

                $ScanRecords = $ScanRecords | Where-Object { $_.status -in $Status }

                if (-not $ScanRecords) {
                    Write-Error -Message "Status filter returned no results."
                    return
                }
            }

            $Results = @()
            ForEach ($Scan in $ScanRecords) {
                $Results += [PSCustomObject]@{
                    PSTypeName = "Nexpose.Scan"
                    id = $Scan.scanID
                    riskScore = $Scan.riskScore
                    assets = $Scan.liveHosts
                    vulnerabilities = $Scan.vulnerabilityCount
                    severeVulnerabilities = $Scan.vulnSevereCount
                    moderateVulnerabilities = $Scan.vulnModerateCount
                    criticalVulnerabilities = $Scan.vulnCriticalCount
                    scanType = if ($Scan.startedByCD -eq "S") { "Scheduled" } elseif ($Scan.startedByCD -eq "A") { "Manual" } else { $Scan.startedByCD }
                    name = $Scan.scanName
                    startTime = ([DateTime]'1/1/1970').AddSeconds($Scan.startTime / 1000)
                    endTime = ([DateTime]'1/1/1970').AddSeconds($Scan.endTime / 1000)
                    elapsedTime = New-TimeSpan -Start ([DateTime]'1/1/1970').AddSeconds($Scan.startTime / 1000) -End ([DateTime]'1/1/1970').AddSeconds($Scan.endTime / 1000)
                    reason = $Scan.reason
                }
            }

            return $Results
        }
    } else {

    }
}