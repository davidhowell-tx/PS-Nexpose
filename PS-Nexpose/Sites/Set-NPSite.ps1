function Set-NPSite {
	<#
	.SYNOPSIS
		Used to modify sites in the Nexpose console.

	.PARAMETER Session
		Session Object returned from Connect-NPConsole command
	#>
	[CmdletBinding(DefaultParameterSetName="Default")]Param(
		[Parameter(Mandatory=$True)]
		$Session
    )
}