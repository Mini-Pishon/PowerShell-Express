# Look for AD groups by name or description

function Get-ADGroupInteractive {
    [CmdletBinding()]
    param()

    # 1. Ensure the AD module is available
    try {
        Import-Module ActiveDirectory -ErrorAction Stop
    } catch {
        Write-Error "ActiveDirectory module not available. Install RSAT or import the module first."
        return
    }

    # 2. Ask whether to search by Name or Description
    Write-Host "Search AD groups by:"
    Write-Host "  1) Name"
    Write-Host "  2) Description"
    $choice = Read-Host -Prompt 'Enter 1 or 2'
    if ($choice -ne '1' -and $choice -ne '2') {
        Write-Warning "Invalid selection. Exiting."
        return
    }

    # 3. Prompt for the filter value
    if ($choice -eq '1') {
        $promptText = 'Enter group Name (supports * as wildcard, e.g. HR-*)'
        $filterProp = 'Name'
    } else {
        $promptText = 'Enter Description text (supports * as wildcard, e.g. *finance*)'
        $filterProp = 'Description'
    }
    $rawFilter = Read-Host -Prompt $promptText
    if ([string]::IsNullOrWhiteSpace($rawFilter)) {
        Write-Host "No filter provided. Exiting."
        return
    }

    # 4. Retrieve matching groups
    #   Always load Description so we can display it
    $adFilter = "$filterProp -like '$rawFilter'"
    $groups   = Get-ADGroup -Filter $adFilter -Properties Description
    if (-not $groups) {
        Write-Host "No AD groups found matching `$filterProp -like '$rawFilter'`."
        return
    }

    # 5. List them with indices
    Write-Host "`nFound groups:"
    for ($i = 0; $i -lt $groups.Count; $i++) {
        $idx  = $i + 1
        $name = $groups[$i].Name
        $desc = if ([string]::IsNullOrEmpty($groups[$i].Description)) { '<none>' } else { $groups[$i].Description }
        Write-Host "[$idx] $name — $desc"
    }

    # 6. Ask which one to inspect
    $sel = Read-Host -Prompt "`nEnter the number of the group to view details"
    if (
        -not [int]::TryParse($sel, [ref]$num) -or
        $num -lt 1 -or
        $num -gt $groups.Count
    ) {
        Write-Warning "Invalid selection. Exiting."
        return
    }

    # 7. Show Name + Description
    $chosen = $groups[$num - 1]
    $desc   = if ([string]::IsNullOrEmpty($chosen.Description)) { '<none>' } else { $chosen.Description }

    Write-Host "`nName:        $($chosen.Name)"
    Write-Host "Description: $desc"
}

# To run:
Get-ADGroupInteractive
