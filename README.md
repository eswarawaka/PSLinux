# Name: RedHatSatelliteSearch

## Description
The RedHatSatelliteSearch PowerShell module provides functions to retrieve and manage data from a RedHat Satellite server. This module allows users to specify search filters to query and fetch information about hosts and other resources managed by the Satellite server.

## Features
- **Retrieve Hosts**: Fetch detailed information about hosts based on specific search filters.
- **Flexible Authentication**: Supports both credential-based and web login authentication methods.
- **Data Integration**: Easily integrate the retrieved data into other systems or processes.
- **Excel Integration**: Update and manage Excel tables with the retrieved data.

## Functions
### Get-SatelliteHosts
Retrieves detailed information about hosts from the RedHat Satellite server based on specified search filters.

#### Parameters:
- **SiteUrl**: The URL of the RedHat Satellite server.
- **SearchFilter**: The search filter to apply when retrieving hosts.
- **Username** (optional): The username for authentication.
- **Password** (optional): The password for authentication.

### Update-ExcelTable
Updates an Excel table with new data.

#### Parameters:
- **ExcelPath**: The path to the Excel file.
- **WorksheetName**: The name of the worksheet to update.
- **ValuesToUpdate**: A hashtable containing the values to update in the Excel table.
- **TableName**: The name of the table to create in the Excel file.

## Usage Examples
### Retrieve Hosts with Search Filter
```powershell
Get-SatelliteHosts -SatelliteServer "https://satellite.example.com" -SearchFilter "environment=production"
