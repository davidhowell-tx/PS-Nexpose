function Get-NPScanEngine {
    <#
    .SYNOPSIS
        Retrieve information related to Nexpose Scan Engines
    #>
    [CmdletBinding(DefaultParameterSetName="All")]
    Param(
        # Retrieve a specific Scan Engine by its ID
        [Parameter(Mandatory=$True,ParameterSetName="ScanEngineID")]
        [String]
        $ScanEngineID,

        # Retrieve the scan engine for a specific site
        [Parameter(Mandatory=$True,ParameterSetName="SiteID")]
        [String]
        $SiteID,

        # Specify to only retrieve a specific number of results
        [Parameter(Mandatory=$True,ParameterSetName="Count")]
        [Uint32]
        $Count
    )
    Process {
        # Log the function and parameters being executed
        $InitializationLog = $MyInvocation.MyCommand.Name
        $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { $InitializationLog = $InitializationLog + " -$($_.Key) $($_.Value)"}
        Write-Log -Message $InitializationLog -Level Informational

        switch ($PSCmdlet.ParameterSetName) {
            "ScanEngineID" { $URI = "/api/3/scan_engines/$ScanEngineID" }
            "SiteID" { $URI = "/api/3/sites/$SiteID/scan_engine" }
            Default { $URI = "/api/3/scan_engines" }
        }

        $Request = @{
            URI = $URI
            Method = "Get"
        }
        if ($Count) {
            $Request.Add("Count", $Count)
        } else {
            $Request.Add("Recurse", $True)
        }
        $Response = Invoke-NPQuery @Request

        switch ($PSCmdlet.ParameterSetName) {
            "ScanEngineID" { $ScanEngines = $Response }
            "SiteID" { $ScanEngines = $Response }
            Default { $ScanEngines = $Response.resources }
        }
        
        Write-Output $ScanEngines | Add-CustomType -CustomTypeName "Nexpose.ScanEngine"
    }
}