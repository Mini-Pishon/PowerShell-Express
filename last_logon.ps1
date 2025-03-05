# Retrieve the list of all Domain Controllers in the AD domain
$DCList = Get-ADDomainController -Filter * | Sort-Object Name | Select-Object Name

# Target user (SamAccountName)
$TargetUser = "admin.fb"

# Initialize LastLogon to $null as the starting point
$TargetUserLastLogon = $null
    
Foreach($DC in $DCList){

        $DCName = $DC.Name
 
        Try {
            
            # Retrieve the lastLogon attribute value from each Domain Controller (one DC at a time)
            $LastLogonDC = Get-ADUser -Identity $TargetUser -Properties lastLogon -Server $DCName

            # Convert the value to DateTime format
            $LastLogon = [Datetime]::FromFileTime($LastLogonDC.lastLogon)

            # If the obtained value is more recent than the one stored in $TargetUserLastLogon,
            # update the variable: this ensures that we have the most recent lastLogon by the end of the process
            If ($LastLogon -gt $TargetUserLastLogon)
            {
                $TargetUserLastLogon = $LastLogon
            }
 
            # Clean the variable
            Clear-Variable LastLogon
            }

        Catch {
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
}

Write-Host "Last logon date for ${TargetUser}:"
Write-Host $TargetUserLastLogon
