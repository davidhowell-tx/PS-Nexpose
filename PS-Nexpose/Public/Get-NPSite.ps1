function Get-NPSite {
    <#
    .SYNOPSIS
        Retrieve information related to Nexpose Sites
    #>
    [CmdletBinding(DefaultParameterSetName="All")]
    Param(
        # Retrieve a specific site by its ID
        [Parameter(Mandatory=$True,ParameterSetName="SiteID")]
        [String]
        $SiteID,

        # Retrieve sites related to a specific tag
        [Parameter(Mandatory=$True,ParameterSetName="TagID")]
        [String]
        $TagID,

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
            "SiteID" { $URI = "/api/3/sites/$SiteID" }
            "TagID" { $URI = "/api/3/tags/$TagID/sites" }
            Default { $URI = "/api/3/sites" }
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
            "SiteID" { $Sites = $Response }
            Default { $Sites = $Response.resources }
        }
        
        Write-Output $Sites | Add-CustomType -CustomTypeName "Nexpose.Site"
    }
}