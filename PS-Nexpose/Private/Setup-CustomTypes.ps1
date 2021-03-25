<#
    Loads all of the type formatting for the module
#>

# Nexpose.Asset
Update-TypeData -TypeName "Nexpose.Asset" -DefaultDisplayPropertySet @("hostName","ip","os","id","riskScore","vulnerabilities")

# Nexpose.AssetGroup
Update-TypeData -TypeName "Nexpose.AssetGroup" -DefaultDisplayPropertySet @("name","id","type","assets","vulnerabilities")

# Nexpose.Site
Update-TypeData -TypeName "Nexpose.Site" -DefaultDisplayPropertySet @("name", "id", "description", "type", "assets", "riskScore", "vulnerabilities", "lastScanTime")

# Nexpose.Tag
Update-TypeData -TypeName "Nexpose.Tag" -DefaultDisplayPropertySet @("name","id","type","source")

# Nexpose.Vulnerability
Update-TypeData -TypeName "Nexpose.Vulnerability" -MemberType "ScriptProperty" -MemberName "cvssv3score" -Value {$this.cvss.v3.score}
Update-TypeData -TypeName "Nexpose.Vulnerability" -MemberType "ScriptProperty" -MemberName "info" -Value {$this.description.text}
Update-TypeData -TypeName "Nexpose.Vulnerability" -DefaultDisplayPropertySet @("id","title","info","cvssv3score","published","modified","riskScore","exploits","malwarekits")