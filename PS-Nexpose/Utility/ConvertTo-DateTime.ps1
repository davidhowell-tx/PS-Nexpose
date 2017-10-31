function ConvertTo-DateTime {
    [CmdletBinding()]Param(
        [Parameter(Mandatory=$True)]
        [String]
        $InputObject,

        [Parameter(Mandatory=$False)]
        [Switch]
        $MS
    )
    if ($InputObject -ne "-1") {
        if ($MS) {
            return ([DateTime]'1/1/1970').AddSeconds($InputObject / 1000).ToLocalTime()
        } else {
            return ([DateTime]'1/1/1970').AddSeconds($InputObject).ToLocalTime()
        }
    } else {
        $InputObject
    }
}