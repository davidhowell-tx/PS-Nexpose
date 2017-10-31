function ConvertFrom-NPRepeater {
    [CmdletBinding()]Param(
        [Parameter(Mandatory=$True)]
        $InputObject
    )

    [XML]$InputObjectXML = $InputObject

    $Headers = $InputObjectXML.DynTable.MetaData.Column | Select-Object -ExpandProperty name

    ForEach ($Row in $InputObjectXML.DynTable.Data.tr) {

    }
}