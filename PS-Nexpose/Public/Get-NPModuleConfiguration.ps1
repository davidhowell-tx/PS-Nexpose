function Get-NPModuleConfiguration {
    <#
    .SYNOPSIS
        Retrieves the current configuration values for the PS-Nexpose Module
    #>
    [CmdletBinding(DefaultParameterSetName="Cached")]
    Param(
        # Retrieve the configuration persisted to disk
        [Parameter(Mandatory=$True,ParameterSetName="Persisted")]
        [Switch]
        $Persisted,

        # Instructs this function to cache the configuration settings in a variable accesible to subsequent requests so that saved configuration does not need to be retrieved for every request
        [Parameter(Mandatory=$False,ParameterSetName="Persisted")]
        [Switch]
        $Cache
    )
    Process {
        # Log the command being executed
        $InitializationLog = $MyInvocation.MyCommand.Name
        $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { $InitializationLog = $InitializationLog + " -$($_.Key) $($_.Value)"}
        Write-Log -Message $InitializationLog -Level Verbose

        if ($Persisted) {
            $Configuration = Read-NPModuleConfiguration -Path $Script:PSNexpose.ConfPath

            if ($Cache) {
                Write-Log -Message "Caching configuration settings for future queries." -Level Verbose
                if ($Configuration.URI -and -not $Script:PSNexpose.ManagementURL) {
                    $Script:PSNexpose.Add("ManagementURL", $Configuration.URI)
                }
                if ($Configuration.UserName -and -not $Script:PSNexpose.UserName) {
                    $Script:PSNexpose.Add("UserName", $Configuration.UserName)
                }
                if ($Configuration.Password -and -not $Script:PSNexpose.Password) {
                    $Script:PSNexpose.Add("Password", $Configuration.Password)
                }
                return
            }

            return $Configuration
        } else {
            return $Script:PSNexpose
        }
    }
}