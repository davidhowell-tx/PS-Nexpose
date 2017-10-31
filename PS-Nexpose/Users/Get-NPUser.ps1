function Get-NPUser {
	<#
	.SYNOPSIS
		Get information about users from the Nexpose Console.

	.PARAMETER Session
		Session Object returned from Connect-NPConsole command
	
	.PARAMETER ID
        Used to specify a User ID to filter upon.
    
    .PARAMETER Detailed
        Switch that specifies to pull the detailed listing of User information (from the Admin page)
    
	.EXAMPLE
        Get a list of all users
        Get-NPUser -Session $Session
    
    .EXAMPLE
        Get detailed information about a user
        Get-NPUser -Session $Session -Detailed
	#>
	[CmdletBinding()]Param(
		[Parameter(Mandatory=$True)]
		$Session,

		[Parameter(Mandatory=$False)]
		[uint32]
        $ID,

        [Parameter(Mandatory=$False)]
        [Switch]
        $Detailed
    )
    $PermissionTypes = (
        [PSCustomObject]@{ name = "fullControl"; description = "All Security Console Permissions"; category = "Global Permissions" },
        [PSCustomObject]@{ name = "manageSites"; description = "Manage Sites"; category = "Global Permissions" },
        [PSCustomObject]@{ name = "manageScanTemplates"; description = "Manage Scan Templates"; category = "Global Permissions" },
        [PSCustomObject]@{ name = "manageReportTemplates"; description = "Manage Report Templates"; category = "Global Permissions" },
        [PSCustomObject]@{ name = "manageScanEngines"; description = "Manage Scan Engines"; category = "Global Permissions" },
        [PSCustomObject]@{ name = "ticketAssignee"; description = "Appear on Ticket and Report Lists"; category = "Global Permissions" },
        [PSCustomObject]@{ name = "configureGlobalSettings"; description = "Configure Global Settings"; category = "Global Permissions" },
        [PSCustomObject]@{ name = "managePolicies"; description = "Manage Policies"; category = "Global Permissions" },
        [PSCustomObject]@{ name = "manageTags"; description = "Manage Tags"; category = "Global Permissions" },
        [PSCustomObject]@{ name = "siteViewAsset"; description = "View Site Asset Data"; category = "Site Permissions" },
        [PSCustomObject]@{ name = "configureSiteSettings"; description = "Specify Site Metadata"; category = "Site Permissions" },
        [PSCustomObject]@{ name = "configureSiteTargets"; description = "Specify Scan Targets"; category = "Site Permissions" },
        [PSCustomObject]@{ name = "configureSiteScanEngine"; description = "Assign Scan Engine"; category = "Site Permissions" },
        [PSCustomObject]@{ name = "configureScanTemplate"; description = "Assign Scan Template"; category = "Site Permissions" },
        [PSCustomObject]@{ name = "configureAlerts"; description = "Manage Scan Alerts"; category = "Site Permissions" },
        [PSCustomObject]@{ name = "configureCredentials"; description = "Manage Site Credentials"; category = "Site Permissions" },
        [PSCustomObject]@{ name = "scheduleScans"; description = "Schedule Automatic Scans"; category = "Site Permissions" },
        [PSCustomObject]@{ name = "runScans"; description = "Start Unscheduled Scans"; category = "Site Permissions" },
        [PSCustomObject]@{ name = "purgeAssetData"; description = "Purge Site Asset Data"; category = "Site Permissions" },
        [PSCustomObject]@{ name = "addUsersToSite"; description = "Manage Site Access"; category = "Site Permissions" },
        [PSCustomObject]@{ name = "manageDynamicAssetGroups"; description = "Manage Dynamic Asset Groups"; category = "Asset Group Permissions" },
        [PSCustomObject]@{ name = "manageAssetGroups"; description = "Manage Static Asset Groups"; category = "Asset Group Permissions" },
        [PSCustomObject]@{ name = "groupViewAsset"; description = "View Group Asset Data"; category = "Asset Group Permissions" },
        [PSCustomObject]@{ name = "configureAssets"; description = "Manage Group Assets"; category = "Asset Group Permissions" },
        [PSCustomObject]@{ name = "addUsersToGroup"; description = "Manage Asset Group Access"; category = "Asset Group Permissions" },
        [PSCustomObject]@{ name = "createReports"; description = "Create Reports"; category = "Report Permissions" },
        [PSCustomObject]@{ name = "generateRestrictedReports"; description = "Use Restricted Report Sections"; category = "Report Permissions" },
        [PSCustomObject]@{ name = "addUsersToReport"; description = "Manage Report Access"; category = "Report Permissions" },
        [PSCustomObject]@{ name = "createTickets"; description = "Create Tickets"; category = "Ticket Permissions" },
        [PSCustomObject]@{ name = "closeTickets"; description = "Close Tickets"; category = "Ticket Permissions" },
        [PSCustomObject]@{ name = "submitVulnExceptions"; description = "Submit Vulnerability Exceptions and Policy Overrides"; category = "Vulnerability Exception and Policy Override Permissions" },
        [PSCustomObject]@{ name = "approveVulnExceptions"; description = "Review Vulnerability Exceptions and Policy Overrides"; category = "Vulnerability Exception and Policy Override Permissions" },
        [PSCustomObject]@{ name = "deleteVulnExceptions"; description = "Delete Vulnerability Exceptions and Policy Overrides"; category = "Vulnerability Exception and Policy Override Permissions" }
    )
    $NotificationTypes = (
        [PSCustomObject]@{ name = "showAfterLogin"; description = "Open notifications panel at login if notifications are available" },
        [PSCustomObject]@{ name = "productUpdates"; description = "Product update notifications" },
        [PSCustomObject]@{ name = "contentUpdates"; description = "Content update notifications" },
        [PSCustomObject]@{ name = "cloudConnectivity"; description = "Cloud connectivity notifications" },
        [PSCustomObject]@{ name = "diskSpace"; description = "Low disk space notifications" },
        [PSCustomObject]@{ name = "discoveryConnections"; description = "Discovery connection notifications" },
        [PSCustomObject]@{ name = "reporting"; description = "Reporting notifications" }
    )

    $UserResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/admin/users?printDocType=0&tableID=UserAdminSynopsis") -WebSession $Session.websession

    if ($UserResponse.StatusCode -ne 200) {
        Write-Error -Message "Failed to retrieve user list"
        return
    } else {
        [XML]$UsersXML = $UserResponse.Content
        $UserHeaders = $UsersXML.DynTable.MetaData.Column | Select-Object -ExpandProperty name

        $Users = @()
        # Loop through TRs in the Response
        ForEach ($Row in $UsersXML.DynTable.Data.tr) {
            $User = [PSCustomObject]@{ PSTypeName = "Nexpose.User" }

            for ($i = 0; $i -lt $UserHeaders.count; $i++) {
                Add-Member -InputObject $User -MemberType NoteProperty -Name ($UserHeaders[$i] -replace " ","") -Value $Row.td[$i]
            }

            if ($User.Administrator) {
                if ($User.Administrator -eq 1) {
                    $User.Administrator = "Yes"
                } elseif ($User.Administrator -eq 0) {
                    $User.Administrator = "No"
                }
            }

            if ($User.LastLogon) {
                $User.LastLogon = ([DateTime]'1/1/1970').AddSeconds($User.LastLogon / 1000)
            }

            $Users += $User
        }

        # If a ID filter was provided, filter now before any additional processing
        if ($ID) {
            $Users = $Users | Where-Object { $_.UserID -like $ID }
        }
        
        ForEach ($User in $Users) {
            if ($Detailed) {
                $UserConfigResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/user/configuration?userid=$($User.UserID)&view=sites") -WebSession $Session.websession
                if ($UserConfigResponse.StatusCode -ne 200) {
                    Write-Error -Message "Failed to retrieve user config for user: $($User.UserID)"
                } else {
                    [XML]$UserConfigXML = $UserConfigResponse.Content

                    $Permissions = @()
                    ForEach ($PermissionType in $PermissionTypes) {
                        $Permissions += [PSCustomObject]@{
                            PSTypeName = "Nexpose.Permission"
                            name = $PermissionType.name
                            description = $PermissionType.description
                            category = $PermissionType.category
                            value = if ($UserConfigXML.ajaxResponse.User.$($PermissionType.name) -eq 1) { "Yes" } else { "No" }
                        }
                    }
                    Add-Member -InputObject $User -MemberType NoteProperty -Name Permissions -Value $Permissions

                    if ($UserConfigXML.ajaxResponse.User.allGroups -eq "true") {
                        Add-Member -InputObject $User -MemberType NoteProperty -Name AllGroups -Value "Yes"
                    } else {
                        Add-Member -InputObject $User -MemberType NoteProperty -Name AllGroups -Value "No"
                    }
                    Add-Member -InputObject $User -MemberType NoteProperty -Name Groups -Value $UserConfigXML.ajaxResponse.User.Groups.group.id
                    
                    if ($UserConfigXML.ajaxResponse.User.allSites -eq "true") {
                        Add-Member -InputObject $User -MemberType NoteProperty -Name AllSites -Value "Yes"
                    } else {
                        Add-Member -InputObject $User -MemberType NoteProperty -Name AllSites -Value "No"
                    }
                    Add-Member -InputObject $User -MemberType NoteProperty -Name Sites -Value $UserConfigXML.ajaxResponse.User.Sites.site.id
                }
            }
        }
        return $Users
    }
}