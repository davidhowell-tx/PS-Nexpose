function Get-NPCredential {
    <#
	.SYNOPSIS
		Retrieve scan information from the Nexpose Console.

	.PARAMETER Session
        Session Object returned from Connect-NPConsole command
	#>
	[CmdletBinding()]Param(
		[Parameter(Mandatory=$True)]
		$Session
    )
    $CredentialForm = @{
        sort = "-1"
        dir = "-1"
        startIndex = "-1"
        results = "-1"
        "table-id" = "credential-listing"
    }
    $CredentialHeaders = @{
        Referer = "$($Session.baseuri)/credential/listing.jsp"
        nexposeCCSessionID = ($Session.websession.Cookies.GetCookies("$($Session.baseuri)") | Where-Object { $_.Name -eq "nexposeCCSessionID" } | Select-Object -ExpandProperty Value)
    }
    $CredentialResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/credential/shared/listing") -WebSession $Session.websession -Method Post -Headers $CredentialHeaders -Body $CredentialForm

    if ($CredentialResponse.StatusCode -ne 200) {
        Write-Error -Message "Failed to retrieve credential list"
    } else {
        $Credentials = $CredentialResponse.Content | ConvertFrom-Json

        $CredentialResults = @()
        ForEach ($Credential in $Credentials.records) {
            $Object = [PSCustomObject]@{
                PSTypeName = "Nexpose.Credential"
                name = $Credential.name
                username = $Credential.username
                domain = $Credential.domain
                scope = $Credential.scope
                service = $Credential.service
                lastModified = ConvertTo-DateTime -InputObject $Credential.lastModified.time -MS
                id = $Credential.credentialID.ID
                privilegeElevationUsername = $Credential.privilegeElevationUsername
            }
            $CredentialResults += $Object
        }

        return $CredentialResults
    }
}