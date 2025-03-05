function Compare-ADUserGroups {
    <#
    This script is made to compare Users' groups.
    #>

    param (
        [string]$User1,
        [string]$User2
    )

    # Get first user groups
    $user1Groups = Get-ADUser -Identity $User1 -Properties MemberOf | Select-Object -ExpandProperty MemberOf

    # Get second user groups
    $user2Groups = Get-ADUser -Identity $User2 -Properties MemberOf | Select-Object -ExpandProperty MemberOf

    # Find groups in common
    $commonGroups = $user1Groups | Where-Object { $user2Groups -contains $_ }

    # Find User 1 specific groups
    $user1SpecificGroups = $user1Groups | Where-Object { $user2Groups -notcontains $_ }

    # Find User 2 specific groups 
    $user2SpecificGroups = $user2Groups | Where-Object { $user1Groups -notcontains $_ }

    # Display results
    Write-Host "Groups in common:"
    if ($commonGroups) {
        $commonGroups | ForEach-Object { Get-ADGroup -Identity $_ | Select-Object Name } | Format-Table -AutoSize
    } else {
        Write-Host "No common group."
    }

    Write-Host "Specific groups to $User1 :"
    if ($user1SpecificGroups) {
        $user1SpecificGroups | ForEach-Object { Get-ADGroup -Identity $_ | Select-Object Name } | Format-Table -AutoSize
    } else {
        Write-Host "No specific group to $User1."
    }

    Write-Host "Specific groups to $User2 :"
    if ($user2SpecificGroups) {
        $user2SpecificGroups | ForEach-Object { Get-ADGroup -Identity $_ | Select-Object Name } | Format-Table -AutoSize
    } else {
        Write-Host "No specific group to $User2."
    }
}

#  Ask user to write users' names to compare
$user1 = Read-Host "Write User 1 name (SamAccountName)"
$user2 = Read-Host "Write User 2 name  (SamAccountName)"
Compare-ADUserGroups -User1 $user1 -User2 $user2
