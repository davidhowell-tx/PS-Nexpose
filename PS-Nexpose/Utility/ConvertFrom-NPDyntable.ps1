function ConvertFrom-NPDyntable {
    [CmdletBinding()]Param(
        [Parameter(Mandatory=$True)]
        $InputObject,

        [Parameter(Mandatory=$False)]
        $ObjectName,

        [Parameter(Mandatory=$False)]
        $FieldMap
    )

    # Cast to XML
    [XML]$InputObjectXML = $InputObject

    # Get column headers to create field names dynamically
    $Headers = $InputObjectXML.DynTable.MetaData.Column | Select-Object -ExpandProperty name

    $Results = @()
    # Loop through each table rable and parse columns
    ForEach ($Row in $InputObjectXML.DynTable.Data.tr) {
        if ($ObjectName) {
            $Object = [PSCustomObject]@{ PSTypeName = "$ObjectName" }
        } else {
            $Object = [PSCustomObject]@{}
        }

        for ($i = 0; $i -lt $Headers.count; $i++) {
            $FieldName = $Headers[$i] -replace " ", ""
            if ($FieldMap.$FieldName) {
                $FieldName = $FieldMap.$FieldName
            }
            Add-Member -InputObject $Object -MemberType NoteProperty -Name $FieldName -Value $Row.td[$i]
        }

        $Results += $Object
    }

    return $Results
}