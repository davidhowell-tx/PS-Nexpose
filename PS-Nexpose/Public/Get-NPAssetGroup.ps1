function Get-NPAssetGroup {
    <#
    .SYNOPSIS
        Retrieve information related to Nexpose Asset Groups
    #>
    [CmdletBinding(DefaultParameterSetName="All")]
    Param(
        [Parameter(Mandatory=$True,ParameterSetName="id")]
        [String]
        $ID,

        # Filter results by asset group type (static, dynamic)
        [Parameter(Mandatory=$False)]
        [ValidateSet("dynamic", "static")]
        [String]
        $Type,

        # Filter results by case insensitive search string
        [Parameter(Mandatory=$False)]
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

        $URI = "/api/3/asset_groups"
        if ($ID) {
            $URI = $URI + "/$ID"
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

        $DefaultDisplayFields = @("name","id","type","assets","vulnerabilities")
        if ($ID) {
            Write-Output $Response | Add-CustomTypeFormatting -CustomTypeName "Nexpose.AssetGroup" -DefaultDisplayFields $DefaultDisplayFields
        } else {
            Write-Output $Response.resources | Add-CustomTypeFormatting -CustomTypeName "Nexpose.AssetGroup" -DefaultDisplayFields $DefaultDisplayFields
        }
    }
}