function Get-NPAssetGroup {
	<#
	.SYNOPSIS
		Retrieve information about Asset Groups from the Nexpose Console.

	.PARAMETER Session
		Session Object returned from Connect-NPConsole command
    
    .PARAMETER ID
        Used to specify an Asset Group ID to filter upon.
    
	.PARAMETER Name
		Used to specify an Asset Group name to filter upon. Accepts wild cards.
	#>
	[CmdletBinding(DefaultParameterSetName="Default")]Param(
		[Parameter(Mandatory=$True)]
		$Session,

        [Parameter(Mandatory=$False)]
        [uint32]
        $ID,

        [Parameter(Mandatory=$False)]
		[String]
        $Name
    )

    $AssetGroupsResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/asset/group/dyntable?printDocType=0&tableID=groupSynopsisTable&allWords=&phrase=") -WebSession $Session.websession

    if ($AssetGroupsResponse.StatusCode -ne 200) {
        Write-Error -Message "Failed to retrieve asset group list"
        return
    }

    $FieldMap = @{
        groupID = "id"
        IsDynamic = "isDynamic"
        GroupName = "name"
        GroupTag = "description"
        ScannedDevices = "assetCount"
        Vulnerabilities = "vulnerabilities"
        Risk = "riskScore"
        Reports = "reportCount"
        GroupFlag = "groupFlag"
        Type = "type"
        Users = "users"
    }

    $AssetGroups = ConvertFrom-NPDyntable -InputObject $AssetGroupsResponse.Content -ObjectName "Nexpose.AssetGroup" -FieldMap $FieldMap
    
    # If an ID filter was supplied, filter results
    if ($ID) {
        $AssetGroups = $AssetGroups | Where-Object { $_.id -like $ID }

        if (-not $AssetGroups) {
            Write-Error -Message "ID filter returned no results."
            return
        }
    }

    # If a name filter was supplied, filter results
    if ($Name) {
        $AssetGroups = $AssetGroups | Where-Object { $_.name -like $Name }

        if (-not $AssetGroups) {
            Write-Error -Message "Name filter returned no results."
            return
        }
    }

    return $AssetGroups
}