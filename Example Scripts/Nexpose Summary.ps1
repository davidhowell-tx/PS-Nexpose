Import-Module ..\PS-Nexpose.psm1 -Force
$Session = Connect-NPConsole

if (-not $Session) {
    Write-Error -Message "Unable to establish a session with the Nexpose console. Exiting script."
} else {
    # Instantiate Excel COM Object
    $xl = New-Object -ComObject Excel.Application
    $xl.Visible = $True
    $Workbook = $xl.Workbooks.Add()

    $AssetGroups = Get-NPAssetGroup -Session $Session
    $Credentials = Get-NPCredential -Session $Session
    $ScanEngines = Get-NPScanEngine -Session $Session
    $ScanPools = Get-NPScanPool -Session $Session
    $Sites = Get-NPSite -Session $Session -Config
    $Users = Get-NPUser -Session $Session

    # Create a Scan Schedule List
    $ScanSchedule = @()
    for ($i = 0; $i -lt $Sites.Count; $i++) {
        for ($j = 0; $j -lt $Sites[$i].scanSchedule.Count; $j++) {
            $Object = $Sites[$i].scanSchedule[$j]
            Add-Member -InputObject $Object -MemberType NoteProperty -Name name -Value $Sites[$i].name
            $ScanSchedule += $Object
        }
    }

    # Asset Group Information
    $WSAssetGroups = $Workbook.Worksheets.Add()
    $WSAssetGroups.Name = "Asset Groups"
    $WSAssetGroups.Cells.Item(1,1) = "Name"
    $WSAssetGroups.Cells.Item(1,2) = "Description"
    $WSAssetGroups.Cells.Item(1,3) = "Dynamic"
    $WSAssetGroups.Cells.Item(1,4) = "Device Count"
    $WSAssetGroups.Cells.Item(1,5) = "Risk Score"
    $WSAssetGroups.Cells.Item(1,6) = "Vulnerabilities"
    $WSAssetGroups.Cells.Item(1,1).Font.Bold = $True
    $WSAssetGroups.Cells.Item(1,2).Font.Bold = $True
    $WSAssetGroups.Cells.Item(1,3).Font.Bold = $True
    $WSAssetGroups.Cells.Item(1,4).Font.Bold = $True
    $WSAssetGroups.Cells.Item(1,5).Font.Bold = $True
    $WSAssetGroups.Cells.Item(1,6).Font.Bold = $True
    for ($i = 0; $i -lt $AssetGroups.Count; $i++) {
        $WSAssetGroups.Cells.Item(2+$i,1) = $AssetGroups[$i].GroupName
        $WSAssetGroups.Cells.Item(2+$i,2) = $AssetGroups[$i].GroupTag
        if ($AssetGroups[$i].IsDynamic -eq 1) {
            $WSAssetGroups.Cells.Item(2+$i,3) = "Yes"
        } else {
            $WSAssetGroups.Cells.Item(2+$i,3) = "No"
        }
        $WSAssetGroups.Cells.Item(2+$i,4) = $AssetGroups[$i].ScannedDevices
        $WSAssetGroups.Cells.Item(2+$i,5) = $AssetGroups[$i].Risk
        $WSAssetGroups.Cells.Item(2+$i,6) = $AssetGroups[$i].Vulnerabilities
    }
    $WSAssetGroupsUsedRange = $WSAssetGroups.UsedRange
    $WSAssetGroupsUsedRange.EntireColumn.AutoFit()
    $WSAssetGroupsUsedRange.Rows.AutoFit()

    # Credential Information
    $WSCredentials = $Workbook.Worksheets.Add()
    $WSCredentials.Name = "Credentials"
    $WSCredentials.Cells.Item(1,1) = "Name"
    $WSCredentials.Cells.Item(1,2) = "Username"
    $WSCredentials.Cells.Item(1,3) = "Domain"
    $WSCredentials.Cells.Item(1,4) = "Service"
    $WSCredentials.Cells.Item(1,5) = "Scope"
    $WSCredentials.Cells.Item(1,6) = "Last Modified"
    $WSCredentials.Cells.Item(1,1).Font.Bold = $True
    $WSCredentials.Cells.Item(1,2).Font.Bold = $True
    $WSCredentials.Cells.Item(1,3).Font.Bold = $True
    $WSCredentials.Cells.Item(1,4).Font.Bold = $True
    $WSCredentials.Cells.Item(1,5).Font.Bold = $True
    $WSCredentials.Cells.Item(1,6).Font.Bold = $True
    for ($i = 0; $i -lt $Credentials.Count; $i++) {
        $WSCredentials.Cells.Item(2+$i,1) = $Credentials[$i].name
        $WSCredentials.Cells.Item(2+$i,2) = $Credentials[$i].username
        $WSCredentials.Cells.Item(2+$i,3) = $Credentials[$i].domain
        $WSCredentials.Cells.Item(2+$i,4) = $Credentials[$i].service
        $WSCredentials.Cells.Item(2+$i,5) = $Credentials[$i].scope
        $WSCredentials.Cells.Item(2+$i,6) = $Credentials[$i].lastModified
    }
    $WSCredentialsUsedRange = $WSCredentials.UsedRange
    $WSCredentialsUsedRange.EntireColumn.AutoFit()

    # Scan Engines Information
    $WSScanEngines = $Workbook.Worksheets.Add()
    $WSScanEngines.Name = "Scan Engines"
    $WSScanEngines.Cells.Item(1,1) = "Name"
    $WSScanEngines.Cells.Item(1,2) = "Address"
    $WSScanEngines.Cells.Item(1,3) = "Status"
    $WSScanEngines.Cells.Item(1,4) = "Operating System"
    $WSScanEngines.Cells.Item(1,5) = "Scan Pool"
    $WSScanEngines.Cells.Item(1,1).Font.Bold = $True
    $WSScanEngines.Cells.Item(1,2).Font.Bold = $True
    $WSScanEngines.Cells.Item(1,3).Font.Bold = $True
    $WSScanEngines.Cells.Item(1,4).Font.Bold = $True
    $WSScanEngines.Cells.Item(1,5).Font.Bold = $True
    for ($i = 0; $i -lt $ScanEngines.Count; $i++) {
        $WSScanEngines.Cells.Item(2+$i,1) = $ScanEngines[$i].name
        $WSScanEngines.Cells.Item(2+$i,2) = $ScanEngines[$i].address
        $WSScanEngines.Cells.Item(2+$i,3) = $ScanEngines[$i].status
        $WSScanEngines.Cells.Item(2+$i,4) = $ScanEngines[$i].os
        ForEach ($ScanPool in $ScanPools) {
            if ($ScanEngines[$i].id -in $ScanPool.scanEngines.id) {
                if ($WSScanEngines.Cells.Item(2+$i,5).Text) {
                    $WSScanEngines.Cells.Item(2+$i,5) = $WSScanEngines.Cells.Item(2+$i,5) + ", " + $ScanPool.name
                } else {
                    $WSScanEngines.Cells.Item(2+$i,5) = $ScanPool.name
                }
            }
        }
    }
    $WSScanEngines = $WSScanEngines.UsedRange
    $WSScanEngines.EntireColumn.AutoFit()

    # Site Information
    $WSSites = $Workbook.Worksheets.Add()
    $WSSites.Name = "Sites"
    $WSSites.Cells.Item(1,1) = "Name"
    $WSSites.Cells.Item(1,2) = "Description"
    $WSSites.Cells.Item(1,3) = "Scan Template"
    $WSSites.Cells.Item(1,4) = "Risk Score"
    $WSSites.Cells.Item(1,5) = "Moderate Vulnerabilities"
    $WSSites.Cells.Item(1,6) = "Critical Vulnerabilities"
    $WSSites.Cells.Item(1,7) = "Severe Vulnerabilities"
    $WSSites.Cells.Item(1,8) = "Total Vulnerabilities"
    $WSSites.Cells.Item(1,1).Font.Bold = $True
    $WSSites.Cells.Item(1,2).Font.Bold = $True
    $WSSites.Cells.Item(1,3).Font.Bold = $True
    $WSSites.Cells.Item(1,4).Font.Bold = $True
    $WSSites.Cells.Item(1,5).Font.Bold = $True
    $WSSites.Cells.Item(1,6).Font.Bold = $True
    $WSSites.Cells.Item(1,7).Font.Bold = $True
    $WSSites.Cells.Item(1,8).Font.Bold = $True
    for ($i = 0; $i -lt $Sites.Count; $i++) {
        $WSSites.Cells.Item(2+$i,1) = $Sites[$i].name
        $WSSites.Cells.Item(2+$i,2) = $Sites[$i].description
        $WSSites.Cells.Item(2+$i,3) = $Sites[$i].scanTemplate
        $WSSites.Cells.Item(2+$i,4) = $Sites[$i].riskScore
        $WSSites.Cells.Item(2+$i,5) = $Sites[$i].moderateVulns
        $WSSites.Cells.Item(2+$i,6) = $Sites[$i].criticalVulns
        $WSSites.Cells.Item(2+$i,7) = $Sites[$i].severeVulns
        $WSSites.Cells.Item(2+$i,8) = $Sites[$i].totalVulns
    }
    $WSSitesUsedRange = $WSSites.UsedRange
    $WSSitesUsedRange.EntireColumn.AutoFit()


    # Scan Timeline
    $WSScanTimeline = $Workbook.Worksheets.Add()
    $WSScanTimeline.Name = "Scan List"
    $WSScanTimeline.Cells.Item(1,1) = "Site Name"
    $WSScanTimeline.Cells.Item(1,2) = "Scan Name"
    $WSScanTimeline.Cells.Item(1,3) = "Day of Week"
    $WSScanTimeline.Cells.Item(1,4) = "Time"
    $WSScanTimeline.Cells.Item(1,5) = "Allowed Duration"
    $WSScanTimeline.Cells.Item(1,6) = "Average Duration"
    $WSScanTimeline.Cells.Item(1,1).Font.Bold = $True
    $WSScanTimeline.Cells.Item(1,2).Font.Bold = $True
    $WSScanTimeline.Cells.Item(1,3).Font.Bold = $True
    $WSScanTimeline.Cells.Item(1,4).Font.Bold = $True
    $WSScanTimeline.Cells.Item(1,5).Font.Bold = $True
    $WSScanTimeline.Cells.Item(1,6).Font.Bold = $True
    $WSScanTimelineUsedRange = $WSScanTimeline.UsedRange
    $WSScanTimelineUsedRange.EntireColumn.AutoFit()

    # Scan List
    $WSScans = $Workbook.Worksheets.Add()
    $WSScans.Name = "Scan List"
    $WSScans.Cells.Item(1,1) = "Site Name"
    $WSScans.Cells.Item(1,2) = "Scan Name"
    $WSScans.Cells.Item(1,3) = "Enabled"
    $WSScans.Cells.Item(1,4) = "Recurrence"
    $WSScans.Cells.Item(1,5) = "Next Run"
    $WSScans.Cells.Item(1,6) = "First Run"
    $WSScans.Cells.Item(1,1).Font.Bold = $True
    $WSScans.Cells.Item(1,2).Font.Bold = $True
    $WSScans.Cells.Item(1,3).Font.Bold = $True
    $WSScans.Cells.Item(1,4).Font.Bold = $True
    $WSScans.Cells.Item(1,5).Font.Bold = $True
    $WSScans.Cells.Item(1,6).Font.Bold = $True
    for ($i = 0; $i -lt $ScanSchedule.Count; $i++) {
        $WSScans.Cells.Item($i+2,1) = $ScanSchedule[$i].name
        $WSScans.Cells.Item($i+2,2) = $ScanSchedule[$i].scanName
        $WSScans.Cells.Item($i+2,3) = $ScanSchedule[$i].enabled
        $WSScans.Cells.Item($i+2,4) = $ScanSchedule[$i].frequency
        $WSScans.Cells.Item($i+2,5) = $ScanSchedule[$i].nextRunTime
        $WSScans.Cells.Item($i+2,6) = $ScanSchedule[$i].startTime
    }
    $WSScansUsedRange = $WSScans.UsedRange
    $WSScansUsedRange.EntireColumn.AutoFit()


    # Scan Schedule
    $WSScanSchedule = $Workbook.Worksheets.Add()
    $WSScanSchedule.Name = "Scan Schedule"
    $WSScanSchedule.Cells.Item(1,1) = "Sunday"
    $WSScanSchedule.Cells.Item(1,2) = "Monday"
    $WSScanSchedule.Cells.Item(1,3) = "Tuesday"
    $WSScanSchedule.Cells.Item(1,4) = "Wednesday"
    $WSScanSchedule.Cells.Item(1,5) = "Thursday"
    $WSScanSchedule.Cells.Item(1,6) = "Friday"
    $WSScanSchedule.Cells.Item(1,7) = "Saturday"
    $WSScanSchedule.Cells.Item(1,1).Font.Bold = $True
    $WSScanSchedule.Cells.Item(1,2).Font.Bold = $True
    $WSScanSchedule.Cells.Item(1,3).Font.Bold = $True
    $WSScanSchedule.Cells.Item(1,4).Font.Bold = $True
    $WSScanSchedule.Cells.Item(1,5).Font.Bold = $True
    $WSScanSchedule.Cells.Item(1,6).Font.Bold = $True
    $WSScanSchedule.Cells.Item(1,7).Font.Bold = $True
    $EnabledScans = $ScanSchedule | Where-Object { $_.enabled -eq "True" }
    $EnabledScans | ForEach-Object {
        Add-Member -InputObject $_ -MemberType NoteProperty -Name order -Value $_.startTime.ToLocalTime().ToString("hh")
    }
    $Sunday = $EnabledScans | Where-Object { $_.scheduleType -like "Daily at*" -or $_.scheduleType -like "Weekly on Sunday*" } | Sort-Object -Property order
    $Monday = $EnabledScans | Where-Object { $_.scheduleType -like "Daily at*" -or $_.scheduleType -like "Weekly on Monday*" } | Sort-Object -Property order
    $Tuesday = $EnabledScans | Where-Object { $_.scheduleType -like "Daily at*" -or $_.scheduleType -like "Weekly on Tuesday*" } | Sort-Object -Property order
    $Wednesday = $EnabledScans | Where-Object { $_.scheduleType -like "Daily at*" -or $_.scheduleType -like "Weekly on Wednesday*" } | Sort-Object -Property order
    $Thursday = $EnabledScans | Where-Object { $_.scheduleType -like "Daily at*" -or $_.scheduleType -like "Weekly on Thursday*" } | Sort-Object -Property order
    $Friday = $EnabledScans | Where-Object { $_.scheduleType -like "Daily at*" -or $_.scheduleType -like "Weekly on Friday*" } | Sort-Object -Property order
    $Saturday = $EnabledScans | Where-Object { $_.scheduleType -like "Daily at*" -or $_.scheduleType -like "Weekly on Saturday*" } | Sort-Object -Property order
    
    
    $WSScansUsedRange = $WSScans.UsedRange
    $WSScansUsedRange.EntireColumn.AutoFit()


    # Site Level Alerts
    $WSSiteLevelAlerts = $Workbook.Worksheets.Add()
    $WSSiteLevelAlerts.Name = "Site-Level Alerts"
    $WSSiteLevelAlerts.Cells.Item(1,1) = "Site Name"
    $WSSiteLevelAlerts.Cells.Item(1,2) = "Alert Name"
    $WSSiteLevelAlerts.Cells.Item(1,3) = "Server"
    $WSSiteLevelAlerts.Cells.Item(1,4) = "Enabled"
    $WSSiteLevelAlerts.Cells.Item(1,5) = "Service Type"
    $WSSiteLevelAlerts.Cells.Item(1,6) = "From Address"
    $WSSiteLevelAlerts.Cells.Item(1,7) = "Recipients"
    $WSSiteLevelAlerts.Cells.Item(1,8) = "Scan Started"
    $WSSiteLevelAlerts.Cells.Item(1,9) = "Scan Paused"
    $WSSiteLevelAlerts.Cells.Item(1,10) = "Scan Resumed"
    $WSSiteLevelAlerts.Cells.Item(1,11) = "Scan Failed"
    $WSSiteLevelAlerts.Cells.Item(1,12) = "Scan Stopped"
    $WSSiteLevelAlerts.Cells.Item(1,1).Font.Bold = $True
    $WSSiteLevelAlerts.Cells.Item(1,2).Font.Bold = $True
    $WSSiteLevelAlerts.Cells.Item(1,3).Font.Bold = $True
    $WSSiteLevelAlerts.Cells.Item(1,4).Font.Bold = $True
    $WSSiteLevelAlerts.Cells.Item(1,5).Font.Bold = $True
    $WSSiteLevelAlerts.Cells.Item(1,6).Font.Bold = $True
    $WSSiteLevelAlerts.Cells.Item(1,7).Font.Bold = $True
    $WSSiteLevelAlerts.Cells.Item(1,8).Font.Bold = $True
    $WSSiteLevelAlerts.Cells.Item(1,9).Font.Bold = $True
    $WSSiteLevelAlerts.Cells.Item(1,10).Font.Bold = $True
    $WSSiteLevelAlerts.Cells.Item(1,11).Font.Bold = $True
    $WSSiteLevelAlerts.Cells.Item(1,12).Font.Bold = $True
    $Row = 2
    for ($i = 0; $i -lt $Sites.Count; $i++) {
        ForEach ($Alert in $Sites[$i].alertConfigs) {
            $WSSiteLevelAlerts.Cells.Item($Row,1) = $Sites[$i].name
            $WSSiteLevelAlerts.Cells.Item($Row,2) = $Alert.name
            $WSSiteLevelAlerts.Cells.Item($Row,3) = $Alert.server
            $WSSiteLevelAlerts.Cells.Item($Row,4) = $Alert.enabled
            $WSSiteLevelAlerts.Cells.Item($Row,5) = $Alert.serviceType
            $WSSiteLevelAlerts.Cells.Item($Row,6) = $Alert.fromAddress
            $WSSiteLevelAlerts.Cells.Item($Row,7) = $Alert.recipients -join ", "
            $WSSiteLevelAlerts.Cells.Item($Row,8) = $Alert.scanFilter.scanStart
            $WSSiteLevelAlerts.Cells.Item($Row,9) = $Alert.scanFilter.scanPause
            $WSSiteLevelAlerts.Cells.Item($Row,10) = $Alert.scanFilter.scanResume
            $WSSiteLevelAlerts.Cells.Item($Row,11) = $Alert.scanFilter.scanFailed
            $WSSiteLevelAlerts.Cells.Item($Row,12) = $Alert.scanFilter.scanStop
            $Row++
        }
    }
    $WSSiteLevelAlertsUsedRange = $WSSiteLevelAlerts.UsedRange
    $WSSiteLevelAlertsUsedRange.EntireColumn.AutoFit()


    # Site Level Credentials
    $WSSiteLevelCredentials = $Workbook.Worksheets.Add()
    $WSSiteLevelCredentials.Name = "Site-Level Credentials"
    $WSSiteLevelCredentials.Cells.Item(1,1) = "Site Name"
    $WSSiteLevelCredentials.Cells.Item(1,1).Font.Bold = $True
    for ($i = 0; $i -lt $Credentials.count; $i++) {
        $WSSiteLevelCredentials.Cells.Item(1,2+$i) = $Credentials[$i].name
        $WSSiteLevelCredentials.Cells.Item(1,2+$i).Font.Bold = $True
    }
    for ($i = 0; $i -lt $Sites.Count; $i++) {
        for ($j = 0; $j -lt $Credentials.count; $j++) {
            $WSSiteLevelCredentials.Cells.Item($i+2,1) = $Sites[$i].name
            if ($Credentials[$j].id -in $Sites[$i].scanCredentials.credentialID) {
                $WSSiteLevelCredentials.Cells.Item($i+2,$j+2) = "TRUE"
                $WSSiteLevelCredentials.Cells.Item($i+2,$j+2).Interior.Color = 14348258
            }
        }
    }
    $WSSiteLevelCredentialsUsedRange = $WSSiteLevelCredentials.UsedRange
    $WSSiteLevelCredentialsUsedRange.EntireColumn.AutoFit()


    # Site Level Permissions
    $WSSiteLevelPermissions = $Workbook.Worksheets.Add()
    $WSSiteLevelPermissions.Name = "Site-Level Permissions"
    $WSSiteLevelPermissions.Cells.Item(1,1) = "Site Name"
    $WSSiteLevelPermissions.Cells.Item(1,2) = "Username"
    $WSSiteLevelPermissions.Cells.Item(1,3) = "Full Name"
    $WSSiteLevelPermissions.Cells.Item(1,4) = "Email"
    $WSSiteLevelPermissions.Cells.Item(1,5) = "Authenticator"
    $WSSiteLevelPermissions.Cells.Item(1,1).Font.Bold = $True
    $WSSiteLevelPermissions.Cells.Item(1,2).Font.Bold = $True
    $WSSiteLevelPermissions.Cells.Item(1,3).Font.Bold = $True
    $WSSiteLevelPermissions.Cells.Item(1,4).Font.Bold = $True
    $WSSiteLevelPermissions.Cells.Item(1,5).Font.Bold = $True
    $Row = 2
    for ($i = 0; $i -lt $Sites.Count; $i++) {
        ForEach ($User in $Sites[$i].users) {
            $User = $Users | Where-Object { $_.UserID -eq $User }
            $WSSiteLevelPermissions.Cells.Item($Row,1) = $Sites[$i].name
            $WSSiteLevelPermissions.Cells.Item($Row,2) = $User.UserName
            $WSSiteLevelPermissions.Cells.Item($Row,3) = $User.FullName
            $WSSiteLevelPermissions.Cells.Item($Row,4) = $User.Email
            $WSSiteLevelPermissions.Cells.Item($Row,5) = $User.Authenticator
            $Row++
        }
    }
    $WSSiteLevelPermissionsUsedRange = $WSSiteLevelPermissions.UsedRange
    $WSSiteLevelPermissionsUsedRange.EntireColumn.AutoFit()

    $Sheet1 = $Workbook.Worksheets.Item("Sheet1")
    $Sheet1.delete()

    


    #$Exclusions = @()
    #for ($i = 2; $i -le $Rows; $i++) {
    #    $Exclusions += $Worksheet.Cells.Item($i,1).text
    #}

    # $xl.quit()


    # Upload th Exclusions list to Nexpose
    # TODO

}