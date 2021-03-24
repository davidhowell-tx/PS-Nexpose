function Read-NPModuleConfiguration {
    <#
    .SYNOPSIS
        Reads the configuration object that has been persisted to disk
    #>
    [CmdletBinding()]
    Param(
        # The file path where the configuration object has been saved
        [Parameter(Mandatory=$True)]
        [String]
        $Path
    )
    Process {
        # Log the command being executed
        $InitializationLog = $MyInvocation.MyCommand.Name
        $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { $InitializationLog = $InitializationLog + " -$($_.Key) $($_.Value)"}
        Write-Log -Message $InitializationLog -Level Verbose

        Write-Log -Message "Checking for configuration file at $Path" -Level Verbose
        if (-not (Test-Path -Path $Path)) {
            Write-Log -Message "$Path not found."
            return
        }

        Write-Log -Message "Importing configuration settings from $Path" -Level Verbose
        $Configuration = Get-Content -Path $Path

        Try {
            return ($Configuration | ConvertFrom-Json)
        } Catch {
            Write-Log -Message "Unable to deserialize saved configuration from json. Please use Remove-NPModuleConfiguration to remove the saved configuration."
        }
    }
}