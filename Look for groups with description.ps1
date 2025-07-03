# Requires ActiveDirectory module

function Get-ADGroupsByDescription {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SearchString
    )

    try {
        $groups = Get-ADGroup -Filter "Description -like '*$SearchString*'" -Properties Description |
                  Select-Object Name, SamAccountName, Description

        if ($groups.Count -eq 0) {
            Write-Host "No groups found with description containing '$SearchString'" -ForegroundColor Yellow
        } else {
            $groups | Format-Table -AutoSize
        }
    } catch {
        Write-Error "Error retrieving groups: $_"
    }
}

# Prompt the user for input
$inputDescription = Read-Host "Enter a keyword or part of the description to search for"
Get-ADGroupsByDescription -SearchString $inputDescription
