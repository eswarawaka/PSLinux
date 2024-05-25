<#
.SYNOPSIS
    Encrypts or decrypts a password using a predefined key.

.DESCRIPTION
    This function can either encrypt a plain text password and save it to a file or decrypt an encrypted password from a file and display it as plain text.
    The encryption and decryption process uses a predefined 32-byte key. If the Action parameter is not specified and the FilePath is provided,
    the function will default to decrypting the password.

.PARAMETER Action
    Specifies the action to perform. Valid value is "Encrypt". If not provided, the default action is "Decrypt".

.PARAMETER Password
    The plain text password to encrypt. This parameter is used only when the Action is "Encrypt".

.PARAMETER FilePath
    The file path where the encrypted password will be saved (for encryption) or read from (for decryption).

.EXAMPLE
    Get-CredentialSecureString -Action "Encrypt" -Password "YourPassword" -FilePath "C:\temp\pass.txt"
    Encrypts the password "YourPassword" and saves the encrypted string to C:\temp\pass.txt.

.EXAMPLE
    Get-CredentialSecureString -FilePath "C:\temp\pass.txt"
    Decrypts the password from C:\temp\pass.txt and displays the plain text password.

.NOTES
    Author: Sundeep Eswarawaka
#>
function Get-CredentialSecureString {
    param (
        [string]$Action,
        [string]$Password,
        [string]$FilePath
    )

    # Define the key inside the function
    $Key = [byte[]] (0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10,
                     0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20)  # 32 bytes key

    # Default to "Decrypt" if Action is not specified and FilePath is provided
    if (-not $Action -and $FilePath) {
        $Action = "Decrypt"
    }

    switch ($Action) {
        "Encrypt" {
            if (-not $Password) {
                Write-Error "Password parameter is required for encryption."
                return
            }
            
            # Convert the plain text password to a secure string
            $SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
            
            # Convert the secure string to an encrypted string using the custom key
            $EncryptedString = $SecurePassword | ConvertFrom-SecureString -Key $Key
            
            # Save the encrypted string to a file
            $EncryptedString | Out-File -FilePath $FilePath
            Write-Output "Password encrypted and saved to $FilePath"
        }
        "Decrypt" {
            if (-not $FilePath) {
                Write-Error "FilePath parameter is required for decryption."
                return
            }

            # Read the encrypted string from the file
            $EncryptedString = Get-Content -Path $FilePath -Raw
            
            # Convert the encrypted string back to a secure string using the custom key
            $DecryptedSecureString = $EncryptedString | ConvertTo-SecureString -Key $Key
            
            # Convert the secure string back to plain text
            $PlainTextPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($DecryptedSecureString))
            
            # Output the plain text password
            Write-Output "$PlainTextPassword"
        }
        default {
            Write-Error "Invalid action. Please use 'Encrypt' or provide a valid FilePath for decryption."
        }
    }
}