#Variables
$TaskName = "Windows Updates - Weekly"
$user = "System" 

#create a scheduled task with powershell
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "C:\TS\WindowsUpdates\settings.xml"
$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Tuesday -At 9am
$ScheduledTask = New-ScheduledTask -Action $action -Trigger $trigger  

Register-ScheduledTask -TaskName $TaskName -InputObject $ScheduledTask -User $user
