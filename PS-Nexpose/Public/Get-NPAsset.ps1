function Get-NPAsset {
    <#
    .SYNOPSIS
        Retrieve information related to Nexpose Assets
    #>
    [CmdletBinding(DefaultParameterSetName="All")]
    Param(
        # Retrieve a specific asset by its ID
        [Parameter(Mandatory=$True,ParameterSetName="AssetID")]
        [String]
        $AssetID,

        # Retrieve assets for a specific Site
        [Parameter(Mandatory=$True,ParameterSetName="SiteID")]
        [String]
        $SiteID,

        # Retrieve assets for a specific Tag
        [Parameter(Mandatory=$True,ParameterSetName="TagID")]
        [String]
        $TagID,

        # Retrieve assets for a specific Vulnerability
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
            "AssetID" { $URI = "/api/3/assets/$AssetID" }
            "SiteID" { $URI = "/api/3/sites/$SiteID/assets" }
            "TagID" { $URI = "/api/3/tags/$TagID/assets" }
            "VulnerabilityID" { $URI = "/api/3/vulnerabilities/$VulnerabilityID/assets" }
            Default { $URI = "/api/3/assets" }
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
            "AssetID" {
                $Assets = $Response
            }
            "TagID" {
                $Assets = $Response.links | Where-Object { $_.rel -eq "Asset" } | ForEach-Object { Invoke-NPQuery -DirectLink $_.href }
            }
            "VulnerabilityID" {
                $Assets = $Response.links | Where-Object { $_.rel -eq "Asset" } | ForEach-Object { Invoke-NPQuery -DirectLink $_.href }
            }
            Default {
                $Assets = $Response.resources
            }
        }
        
        Write-Output $Assets | Add-CustomType -CustomTypeName "Nexpose.Asset"
    }
}