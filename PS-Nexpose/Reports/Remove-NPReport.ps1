function Remove-NPReport {
	<#
	.SYNOPSIS
		Delete a report from the Nexpose Console.

	.PARAMETER Session
		Session Object returned from Connect-NPConsole command
    
    .PARAMETER ID
        Used to specify the Report ID to delete.
	#>
	[CmdletBinding(DefaultParameterSetName="Default")]Param(
		[Parameter(Mandatory=$True)]
		$Session,

        [Parameter(Mandatory=$True)]
        [uint32]
        $ID
    )
    $Headers = @{
        Referer = "$($Session.baseuri)/report/reports.jsp"
        nexposeCCSessionID = ($Session.websession.Cookies.GetCookies("$($Session.baseuri)") | Where-Object { $_.Name -eq "nexposeCCSessionID" } | Select-Object -ExpandProperty Value)
    }
    $ReportDeleteResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/report/configs/$ID") -WebSession $Session.websession -Method Delete -Headers $Headers

    if ($ReportDeleteResponse.StatusCode -ne 200) {
        Write-Error -Message "Failed to delete report"
        return
    }

    Write-Verbose -Message "Report $ID deleted."
}