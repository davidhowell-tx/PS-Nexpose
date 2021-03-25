function Get-NPAssetGroup {
    <#
    .SYNOPSIS
        Retrieve information related to Nexpose Asset Groups
    #>
    [CmdletBinding(DefaultParameterSetName="All")]
    Param(
        # Retrieve a specific Asset Group by its ID
        [Parameter(Mandatory=$True,ParameterSetName="AssetGroupID")]
        [String]
        $AssetGroupID,

        # Retrieve Asset Groups related to a specific Tag
        [Parameter(Mandatory=$True,ParameterSetName="TagID")]
        [String]
        $TagID,

        # Filter results by asset group type (static, dynamic)
        [Parameter(Mandatory=$False,ParameterSetName="All")]
        [Parameter(Mandatory=$False,ParameterSetName="Count")]
        [ValidateSet("dynamic", "static")]
        [String]
        $Type,

        # Filter results by case insensitive search string
        [Parameter(Mandatory=$False,ParameterSetName="All")]
        [Parameter(Mandatory=$False,ParameterSetName="Count")]
        [String]
        $Name,

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
            "AssetGroupID" { $URI = "/api/3/asset_groups/$AssetGroupID" }
            "TagID" { $URI = "/api/3/tags/$TagID/asset_groups" }
            Default { $URI = "/api/3/asset_groups" }
        }

        $Parameters = @{}
        if ($Type) { $Parameters.Add("type", $Type) }
        if ($Name) { $Parameters.Add("name", $Name) }
        $Request = @{
            URI = $URI
            Method = "Get"
            Parameters = $Parameters
        }
        if ($Count) {
            $Request.Add("Count", $Count)
        } else {
            $Request.Add("Recurse", $True)
        }

        $Response = Invoke-NPQuery @Request

        switch ($PSCmdlet.ParameterSetName) {
            "AssetGroupID" { $AssetGroups = $Response }
            Default { $AssetGroups = $Response.resources }
        }

        Write-Output $AssetGroups | Add-CustomType -CustomTypeName "Nexpose.AssetGroup"
    }
}