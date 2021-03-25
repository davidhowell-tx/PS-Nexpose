<#
    Loads all of the type formatting for the module
#>

# Nexpose.Asset
Update-TypeData -TypeName "Nexpose.Asset" -DefaultDisplayPropertySet @("hostName","ip","os","id","riskScore","vulnerabilities")

# Nexpose.AssetGroup
Update-TypeData -TypeName "Nexpose.AssetGroup" -DefaultDisplayPropertySet @("name","id","type","assets","vulnerabilities")

# Nexpose.Exploit
Update-TypeData -TypeName "Nexpose.Exploit" -DefaultDisplayPropertySet @("title","id","skillLevel","source")

# Nexpose.MalwareKit
Update-TypeData -TypeName "Nexpose.MalwareKit" -DefaultDisplayPropertySet @("name","id","popularity")

# Nexpose.ScanEngine
Update-TypeData -TypeName "Nexpose.ScanEngine" -DefaultDisplayPropertySet @("name","address","port","status","id","productVersion","contentVersion","lastRefreshedDate","lastUpdatedDate")

# Nexpose.Site
Update-TypeData -TypeName "Nexpose.Site" -DefaultDisplayPropertySet @("name", "id", "description", "type", "assets", "riskScore", "vulnerabilities", "lastScanTime")

# Nexpose.Solution
Update-TypeData -TypeName "Nexpose.Solution" -MemberType "ScriptProperty" -MemberName "description" -Value {$this.summary.text}
Update-TypeData -TypeName "Nexpose.Solution" -DefaultDisplayPropertySet @("id","description","estimate","type","appliesTo")

# Nexpose.Tag
Update-TypeData -TypeName "Nexpose.Tag" -DefaultDisplayPropertySet @("name","id","type","source")

# Nexpose.Vulnerability
Update-TypeData -TypeName "Nexpose.Vulnerability" -MemberType "ScriptProperty" -MemberName "cvssv3score" -Value {$this.cvss.v3.score}
Update-TypeData -TypeName "Nexpose.Vulnerability" -MemberType "ScriptProperty" -MemberName "summary" -Value {$this.description.text}
Update-TypeData -TypeName "Nexpose.Vulnerability" -DefaultDisplayPropertySet @("id","title","summary","cvssv3score","published","modified","riskScore","exploits","malwarekits")