Function ConvertTo-BinaryIP {
    [CmdletBinding()]Param(
        [Parameter(Mandatory=$True)]
        [String]
        $IPAddress,

        [Parameter(Mandatory=$False)]
        [Switch]
        $DotNotation
    )

    if ($DotNotation) {
        ($IPAddress.Split(".") | ForEach-Object { $([convert]::toString($_,2).padleft(8,"0")) }) -join "."
    } else {
        ($IPAddress.Split(".") | ForEach-Object { $([convert]::toString($_,2).padleft(8,"0")) }) -join ""
    }
} 