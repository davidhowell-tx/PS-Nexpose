function New-NPExclusion {
	<#
    .SYNOPSIS
        Add an Exclusion to the current list of exclusions in the Nexpose console.

	.PARAMETER Session
        Session Object returned from Connect-NPConsole command
    
    .PARAMETER Exclusion
	#>
	[CmdletBinding()]Param(
		[Parameter(Mandatory=$True)]
        $Session,
        
        [Parameter(Mandatory=$True)]
        [String[]]
        $Exclusion
	)
    
    # Get the current list of exclusions to build upon
    $GlobalSettingsResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/admin/global-settings") -WebSession $Session.websession
	if ($GlobalSettingsResponse.StatusCode -ne 200) {
        Write-Error -Message "Failed to retrieve Nexpose Global Settings"
        return
	} else {
        [XML]$GlobalSettingsXML = $GlobalSettingsResponse.Content

        # Add Recalculation Duration to RiskModel section (post will fail without this)
        $RecalculationXML = $GlobalSettingsXML.CreateAttribute("recalculation_duration")
        $RecalculationXML.value = "do_not_recalculate"
        $GlobalSettingsXML.GlobalSettings.riskModel.Attributes.Append($RecalculationXML) | Out-Null

        ForEach ($Entry in $Exclusion) {
            switch -Regex ($Entry) {
                # Single IP Address
                "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$" {
                    $NewRangeXML = $GlobalSettingsXML.CreateElement("range")
                    $NewRangeFrom = $GlobalSettingsXML.CreateAttribute("from")
                    $NewRangeFrom.value = $matches[0]
                    $NewRangeXML.Attributes.Append($NewRangeFrom) | Out-Null
                    $GlobalSettingsXML.GlobalSettings.ExcludedHosts.AppendChild($NewRangeXML) | Out-Null
                }

                # IP Address Range, like 10.0.0.1 - 10.0.0.4
                "^((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))\s-\s((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))$" {
                    $NewRangeXML = $GlobalSettingsXML.CreateElement("range")
                    $NewRangeFrom = $GlobalSettingsXML.CreateAttribute("from")
                    $NewRangeFrom.value = $matches[1]
                    $NewRangeXML.Attributes.Append($NewRangeFrom) | Out-Null
                    $NewRangeTo = $GlobalSettingsXML.CreateAttribute("to")
                    $NewRangeTo.value = $matches[2]
                    $NewRangeXML.Attributes.Append($NewRangeTo) | Out-Null
                    $GlobalSettingsXML.GlobalSettings.ExcludedHosts.AppendChild($NewRangeXML) | Out-Null
                }

                # Subnet CIDR
                "^((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))/((?:3[0-2]|[0-2][0-9]|[0-9]))$" {
                    $IPAddress = $matches[1]
                    $CIDR = [Convert]::ToInt32($matches[2])

                    if ($cidr -le 32 -and $cidr -ne 0) {
                        # Convert IP to Binary format and retrieve first and last addresses in the range
                        $IPAddressBinary = ConvertTo-BinaryIP -IPAddress $IPAddress
                        $IPAddressFrom = ConvertTo-IPAddress -BinaryIP ($IPAddressBinary.substring(0,$CIDR).padright(31,"0") + "1")
                        $IPAddressTo = ConvertTo-IPAddress -BinaryIP ($IPAddressBinary.substring(0,$CIDR).padright(31,"1") + "0")

                        $NewRangeXML = $GlobalSettingsXML.CreateElement("range")
                        $NewRangeFrom = $GlobalSettingsXML.CreateAttribute("from")
                        $NewRangeFrom.value = $IPAddressFrom
                        $NewRangeXML.Attributes.Append($NewRangeFrom) | Out-Null
                        $NewRangeTo = $GlobalSettingsXML.CreateAttribute("to")
                        $NewRangeTo.value = $IPAddressTo
                        $NewRangeXML.Attributes.Append($NewRangeTo) | Out-Null
                        $GlobalSettingsXML.GlobalSettings.ExcludedHosts.AppendChild($NewRangeXML) | Out-Null
                    }

                }
                default {
                    $NewHostXML = $GlobalSettingsXML.CreateElement("host")
                    $NewHostXMLText = $GlobalSettingsXML.CreateTextNode($Entry)
                    $NewHostXML.AppendChild($NewHostXMLText) | Out-Null
                    $GlobalSettingsXML.GlobalSettings.ExcludedHosts.AppendChild($NewHostXML) | Out-Null
                }
            }
        }
        $Headers = @{
            Referer = "$($Session.baseuri)/admin/global-settings.jsp"
            nexposeCCSessionID = ($Session.websession.Cookies.GetCookies("$($Session.baseuri)") | Where-Object { $_.Name -eq "nexposeCCSessionID" } | Select-Object -ExpandProperty Value)
        }
        $GlobalSettingsUpdateResponse = Invoke-WebRequest -Uri ($Session.baseuri + "/data/admin/global-settings") -WebSession $Session.websession -Method Post -Body $GlobalSettingsXML.OuterXml -ContentType 'text/xml; charset=UTF-8' -Headers $Headers
        if ($GlobalSettingsUpdateResponse.StatusCode -ne 200) {
            Write-Error -Message "HTTP Post failed to upload new exclusions list"
        } else {
            if (([XML]$GlobalSettingsUpdateResponse.Content).SaveConfig.success -eq 0) {
                Write-Error -Message "HTTP Post succeeded, but failed to save changes to exclusions list"
            }
        }

    }
}