function Get-NPScanEnginePool {
    <#
    .SYNOPSIS
        Retrieve information related to Nexpose Scan Engine Pools
    #>
    [CmdletBinding(DefaultParameterSetName="All")]
    Param(
        # Retrieve a specific Scan Engine Pool by its ID
        [Parameter(Mandatory=$True,ParameterSetName="ScanEnginePoolID")]
        [String]
        $ScanEnginePoolID,

        # Retrieve scan engine pools linked to a specific scan engine
        [Parameter(Mandatory=$True,ParameterSetName="ScanEngineID")]
        [String]
        $ScanEngineID,

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
            "ScanEnginePoolID" { $URI = "/api/3/scan_engine_pools/$ScanEnginePoolID" }
            "ScanEngineID" { $URI = "/api/3/scan_engines/$ScanEngineID/scan_engine_pools" }
            Default { $URI = "/api/3/scan_engine_pools" }
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
            "ScanEnginePoolID" { $ScanEnginePools = $Response }
            Default { $ScanEnginePools = $Response.resources }
        }
        
        Write-Output $ScanEnginePools | Add-CustomType -CustomTypeName "Nexpose.ScanEnginePool"
    }
}