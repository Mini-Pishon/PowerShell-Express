while ($true) {
    # Ask for file path
    $filePath = Read-Host -Prompt "Enter the path to the file (or type 'quit' to exit)"

    # Check if the user wants to quit
    if ($filePath -eq 'quit') {
        Write-Output "Exiting the script."
        break
    }

    # Ask for the hashing algorithm
    $Algo = Read-Host -Prompt "Enter the algorithm you want to use (e.g., SHA256, SHA512)"

    # Check if the file exists
    if (Test-Path -Path $filePath) {
        # Calculate the checksum using the specified algorithm
        $fileHash = Get-FileHash -Path $filePath -Algorithm $Algo

        # Output the checksum
        Write-Output "The $Algo checksum of the file is: $($fileHash.Hash)"
    } else {
        Write-Output "The specified file does not exist."
    }

    # Ask the user if they want to check another file
    $continue = Read-Host -Prompt "Do you want to check another file? (yes/no)"
    if ($continue -ne 'yes') {
        Write-Output "Exiting the script."
        break
    }
}
