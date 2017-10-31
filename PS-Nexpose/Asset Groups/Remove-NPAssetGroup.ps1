function Remove-NPAssetGroup {
	<#
	.SYNOPSIS
		Remove an asset group from the Nexpose Console.

	.PARAMETER Session
		Session Object returned from Connect-NPConsole command
    
    .PARAMETER ID
        Used to specify the asset group ID to remove.
	#>
	[CmdletBinding(DefaultParameterSetName="Default")]Param(
		[Parameter(Mandatory=$True)]
		$Session,

        [Parameter(Mandatory=$False)]
        [uint32]
        $ID
    )
    $RemoveAssetGroupForm = @{ groupid = $ID }
    $Headers = @{
        Referer = "$($Session.baseuri)/admin/groups.jsp"
        nexposeCCSessionID = ($Session.websession.Cookies.GetCookies("$($Session.baseuri)") | Where-Object { $_.Name -eq "nexposeCCSessionID" } | Select-Object -ExpandProperty Value)
    }
    $AssetGroupDeleteResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/assetGroup/removeAssetGroup") -WebSession $Session.websession -Method Post -Headers $Headers -ContentType 'application/x-www-form-urlencoded' -Body $RemoveAssetGroupForm

    if ($AssetGroupDeleteResponse.StatusCode -ne 200) {
        Write-Error -Message "Failed to delete asset group"
        return
    }

    Write-Verbose -Message "Asset Group $ID deleted."
}