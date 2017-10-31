function ConvertTo-IPAddress {
    [CmdletBinding()]Param(
        [Parameter(Mandatory=$True)]
        [String]
        $BinaryIP
    )
    if ($BinaryIP) {
        for ($i=0; $i -lt 4; $i++) {
            $IPAddress += [Convert]::toInt32($BinaryIP.Substring(($i * 8),8),2).ToString()
            if ($i -ne 3) {
                $IPAddress += "."
            }
        }
        return $IPAddress
    }
}