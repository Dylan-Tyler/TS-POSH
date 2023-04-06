#Variables
$TaskName = "Windows Updates - Weekly"
$user = "System" 

#create a scheduled task with powershell
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "C:\IT\Software\PS2EXE-GUI\POSH\WindowsUpdatesv3.exe"
$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Tuesday -At 9am
$ScheduledTask = New-ScheduledTask -Action $action -Trigger $trigger  

Register-ScheduledTask -TaskName $TaskName -InputObject $ScheduledTask -User $user