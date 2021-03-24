function Add-CustomTypeFormatting {
    <#
    .SYNOPSIS
        Function to abstract away the process of naming a PSCustomObject and creating a default property display set
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$True)]
        [PSCustomObject]
        $InputObject,

        [Parameter(Mandatory=$True)]
        [String]
        $CustomTypeName,
        
        [Parameter(Mandatory=$True)]
        [String[]]
        $DefaultDisplayFields
    )
    Process {
        $DefaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet("DefaultDisplayPropertySet",$DefaultDisplayFields)
        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($DefaultDisplayPropertySet)
        $InputObject.PSObject.TypeNames.Insert("0", $CustomTypeName)
        $InputObject | Add-Member MemberSet PSStandardMembers $PSStandardMembers
        Write-Output $InputObject
    }
}