<#
.SYNOPSIS
    Ensures that a specified PowerShell module is installed.

.DESCRIPTION
    This function checks if a specified PowerShell module is installed on the system either globally or for the current user. 
    If the module is not installed, it will install the module. If PowerShell is launched with administrative privileges, the module 
    will be installed globally. If launched as a normal user, the module will be installed for the current user scope.

.PARAMETER ModuleName
    The name of the PowerShell module to check and install.

.EXAMPLE
    Ensure-Module -ModuleName 'PnP.PowerShell'

.NOTES
    Author: Sundep Eswarawaka
#>
function Ensure-Module {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModuleName
    )

    function Test-IsAdmin {
        $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }

    # Check if the module is installed
    $moduleInstalled = Get-Module -ListAvailable -Name $ModuleName

    if ($moduleInstalled) {
        Write-Output "Module '$ModuleName' is already installed."
    } else {
        Write-Output "Module '$ModuleName' is not installed. Installing..."

        if (Test-IsAdmin) {
            # Install module globally
            try {
                Install-Module -Name $ModuleName -Force -Scope AllUsers
                Write-Output "Module '$ModuleName' installed globally."
            } catch {
                Write-Error "Failed to install module '$ModuleName' globally. Error: $_"
            }
        } else {
            # Install module for current user
            try {
                Install-Module -Name $ModuleName -Force -Scope CurrentUser
                Write-Output "Module '$ModuleName' installed for current user."
            } catch {
                Write-Error "Failed to install module '$ModuleName' for current user. Error: $_"
            }
        }
    }
}

# Usage example
 Ensure-Module -ModuleName 'pscitrix'
