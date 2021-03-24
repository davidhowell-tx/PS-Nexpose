function Write-Log {
    <#
    .SYNOPSIS
        Converts the supplied message into a consistent log format
    #>
    [CmdletBinding()]
    Param(
        # The message to be logged.
        [Parameter(Mandatory=$True)]
        [String]
        $Message,

        # The log level of the message to be logged.
        [Parameter()]
        [ValidateSet(
            "Error",
            "Warning",
            "Verbose",
            "Informational"
        )]
        [String]
        $Level = "Informational"
    )
    Process {
        $DateTime = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"
        $Username = @($Env:USERDOMAIN, $Env:USERNAME) -join "\"
        $LogMessage = "$DateTime [$($Level.ToUpper())] - User: $Username, Message: $Message"

        switch ($Level) {
            "Informational" {
                Write-Host $LogMessage
            }
            "Verbose" {
                Write-Verbose $LogMessage
            }
            "Error" {
                Write-Error $LogMessage -ErrorAction Continue
            }
            "Warning" {
                Write-Warning $LogMessage
            }
        }
    }
}