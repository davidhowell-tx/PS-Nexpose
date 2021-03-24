function Remove-NPModuleConfiguration {
    <#
    .SYNOPSIS
        Remove persisted configuration for PS-Nexpose module
    #>
    [CmdletBinding()]
    Param(
        # Delete the configuration file from disk
        [Parameter(Mandatory=$False)]
        [Switch]
        $All,

        # Only remove a specific field from the persisted configuration
        [Parameter(Mandatory=$True,ParameterSetName="Value")]
        [ValidateSet("URI","Credentials")]
        [String[]]
        $Value
    )
    Process {
        # Log the command being executed
        $InitializationLog = $MyInvocation.MyCommand.Name
        $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { $InitializationLog = $InitializationLog + " -$($_.Key) $($_.Value)"}
        Write-Log -Message $InitializationLog -Level Verbose

        if ($All) {
            if (Test-Path -Path $Script:PSNexpose.ConfPath) {
                Write-Log -Message "Remove all was specified. Deleting the configuration file from $($Script:PSNexpose.ConfPath)" -Level Verbose
                Try {
                    Remove-Item -Path $Script:PSNexpose.ConfPath -Force
                } Catch {
                    Write-Log -Message "Unable to remove the configuration file from $($Script:PSNexpose.ConfPath)" -Level Error
                }
                
            } else {
                Write-Log -Message "Unable to locate configuration file to be deleted." -Level Warning
            }
            return
        }

        Write-Log -Message "Retrieving the saved configuration" -Level Verbose
        $Configuration = Get-NPModuleConfiguration -Persisted

        if ($Value -contains "URI") {
            Write-Log -Message "Removing URI from saved configuration" -Level Verbose
            $Configuration.PSObject.Properties.Remove("URI")
        }
        if ($Value -contains "Credentials") {
            Write-Log -Message "Removing Credentials from saved configuration" -Level Verbose
            $Configuration.PSObject.Properties.Remove("UserName")
            $Configuration.PSObject.Properties.Remove("Password")
        }

        Try {
            Write-Log -Message "Saving configuration to $($Script:PSNexpose.ConfPath)" -Level Verbose
            Save-NPModuleConfiguration -Path $Script:PSNexpose.ConfPath -InputObject $Configuration
        } Catch {
            Write-Log -Message "Error received when attempting to save configuration to $($Script:PSNexpose.ConfPath)" -Level Error
        }
    }
}