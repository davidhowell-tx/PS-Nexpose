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
	
	.PARAMETER Config
        Switch used to include site configuration information in the response
	#>
	[CmdletBinding(DefaultParameterSetName="Default")]Param(
		[Parameter(Mandatory=$True)]
		$Session,

        [Parameter(Mandatory=$False)]
        [uint32]
        $ID,

        [Parameter(Mandatory=$False)]
		[String]
        $Name,
        
        [Parameter(Mandatory=$False,ParameterSetName="Default")]
        [Parameter(Mandatory=$True,ParameterSetName="Config")]
        [Switch]
        $Config,

        [Parameter(Mandatory=$False,ParameterSetName="Config")]
        [Switch]
        $ResolveUserID
    )

    $AssetGroupsResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/asset/group/dyntable?printDocType=0&tableID=groupSynopsisTable&allWords=&phrase=") -WebSession $Session.websession

    if ($AssetGroupsResponse.StatusCode -ne 200) {
        Write-Error -Message "Failed to retrieve asset group list"
    } else {
        [XML]$AssetGroupsXML = $AssetGroupsResponse.Content
        $AssetGroupHeaders = $AssetGroupsXML.DynTable.MetaData.Column | Select-Object -ExpandProperty name

        $AssetGroups = @()
        # Loop through TRs in the Response
        ForEach ($Row in $AssetGroupsXML.DynTable.Data.tr) {
            $AssetGroup = [PSCustomObject]@{ PSTypeName = "Nexpose.AssetGroup" }

            for ($i = 0; $i -lt $AssetGroupHeaders.count; $i++) {
                Add-Member -InputObject $AssetGroup -MemberType NoteProperty -Name ($AssetGroupHeaders[$i] -replace " ","") -Value $Row.td[$i]
            }

            $AssetGroups += $AssetGroup
        }
        
        # If an ID filter was supplied, filter results
        if ($ID) {
            $AssetGroups = $AssetGroups | Where-Object { $_.GroupID -like $ID }

            if (-not $AssetGroups) {
                Write-Error -Message "ID filter returned no results."
                return
            }
        }

        # If a name filter was supplied, filter results
        if ($Name) {
            $AssetGroups = $AssetGroups | Where-Object { $_.GroupName -like $Name }

            if (-not $AssetGroups) {
                Write-Error -Message "Name filter returned no results."
                return
            }
        }

        if ($Config) {
            ForEach ($AssetGroup in $AssetGroups) {
                $AssetGroupConfigResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/assetGroup/loadAssetGroup?entityid=$($AssetGroup.GroupID)") -WebSession $Session.websession

                if ($AssetGroupConfigResponse.StatusCode -ne 200) {
                    Write-Error -Message "Failed to retrieve asset group configuration for group $($AssetGroup.GroupName)"
                } else {
                    $AssetGroupConfig = $AssetGroupConfigResponse.Content | ConvertFrom-Json

                    $SearchCriteria = @()
                    ForEach ($Criteria in $AssetGroupConfig.searchCriteria.criteria) {

                    }
                    Add-Member -InputObject $AssetGroup -MemberType NoteProperty -Name searchCriteria -Value $AssetGroupConfig.searchCriteria
                }
            }
        }

        return $AssetGroups
    }
}