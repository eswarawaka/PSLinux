<#
.SYNOPSIS
    Retrieves RedHat Satellite hosts based on a search filter.

.DESCRIPTION
    This function connects to the RedHat Satellite API and retrieves hosts that match the specified search filter. 
    If the Username and Password parameters are not provided, the function uses the current user's default credentials.

.PARAMETER Username
    The username to authenticate with the RedHat Satellite server. This parameter is optional.

.PARAMETER Keypath
    The password to authenticate with the RedHat Satellite server. This parameter is optional.

.PARAMETER SatelliteServer
    The URL of the RedHat Satellite server.

.PARAMETER SearchFilter
    The filter to apply when searching for hosts.

.EXAMPLE
    Search-SatelliteHosts -SatelliteServer "https://testserver001.london.test.com" -SearchFilter "model=AHV"
    Retrieves hosts with the model "AHV" using the current user's default credentials.

.EXAMPLE
    Search-SatelliteHosts -Username "test" -keypath "C:\temp\pass.encrypted" -SatelliteServer "https://testserver001.london.test.com" -SearchFilter "model=AHV"
    Retrieves hosts with the model "AHV" using the specified username and password.

.NOTES
    Author: Sundeep Eswarawaka
#>
function Search-SatelliteHosts {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$Username,

        [Parameter(Mandatory = $false)]
        [string]$keypath,

        [Parameter(Mandatory = $true)]
        [string]$SatelliteServer,

        [Parameter(Mandatory = $true)]
        [string]$SearchFilter
    )

    # Check if the TrustAllCertsPolicy type already exists
    if (-not ([AppDomain]::CurrentDomain.GetAssemblies() | 
              ForEach-Object { $_.GetType('TrustAllCertsPolicy', $false) } | 
              Where-Object { $_ })) {
        Add-Type @"
        using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
    }

    # Define the API endpoint
    $ApiEndpoint = "/api/v2/hosts"
    $Filter = "?search=$SearchFilter"

    # Initialize variables for pagination
    $page = 1
    $perPage = 100
    $allResults = @()

    do {
        # Create the full API URL with pagination parameters
        $ApiUrl = "$SatelliteServer$ApiEndpoint$Filter&page=$page&per_page=$perPage"

        # Make the API call
        try {
            if (-not $Username -and -not $keypath) {
                # Use default credentials
                $Response = Invoke-RestMethod -Uri $ApiUrl -Method Get -UseDefaultCredentials -UseBasicParsing
            } else {

                 $securepass = Get-CredentialSecureString -FilePath $keypath
                 # Create a base64-encoded credentials string
                 $AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $Username, $securepass)))

                 # Define the headers
                 $Headers = @{
                     "Authorization" = "Basic $AuthInfo"
                     "Accept" = "application/json"
                 }
                
                # Use provided credentials
                $Response = Invoke-RestMethod -Uri $ApiUrl -Method Get -Headers $Headers -UseBasicParsing
            }
            
            # Append the current page results to the allResults array
            $allResults += $Response.results

            # Check if there are more pages
            $total = $Response.total
            $fetched = $page * $perPage
            $page++

        } catch {
            Write-Error "Error: $_"
            if ($_.Exception.Response -ne $null) {
                $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
                $reader.ReadToEnd()
                $reader.Close()
            }
            break
        }
    } while ($fetched -lt $total)

    # Process the results to create custom objects
    $hosts = $allResults | ForEach-Object {
        [PSCustomObject]@{
            OperatingSystemName = $_.operatingsystem_name
            Name = $_.name
            LocationName = $_.location_name
            Environment = $_.environment_name
            Domain = $_.domain_name
        }
    }

    # Sort and display the results
    $hosts
}