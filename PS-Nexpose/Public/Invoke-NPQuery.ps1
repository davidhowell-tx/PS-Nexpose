function Invoke-NPQuery {
    <#
    .SYNOPSIS
        Handles the request/response aspect of interacting with the Nexpose API.

    .DESCRIPTION
        Handles the request/response aspect of interacting with the Nexpose API, including pagination and error handling
    #>
    [CmdletBinding(DefaultParameterSetName="Default")]
    Param(
        # The API URI from the Nexpose API Documentation, i.e. "/api/3/assets"
        [Parameter(Mandatory=$True,ParameterSetName="Default")]
        [Parameter(Mandatory=$True,ParameterSetName="Count")]
        [Parameter(Mandatory=$True,ParameterSetName="CountOnly")]
        [Parameter(Mandatory=$True,ParameterSetName="Recurse")]
        [String]
        $URI,
    
        # Hashtable containing the query string parameters used for filtering the results
        [Parameter(Mandatory=$False,ParameterSetName="Default")]
        [Parameter(Mandatory=$False,ParameterSetName="Count")]
        [Parameter(Mandatory=$False,ParameterSetName="CountOnly")]
        [Parameter(Mandatory=$False,ParameterSetName="Recurse")]
        [Hashtable]
        $Parameters,

        # Content type of the body, if necessary, i.e. "application/json"
        [Parameter(Mandatory=$False,ParameterSetName="Default")]
        [Parameter(Mandatory=$False,ParameterSetName="Count")]
        [Parameter(Mandatory=$False,ParameterSetName="CountOnly")]
        [Parameter(Mandatory=$False,ParameterSetName="Recurse")]
        [String]
        $ContentType,

        # Rest method for the query.
        [Parameter(Mandatory=$False)]
        [ValidateSet("Get", "Post", "Put", "Delete")]
        [String]
        $Method = "Get",

        # Used to limit the number of results in the response, if supported by the specific API
        [Parameter(Mandatory=$True,ParameterSetName="Count")]
        [Uint32]
        $Count,

        [Parameter(Mandatory=$True,ParameterSetName="CountOnly")]
        [Switch]
        $CountOnly,

        # Used to follow the cursor in paginated requests to retrieve all possible results
        [Parameter(Mandatory=$True,ParameterSetName="Recurse")]
        [Switch]
        $Recurse,

        # The body value for a POST or PUT request
        [Parameter(Mandatory=$False,ParameterSetName="Default")]
        [Parameter(Mandatory=$False,ParameterSetName="Count")]
        [Parameter(Mandatory=$False,ParameterSetName="CountOnly")]
        [Parameter(Mandatory=$False,ParameterSetName="Recurse")]
        $Body,

        # For querying directly linked resources, such as those in the "links" array on objects returned by the Nexpose API
        [Parameter(Mandatory=$True,ParameterSetName="DirectLink")]
        [String]
        $DirectLink
    )
    Process {
        # Log the function and parameters being executed
        $InitializationLog = $MyInvocation.MyCommand.Name
        $MyInvocation.BoundParameters.GetEnumerator() | ForEach-Object { $InitializationLog = $InitializationLog + " -$($_.Key) $($_.Value)"}
        Write-Log -Message $InitializationLog -Level Verbose

        # Attempt to retrieve cached configuration
        if ((-not $Script:PSNexpose.UserName -or -not $Script:PSNexpose.Password) -or -not $Script:PSNexpose.ManagementURL) {
            Write-Log -Message "PS-Nexpose Module Configuration not cached. Loading information from disk." -Level Verbose
            Get-NPModuleConfiguration -Persisted -Cache
        }

        # If no management URL is known, notify the user and exit
        if (-not $Script:PSNexpose.ManagementURL) {
            Write-Log -Message "Please use Set-NPModuleConfiguration to save your management URL." -Level Error
            return
        }

        # If no credentials are present, notify the user and exit
        if (-not $Script:PSNexpose.UserName -and -not $Script:PSNexpose.Password) {
            Write-Log -Message "Please use Set-NPModuleConfiguration to cache your Credentials for API calls." -Level Error
            return
        }

        # Start building request
        $Request = @{}
        $Request.Add("Method", $Method)
        $Request.Add("ErrorVariable", "RestError")
        if ($ContentType) {
            $Request.Add("ContentType", $ContentType)
        }
        if ($Body) {
            $Request.Add("Body", $Body)
        }

        # Build request headers and add to request
        $Headers = @{}
        $Headers.Add("Accept", "application/json")
        $Headers.Add("Accept-Language", "en-US")
        $Credential = Unprotect-NPCredential -String $Script:PSNexpose.Password
        $Headers.Add("Authorization", "Basic $([Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes("$($Script:PSNexpose.UserName):$Credential")))")
        $Request.Add("Headers", $Headers)

        # Build the URI to be added to the request
        if ($DirectLink) {
            $URIBuilder = [System.UriBuilder]$DirectLink
        } else {
            $URIBuilder = [System.UriBuilder]"$($Script:PSNexpose.ManagementURL.Trim("/"), $URI.Trim("/") -join "/")"
            $QueryString = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

            # Add any parameters supplied with -Parameters switch to Query String
            if ($Parameters.Count -gt 0) {
                $Parameters.GetEnumerator() | ForEach-Object {
                    $QueryString.Add($_.Name, $_.Value)       
                }
            }

            # Process result limit
            $MaxSize = 500
            if ($Count) {
                if ($Count -lt $MaxSize) {
                    $QueryString.Add("size", $Count)
                    $Count = $Count - $Count
                } else {
                    $QueryString.Add("size", $MaxSize)
                    $Count = $Count - $MaxSize
                }
            }
            if ($Recurse -and $QueryString -notcontains "size") {
                $QueryString.Add("size", $MaxSize)
            }

            # If we have any querystring parameters, add them to the URI
            if ($QueryString.Count -gt 0) {
                $URIBuilder.Query = $QueryString.ToString()
            }
        }
        $Request.Add("URI", $URIBuilder.Uri.OriginalString)

        # Execute the REST call based on the request parameters we've built
        Try {
            Write-Log -Message "[$Method] $($URIBuilder.Uri.OriginalString)" -Level Verbose
            $Response = Invoke-RestMethod @Request
        } Catch {
            Write-Log -Message $RestError.InnerException.Message -Level Warning
            Write-Log -Message $RestError.Message -Level Warning
            Throw
        }

        if ($CountOnly) {
            return $Response.page.totalResources
        } else {
            Write-Output $Response
        }
        
        # Recurse through all results using the pagination cursor
        if ($Recurse) {
            $Next = $Response.links | Where-Object { $_.rel -eq "next" } | Select-Object -ExpandProperty href
            while ($Next) {
                $URIBuilder = [System.UriBuilder]"$Next"
                $Request.URI = $URIBuilder.Uri.OriginalString
                Write-Log -Message "[$Method] $($URIBuilder.Uri.OriginalString)" -Level Verbose
                $Response = Invoke-RestMethod @Request
                Write-Output $Response
                
                Remove-Variable -Name Next
                $Next = $Response.links | Where-Object { $_.rel -eq "next" } | Select-Object -ExpandProperty href
            }
        }

        # Recurse through results until requested count is met. This could result in too many results, the commandlets should deal with returning exact numbers
        if ($Count) {
            $Next = $Response.links | Where-Object { $_.rel -eq "next" } | Select-Object -ExpandProperty href
            while ($Count -gt 0 -and $Next) {
                $URIBuilder = [System.UriBuilder]"$Next"
                $Request.URI = $URIBuilder.Uri.OriginalString
                Write-Log -Message "[$Method] $($URIBuilder.Uri.OriginalString)" -Level Verbose
                $Response = Invoke-RestMethod @Request
                Write-Output $Response
                if ($Count -lt $MaxSize) {
                    $Count = $Count - $Count
                } else {
                    $Count = $Count - $MaxSize
                }
            }
        }
    }
}