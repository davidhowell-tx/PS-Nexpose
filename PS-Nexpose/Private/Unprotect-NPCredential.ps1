function Unprotect-NPCredential {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [String]
        $String
    )
    Process {
        $SecureString = ConvertTo-SecureString -String $String
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
        $OutString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        Write-Output -InputObject $OutString
    }
}