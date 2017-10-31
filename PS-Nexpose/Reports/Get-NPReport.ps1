function Get-NPReport {
	<#
	.SYNOPSIS
		Get the report listing from the Nexpose Console.

	.PARAMETER Session
		Session Object returned from Connect-NPConsole command
    
    .PARAMETER ID
        Used to specify a Report ID to filter upon.
    
	.PARAMETER Name
		Used to specify a Report name to search for.
	
	.PARAMETER Config
        Switch used to include report configuration information in the response
    
	.EXAMPLE
		Get a full list of all reports with their configurations
		Get-NPReport -Session $Session -Config
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
        $Config
    )
    if ($Name) {
        $ReportsResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/report/configs?sEcho=1&iColumns=4&sColumns=id%2C%2C%2C&iDisplayStart=0&iDisplayLength=500&mDataProp_0=id.configID&mDataProp_1=&mDataProp_2=name&mDataProp_3=mostRecentReportSummary&sSearch=&bRegex=false&sSearch_0=&bRegex_0=false&bSearchable_0=true&sSearch_1=&bRegex_1=false&bSearchable_1=true&sSearch_2=&bRegex_2=false&bSearchable_2=true&sSearch_3=&bRegex_3=false&bSearchable_3=true&iSortCol_0=3&sSortDir_0=desc&iSortingCols=1&bSortable_0=false&bSortable_1=false&bSortable_2=true&bSortable_3=true&sort=mostRecentReport&searchPhrase=$Name") -WebSession $Session.websession
    } else {
        $ReportsResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/report/configs?sEcho=1&iColumns=4&sColumns=id%2C%2C%2C&iDisplayStart=0&iDisplayLength=500&mDataProp_0=id.configID&mDataProp_1=&mDataProp_2=name&mDataProp_3=mostRecentReportSummary&sSearch=&bRegex=false&sSearch_0=&bRegex_0=false&bSearchable_0=true&sSearch_1=&bRegex_1=false&bSearchable_1=true&sSearch_2=&bRegex_2=false&bSearchable_2=true&sSearch_3=&bRegex_3=false&bSearchable_3=true&iSortCol_0=3&sSortDir_0=desc&iSortingCols=1&bSortable_0=false&bSortable_1=false&bSortable_2=true&bSortable_3=true&sort=mostRecentReport") -WebSession $Session.websession
    }

    if ($ReportsResponse.StatusCode -ne 200) {
        Write-Error -Message "Failed to retrieve reports list"
        return
    }
    $Reports = $ReportsResponse.Content | ConvertFrom-Json

    if (-not $Reports) {
        Write-Error -Message "Retrieved reports list is empty"
        return
    }

    # If an ID filter was supplied, filter results
    if ($ID) {
        $Reports = $Reports | Where-Object { $_.id.configID -like $ID }

        if (-not $Reports) {
            Write-Error -Message "ID filter returned no results."
            return
        }
    }

    $Results = @()
    ForEach ($Report in $Reports.records) {
        $Result = [PSCustomObject]@{
            PSTypeName = "Nexpose.Report"
            name = $Report.name
            id = $Report.id.configID
            frequency = $Report.reportFrequency
            templateID = $Report.reportTemplateID
            lastRun = ""
            ownerID = $Report.owner
        }
        if ($Report.mostRecentReportSummary) {
            $Result.lastRun = ConvertTo-DateTime -InputObject $Report.mostRecentReportSummary.generatedOn -MS
        }
        $Results += $Result
    }

    # If Report Configuration was requested, pull additional data
    if ($Config) {
        ForEach ($Report in $Results) {
            $ReportConfigResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/report/configs/$($Report.id)") -WebSession $Session.websession

            if ($ReportConfigResponse.StatusCode -ne 200) {
                Write-Error -Message "Failed to retrieve report configuration"
                return
            }
            $ReportConfig = $ReportConfigResponse.Content | ConvertFrom-Json
            Add-Member -InputObject $Report -MemberType NoteProperty -Name ownerName -Value $ReportConfig.ownerName
            Add-Member -InputObject $Report -MemberType NoteProperty -Name ownerEmail -Value $ReportConfig.ownerEmail
            Add-Member -InputObject $Report -MemberType NoteProperty -Name ownerLogin -Value $ReportConfig.ownerLogin
            Add-Member -InputObject $Report -MemberType NoteProperty -Name smtpserver -Value $ReportConfig.smtpserver
            Add-Member -InputObject $Report -MemberType NoteProperty -Name emailSender -Value $ReportConfig.emailSender
            Add-Member -InputObject $Report -MemberType NoteProperty -Name recipients -Value $ReportConfig.recipients

            # Format Scan Schedules
            $ReportSchedule = @()
            ForEach ($Schedule in $ReportConfig.schedule.repeaters.repeater) {
                $ReportSchedule += ConvertFrom-NPRepeater -InputObject $Schedule
            }
            Add-Member -InputObject $Report -MemberType NoteProperty -Name reportSchedule -Value $ReportSchedule

            # Format selected scope
            $Scope = @()
            ForEach ($AssetGroup in $ReportConfig.assetGroups) {
                $Scope += [PSCustomObject]@{
                    type = "assetGroup"
                    id = $AssetGroup
                }
            }
            ForEach ($Site in $ReportConfig.sites) {
                $Scope += [PSCustomObject]@{
                    type = "site"
                    id = $Site
                }
            }
            ForEach ($Scan in $ReportConfig.scans) {
                $Scope += [PSCustomObject]@{
                    type = "scan"
                    id = $Scan
                }
            }
            ForEach ($Tag in $ReportConfig.tags) {
                $Scope += [PSCustomObject]@{
                    type = "tag"
                    id = $Tag
                }
            }
        }
    }

    return $Results
}