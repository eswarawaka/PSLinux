<#
.SYNOPSIS
    Uploads an Excel file to a SharePoint site.

.DESCRIPTION
    This function connects to a specified SharePoint site and uploads an Excel file from the provided local path to the specified server-relative URL on SharePoint. If username and password are not provided, it will use web login by default.

.PARAMETER SiteUrl
    The URL of the SharePoint site.

.PARAMETER SharePointFileServerRelativeUrl
    The server-relative URL where the Excel file will be uploaded on SharePoint.

.PARAMETER LocalExcelFilePath
    The local path of the Excel file to be uploaded.

.PARAMETER Username
    The username for SharePoint authentication (optional).

.PARAMETER Password
    The password for SharePoint authentication (optional).

.EXAMPLE
    Send-ExcelToSharePoint -SiteUrl "https://contoso.sharepoint.com/sites/Finance" -SharePointFileServerRelativeUrl "/sites/Finance/Shared Documents/report.xlsx" -LocalExcelFilePath "C:\Uploads\report.xlsx"

.EXAMPLE
    Send-ExcelToSharePoint -SiteUrl "https://contoso.sharepoint.com/sites/Finance" -SharePointFileServerRelativeUrl "/sites/Finance/Shared Documents/report.xlsx" -LocalExcelFilePath "C:\Uploads\report.xlsx" -Username "user@contoso.com" -keypath "C:\temp\pass.encrypted"

.NOTES
Author: Sundeep Eswarawaka
#>
function Send-ExcelToSharePoint {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SiteUrl,

        [Parameter(Mandatory = $true)]
        [string]$SharePointFileServerRelativeUrl,

        [Parameter(Mandatory = $true)]
        [string]$LocalExcelFilePath,

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

    # Upload the file
    Add-PnPFile -Path $LocalExcelFilePath -Folder (Split-Path -Parent $SharePointFileServerRelativeUrl)
}