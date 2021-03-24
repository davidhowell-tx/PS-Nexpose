function Save-NPModuleConfiguration {
    <#
    .SYNOPSIS
        Serializes the provided configuration object to disk as a json file
    #>
    [CmdletBinding()]
    Param(
        # The configuration object to persist to disk
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [PSCustomObject]
        $InputObject,

        # The file path to save the object as
        [Parameter(Mandatory=$True)]
        [String]
        $Path
    )
    Process {
        # Log the command being executed
        $InitializationLog = $MyInvocation.MyCommand.Name
        $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { $InitializationLog = $InitializationLog + " -$($_.Key) $($_.Value)"}
        Write-Log -Message $InitializationLog -Level Verbose
        
        Try {
            Write-Log -Message "Saving configuration to $Path" -Level Verbose
            $InputObject | ConvertTo-Json | Out-File -FilePath (New-Item $Path -Force)
        } Catch {
            Write-Log -Message "Error received when attempting to save configuration to $Path" -Level Error
        }
    }
}