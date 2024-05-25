<#
.SYNOPSIS
    Updates an Excel table with new data.

.DESCRIPTION
    This function imports data from a specified worksheet in an Excel file, updates the data with new values provided in a hashtable, and then exports the updated data back to the Excel file, formatting it as a table.

.PARAMETER ExcelPath
    The path to the Excel file.

.PARAMETER WorksheetName
    The name of the worksheet to update.

.PARAMETER ValuesToUpdate
    A hashtable containing the values to update in the Excel table.

.PARAMETER TableName
    The name of the table to create in the Excel file.

.EXAMPLE
    $values = @{ "Column1" = "Value1"; "Column2" = "Value2" }
    Update-ExcelTable -ExcelPath "C:\Reports\report.xlsx" -WorksheetName "Sheet1" -ValuesToUpdate $values -TableName "MyTable"

.NOTES
    Author: Sundeep Eswarawaka
#>
function Update-ExcelTable {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ExcelPath,

        [Parameter(Mandatory = $true)]
        [string]$WorksheetName,

        [Parameter(Mandatory = $true)]
        [hashtable]$ValuesToUpdate,

        [Parameter(Mandatory = $true)]
        [string]$TableName
    )

    # Import the ImportExcel module
    Import-Module ImportExcel

    # Import existing data from the Excel worksheet
    $existingData = Import-Excel -Path $ExcelPath -WorksheetName $WorksheetName

    # Convert the hashtable of updates to an object and add to existing data
    $newDataRow = New-Object -TypeName PSObject
    foreach ($key in $ValuesToUpdate.Keys) {
        $newDataRow | Add-Member -MemberType NoteProperty -Name $key -Value $ValuesToUpdate[$key]
    }
    $combinedData = $existingData + $newDataRow

    try {
        # Clear the existing Excel file content by removing the file
        Remove-Item -Path $ExcelPath -Force

        # Export the combined data back to a new Excel file, creating a table
        $combinedData | Export-Excel -Path $ExcelPath -WorksheetName $WorksheetName -TableName $TableName -TableStyle Medium2 -AutoFilter -AutoNameRange

        Write-Host "Excel file at '$ExcelPath' has been updated with new data and formatted as a table."
    }
    catch {
        Write-Error "Failed to update Excel file: $_"
    }
}

# Example usage
$values = @{ "Column1" = "Value1"; "Column2" = "Value2" }
Update-ExcelTable -ExcelPath "C:\Reports\report.xlsx" -WorksheetName "Sheet1" -ValuesToUpdate $values -TableName "MyTable"
