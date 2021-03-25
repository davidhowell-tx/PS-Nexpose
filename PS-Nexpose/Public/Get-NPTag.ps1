function Get-NPTag {
    <#
    .SYNOPSIS
        Retrieve information related to Nexpose Tags
    #>
    [CmdletBinding(DefaultParameterSetName="All")]
    Param(
        # Retrieve a specific tag by its ID
        [Parameter(Mandatory=$True,ParameterSetName="TagID")]
        [String]
        $TagID,

        # Retrieve tags for a specific asset
        [Parameter(Mandatory=$True,ParameterSetName="AssetID")]
        [String]
        $AssetID,

        # Retrieve tags for a specific asset group
        [Parameter(Mandatory=$True,ParameterSetName="AssetGroupID")]
        [String]
        $AssetGroupID,

        # Retrieve tags for a specific site
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
            "AssetID" { $URI = "/api/3/assets/$AssetID/tags" }
            "AssetGroupID" { $URI = "/api/3/asset_groups/$AssetGroupID/tags"}
            "SiteID" { $URI = "/api/3/sites/$SiteID/tags" }
            "TagID" { $URI = "/api/3/tags/$TagID" }
            Default { $URI = "/api/3/tags" }
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
            "TagID" { $Tags = $Response }
            Default { $Tags = $Response.resources }
        }
        
        Write-Output $Tags | Add-CustomType -CustomTypeName "Nexpose.Tag"
    }
}