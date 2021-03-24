function Get-NPAsset {
    <#
    .SYNOPSIS
        Retrieve information related to Nexpose Assets
    #>
    [CmdletBinding(DefaultParameterSetName="All")]
    Param(
        [Parameter(Mandatory=$True,ParameterSetName="id")]
        [String]
        $ID,

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

        $URI = "/api/3/assets"
        if ($ID) {
            $URI = $URI + "/$ID"
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
        
        $DefaultDisplayFields = @("hostName","ip","os","id","riskScore","vulnerabilities")
        if ($ID) {
            Write-Output $Response | Add-CustomTypeFormatting -CustomTypeName "Nexpose.Asset" -DefaultDisplayFields $DefaultDisplayFields
        } else {
            Write-Output $Response.resources | Add-CustomTypeFormatting -CustomTypeName "Nexpose.Asset" -DefaultDisplayFields $DefaultDisplayFields
        }
    }
}