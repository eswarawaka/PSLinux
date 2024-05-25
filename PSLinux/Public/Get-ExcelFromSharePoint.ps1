<#
.SYNOPSIS
    Downloads an Excel file from a SharePoint site.

.DESCRIPTION
    This function connects to a specified SharePoint site and downloads an Excel file from the provided server-relative URL to a local path. If username and password are not provided, it will use web login by default.

.PARAMETER SiteUrl
    The URL of the SharePoint site.

.PARAMETER SharePointFileServerRelativeUrl
    The server-relative URL of the Excel file on SharePoint.

.PARAMETER LocalDownloadPath
    The local directory path where the Excel file will be downloaded.

.PARAMETER Username
    The username for SharePoint authentication (optional).

.PARAMETER Password
    The password for SharePoint authentication (optional).

.EXAMPLE
    Get-ExcelFromSharePoint -SiteUrl "https://contoso.sharepoint.com/sites/Finance" -SharePointFileServerRelativeUrl "/sites/Finance/Shared Documents/report.xlsx" -LocalDownloadPath "C:\Downloads"

.EXAMPLE
    Get-ExcelFromSharePoint -SiteUrl "https://contoso.sharepoint.com/sites/Finance" -SharePointFileServerRelativeUrl "/sites/Finance/Shared Documents/report.xlsx" -LocalDownloadPath "C:\Downloads" -Username "user@contoso.com" -keypath "C:\temp\pass.encrypted"

.NOTES
Author: Sundeep Eswarawaka
#>
function Get-ExcelFromSharePoint {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SiteUrl,

        [Parameter(Mandatory = $true)]
        [string]$SharePointFileServerRelativeUrl,

        [Parameter(Mandatory = $true)]
        [string]$LocalDownloadPath,

        [Parameter(Mandatory = $false)]
        [string]$Username,

        [Parameter(Mandatory = $false)]
        [string]$keypath
    )

    # Connect to SharePoint Online
    if ($PSBoundParameters.ContainsKey('Username') -and $PSBoundParameters.ContainsKey('keypath')) {
        $securepass = Get-CredentialSecureString -FilePath $keypath
        $securePassword = ConvertTo-SecureString -String $securepass -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential($Username, $securePassword)
        Connect-PnPOnline -Url $SiteUrl -Credentials $credential -WarningAction SilentlyContinue
    } else {
        Connect-PnPOnline -Url $SiteUrl -UseWebLogin -WarningAction SilentlyContinue
    }

    # Extract the filename from the server-relative URL
    $filename = Split-Path -Leaf $SharePointFileServerRelativeUrl

    # Download the file
    Get-PnPFile -Url $SharePointFileServerRelativeUrl -Path $LocalDownloadPath -Filename $filename -AsFile -Force
}