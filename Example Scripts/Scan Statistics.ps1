Import-Module ..\PS-Nexpose.psm1 -Force
$Session = Connect-NPConsole

if (-not $Session) {
    Write-Error -Message "Unable to establish a session with the Nexpose console. Exiting script."
} else {
    # Instantiate Excel COM Object
    $xl = New-Object -ComObject Excel.Application
    $xl.Visible = $True
    $Workbook = $xl.Workbooks.Add()

    $Scans = Get-NPScan -Session $Session -History
    $Sites = Get-NPSite -Session $Session -Config
    $ScannedSites = $Scans | Select-Object -ExpandProperty siteName -Unique

    $WSScanStatistics = $Workbook.Worksheets.Add()
    $WSScanStatistics.Name = "Scan Statistics"
    $WSScanStatistics.Cells.Item(1,1) = "Site Name"
    $WSScanStatistics.Cells.Item(1,2) = "Scan Start"
    $WSScanStatistics.Cells.Item(1,3) = "Average Duration"
    $WSScanStatistics.Cells.Item(1,1).Font.Bold = $True
    $WSScanStatistics.Cells.Item(1,2).Font.Bold = $True
    $WSScanStatistics.Cells.Item(1,3).Font.Bold = $True
    for ($i = 0; $i -lt $ScannedSites.Count; $i++) {
        $WSScanStatistics.Cells.Item(2+$i,1) = $ScannedSites[$i]
        $Site = $Sites  | Where-Object { $_.name -eq $ScannedSites[$i] }
        $FullAuditScan = $Site.scanSchedule | Where-Object { $_.scanName -like "*- Full Audit" }
        $WSScanStatistics.Cells.Item(2+$i,2) = $FullAuditScan.scheduleType
        $SiteScans = $Scans | Where-Object { $_.siteName -eq $ScannedSites[$i] }
        $SiteScans | ForEach-Object {
            $Timespan += New-TimeSpan -Start $_.startTime -End $_.endTime
        }
        if ($SiteScans.count) {
            $AverageDuration = New-TimeSpan -Seconds ($TimeSpan.TotalSeconds / $SiteScans.count)
        } else {
            $AverageDuration = $TimeSpan
        }
        $WSScanStatistics.Cells.Item(2+$i,3) = $AverageDuration.ToString()
        $WSScanStatistics.Cells.Item(2+$i,3).NumberFormat = "dd `"days`", hh `"hours,`" mm `"minutes,`" ss `"seconds`""
        Remove-Variable Timespan
        Remove-Variable AverageDuration
    }


    $WSScanHistory = $Workbook.Worksheets.Add()
    $WSScanHistory.Name = "Scan History"
    $WSScanHistory.Cells.Item(1,1) = "Site Name"
    $WSScanHistory.Cells.Item(1,2) = "Scan Name"
    $WSScanHistory.Cells.Item(1,3) = "Status"
    $WSScanHistory.Cells.Item(1,4) = "Risk Score"
    $WSScanHistory.Cells.Item(1,5) = "Vulnerabilities"
    $WSScanHistory.Cells.Item(1,6) = "Moderate Vulnerabilities"
    $WSScanHistory.Cells.Item(1,7) = "Severe Vulnerabilities"
    $WSScanHistory.Cells.Item(1,8) = "Critical Vulnerabilities"
    $WSScanHistory.Cells.Item(1,9) = "Start Time"
    $WSScanHistory.Cells.Item(1,10) = "End Time"
    $WSScanHistory.Cells.Item(1,11) = "Duration"
    $WSScanHistory.Cells.Item(1,1).Font.Bold = $True
    $WSScanHistory.Cells.Item(1,2).Font.Bold = $True
    $WSScanHistory.Cells.Item(1,3).Font.Bold = $True
    $WSScanHistory.Cells.Item(1,4).Font.Bold = $True
    $WSScanHistory.Cells.Item(1,5).Font.Bold = $True
    $WSScanHistory.Cells.Item(1,6).Font.Bold = $True
    $WSScanHistory.Cells.Item(1,7).Font.Bold = $True
    $WSScanHistory.Cells.Item(1,8).Font.Bold = $True
    $WSScanHistory.Cells.Item(1,9).Font.Bold = $True
    $WSScanHistory.Cells.Item(1,10).Font.Bold = $True
    $WSScanHistory.Cells.Item(1,11).Font.Bold = $True
    for ($i = 0; $i -lt $Scans.Count; $i++) {
        $WSScanHistory.Cells.Item(2+$i,1) = $Scans[$i].siteName
        $WSScanHistory.Cells.Item(2+$i,2) = $Scans[$i].scanName
        $WSScanHistory.Cells.Item(2+$i,3) = $Scans[$i].status
        $WSScanHistory.Cells.Item(2+$i,4) = $Scans[$i].riskScore
        $WSScanHistory.Cells.Item(2+$i,5) = $Scans[$i].Vulnerabilities
        $WSScanHistory.Cells.Item(2+$i,6) = $Scans[$i].moderateVulnerabilities
        $WSScanHistory.Cells.Item(2+$i,7) = $Scans[$i].severeVulnerabilities
        $WSScanHistory.Cells.Item(2+$i,8) = $Scans[$i].criticalVulnerabilities
        $WSScanHistory.Cells.Item(2+$i,9) = $Scans[$i].startTime
        $WSScanHistory.Cells.Item(2+$i,10) = $Scans[$i].endTime
        $WSScanHistory.Cells.Item(2+$i,11) = $Scans[$i].duration.ToString()
    }
}