function Set-NPModuleConfiguration {
    <#
    .SYNOPSIS
        Sets the PS-Nexpose module configuration values for connecting to the Nexpose console
    
    .DESCRIPTION
        Sets the PS-Nexpose module configuration values for connecting to the Nexpose console
        Values can be set for the session only, or persisted to disk
    #>
    [CmdletBinding()]
    Param(
        # Set the URI for your Nexpose management console
		[Parameter(Mandatory=$False)]
		[String]
        $URI,

        # Set the credentials used to authenticate to your Nexpose console
		[Parameter(Mandatory=$False)]
		[System.Management.Automation.PSCredential]
		$Credentials,
        
        # Switch to specify that the configuration values should be saved to disk. Tokens are a secure string saved to disk. Path is in the user's local AppData directory
        [Parameter(Mandatory=$False)]
        [Switch]
        $Persist
    )
    Process {
        # Log the command being executed
        $InitializationLog = $MyInvocation.MyCommand.Name
        $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { $InitializationLog = $InitializationLog + " -$($_.Key) $($_.Value)"}
        Write-Log -Message $InitializationLog -Level Verbose

        if ($URI) {
            if ($Script:PSNexpose.ManagementURL) {
                $Script:PSNexpose.ManagementURL = $URI
            } else {
                $Script:PSNexpose.Add("ManagementURL", $URI)
            }
        }
        if ($Credentials) {
            $CredentialSecured = ConvertFrom-SecureString -SecureString ($Credentials.Password)
            if ($Script:PSNexpose.UserName) {
                $Script:PSNexpose.UserName = $Credentials.UserName
            } else {
                $Script:PSNexpose.Add("UserName", $Credentials.UserName)
            }
            if ($Script:PSNexpose.Password) {
                $Script:PSNexpose.Password = $CredentialSecured
            } else {
                $Script:PSNexpose.Add("Password", $CredentialSecured)
            }
        }

        if ($Persist) {
            $Configuration = Read-NPModuleConfiguration -Path $Script:PSNexpose.ConfPath

            if (-not $Configuration) {
                $Configuration = [PSCustomObject]@{}
            }

            if ($URI) {
                if (-not $Configuration.URI) {
                    Add-Member -InputObject $Configuration -MemberType NoteProperty -Name URI -Value $URI
                } else {
                    $Configuration.URI = $URI
                }
            }

            if ($Credentials) {
                if (-not $Configuration.UserName) {
                    Add-Member -InputObject $Configuration -MemberType NoteProperty -Name UserName -Value $Credentials.UserName
                } else {
                    $Configuration.UserName = $Credentials.UserName
                }
                if (-not $Configuration.Password) {
                    Add-Member -InputObject $Configuration -MemberType NoteProperty -Name Password -Value $CredentialSecured
                } else {
                    $Configuration.Password = $CredentialSecured
                }
            }
            
            Save-NPModuleConfiguration -Path $Script:PSNexpose.ConfPath -InputObject $Configuration
        }
    }
}