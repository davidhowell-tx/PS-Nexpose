function Get-NPSolution {
    <#
    .SYNOPSIS
        Retrieve information related to Nexpose Solution entries
    #>
    [CmdletBinding(DefaultParameterSetName="All")]
    Param(
        # Retrieve a specific Solution by its ID
        [Parameter(Mandatory=$True,ParameterSetName="SolutionID")]
        [String]
        $SolutionID,

        # Retrieve solutions for a specific vulnerability
        [Parameter(Mandatory=$True,ParameterSetName="VulnerabilityID")]
        [String]
        $VulnerabilityID,

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
            "SolutionID" { $URI = "/api/3/solutions/$SolutionID" }
            "VulnerabilityID" { $URI = "/api/3/vulnerabilities/$VulnerabilityID/solutions" }
            Default { $URI = "/api/3/malware_kits" }
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
            "SolutionID" { $Solutions = $Response }
            Default { $Solutions = $Response.resources }
        }
        
        Write-Output $Solutions | Add-CustomType -CustomTypeName "Nexpose.Solution"
    }
}