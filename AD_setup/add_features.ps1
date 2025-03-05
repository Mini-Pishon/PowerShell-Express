# Install ADDS + DNS + RSAT Tools

$FeatureList = @("RSAT-AD-Tools", "AD-Domain-Services", "DNS")

foreach ($Feature in $FeatureList) {

   $FeatureState = Get-WindowsFeature -Name $Feature
   if ($FeatureState.InstallState -eq "Available") {

     Write-Output "Feature $Feature will be installed now!"

     try {
        Install-WindowsFeature -Name $Feature -IncludeManagementTools -IncludeAllSubFeature
        Write-Output "$Feature : Installation is a success!"
     } catch {
        Write-Output "$Feature : Error during installation!"
     }
   } else {
      Write-Output "$Feature is already installed or not available for installation."
   }
}
# Schedule task to install new features after restart
$ScriptPath = "c:\scripts\Forest_config.ps1"
$TaskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File `"$ScriptPath`""
$TaskTrigger = New-ScheduledTaskTrigger -AtStartup
$TaskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount
Register-ScheduledTask -Action $TaskAction -Trigger $TaskTrigger -Principal $TaskPrincipal -TaskName "InstallForest"
