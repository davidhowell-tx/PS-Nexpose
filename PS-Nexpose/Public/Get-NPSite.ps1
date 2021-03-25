function Get-NPSite {
    <#
    .SYNOPSIS
        Retrieve information related to Nexpose Sites
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

        $URI = "/api/3/sites"
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
        
        if ($ID) {
            $Sites = $Response
        } else {
            $Sites = $Response.resources
        }
        Write-Output $Sites | Add-CustomType -CustomTypeName "Nexpose.Site"
    }
}