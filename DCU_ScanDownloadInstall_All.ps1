<#
Dell Command Update - Auto Import Schedule
Dylan Tyler
02.19.2021
Version 1

This script will download Dell Command Update v4 and install to a target directory.
I will update it later as the version changes and can figure out a better method
for getting the version of Dell Command Update.

#>

<#$DownloadURL = "https://dl.dell.com/FOLDER07582851M/2/Dell-Command-Update-Application_8D5MC_WIN_4.3.0_A00_01.EXE"
$DownloadLocation = "C:\TS\apps\Dell\"
 
try {
    $TestDownloadLocation = Test-Path $DownloadLocation
    if (!$TestDownloadLocation) { new-item $DownloadLocation -ItemType Directory -force }
    $TestDownloadLocationZip = Test-Path "$DownloadLocation\DellCommandUpdate.exe"
    if (!$TestDownloadLocationZip) { 
        Invoke-WebRequest -UseBasicParsing -Uri $DownloadURL -OutFile "$($DownloadLocation)\DellCommandUpdate.exe"
        Start-Process -FilePath "$($DownloadLocation)\DellCommandUpdate.exe" -ArgumentList '/s' -Wait
        Set-Service -name 'DellClientManagementService' -StartupType Manual
    }
 
}
catch {
    #write-host "The download and installation of DCUCli failed. Error: $($_.Exception.Message)"
    exit 1
}
#>

#Generates the XML file to the directory
New-Item C:\TS\apps\Dell\ImportSettings.xml -ItemType File -Force
Set-Content C:\TS\apps\Dell\ImportSettings.xml '<Configuration>
<Group Name="Settings" Version="4.3.0" TimeSaved="8/19/2021 11:40:27 AM (UTC -5:00)">
  <Group Name="General">
    <Property Name="SettingsModifiedTime">
      <Value>8/19/2021 11:40:15 AM</Value>
    </Property>
    <Property Name="DownloadPath" Default="ValueIsDefault" />
    <Property Name="CustomCatalogPaths" Default="ValueIsDefault" />
    <Property Name="EnableDefaultDellCatalog" Default="ValueIsDefault" />
    <Property Name="UserConsent" Default="ValueIsDefault" />
    <Property Name="SuspendBitLocker">
      <Value>true</Value>
    </Property>
    <Group Name="CustomProxySettings">
      <Property Name="UseDefaultProxy" Default="ValueIsDefault" />
      <Property Name="Server" Default="ValueIsDefault" />
      <Property Name="Port" Default="ValueIsDefault" />
      <Property Name="UseAuthentication" Default="ValueIsDefault" />
    </Group>
  </Group>
  <Group Name="Schedule">
    <Property Name="ScheduleMode">
      <Value>Weekly</Value>
    </Property>
    <Property Name="Time">
      <Value>2021-02-03T09:00:00</Value>
    </Property>
    <Property Name="DayOfWeek">
      <Value>Tuesday</Value>
    </Property>
    <Property Name="DayOfMonth">
      <Value>16</Value>
    </Property>
    <Property Name="AutomationMode">
      <Value>ScanDownloadApplyNotify</Value>
    </Property>
    <Property Name="ScheduledExecution" Default="ValueIsDefault" />
    <Property Name="RebootWait">
      <Value>OneHour</Value>
    </Property>
  </Group>
  <Group Name="UpdateFilter">
    <Property Name="FilterApplicableMode" Default="ValueIsDefault" />
    <Group Name="RecommendedLevel">
      <Property Name="IsCriticalUpdatesSelected" Default="ValueIsDefault" />
      <Property Name="IsRecommendedUpdatesSelected" Default="ValueIsDefault" />
      <Property Name="IsOptionalUpdatesSelected" Default="ValueIsDefault" />
      <Property Name="IsSecurityUpdatesSelected" Default="ValueIsDefault" />
    </Group>
    <Group Name="UpdateType">
      <Property Name="IsDriverSelected" Default="ValueIsDefault" />
      <Property Name="IsApplicationSelected" Default="ValueIsDefault" />
      <Property Name="IsBiosSelected" Default="ValueIsDefault" />
      <Property Name="IsFirmwareSelected" Default="ValueIsDefault" />
      <Property Name="IsUtilitySelected" Default="ValueIsDefault" />
      <Property Name="IsUpdateTypeOtherSelected" Default="ValueIsDefault" />
    </Group>
    <Group Name="DeviceCategory">
      <Property Name="IsAudioSelected" Default="ValueIsDefault" />
      <Property Name="IsChipsetSelected" Default="ValueIsDefault" />
      <Property Name="IsInputSelected" Default="ValueIsDefault" />
      <Property Name="IsNetworkSelected" Default="ValueIsDefault" />
      <Property Name="IsStorageSelected" Default="ValueIsDefault" />
      <Property Name="IsVideoSelected" Default="ValueIsDefault" />
      <Property Name="IsDeviceCategoryOtherSelected" Default="ValueIsDefault" />
    </Group>
  </Group>
  <Group Name="AdvancedDriverRestore">
    <Property Name="IsCabSourceDell" Default="ValueIsDefault" />
    <Property Name="CabPath" Default="ValueIsDefault" />
    <Property Name="IsAdvancedDriverRestoreEnabled">
      <Value>true</Value>
    </Property>
  </Group>
</Group>
</Configuration>'


#Command to import the settings into Dell Command Update
#$ImportDCUSettings = "C:\TS\apps\Dell\$DCUFilename"
$DCUFilename = "ImportSettings.xml"

#Checks if Zoom is currently in use and will skip install.
$ZoomCheck = (Get-NetUDPEndpoint -OwningProcess (gps Zoom).Id -EA Stop | measure).count

if (Test-Path "C:\Program Files (x86)\Dell\CommandUpdate")
    {

    Start-Process "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList "/scan -report=$DownloadLocation\UpdatesReady -silent" -Wait -WindowStyle Hidden
    Start-Process "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList "/configure -importSettings=C:\TS\apps\Dell\$DCUFilename" -Wait -WindowStyle Hidden
    Start-Process "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList "/scan -silent" -Wait -WindowStyle Hidden
    $ZoomCheck
    Start-Process "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList "/applyupdates -reboot=disable -silent" -Wait -WindowStyle Hidden
    
    }
else
    {

    Start-Process "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList "/scan -report=$DownloadLocation\UpdatesReady -silent" -Wait -WindowStyle Hidden
    Start-Process "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList "/configure -importSettings=C:\TS\apps\Dell\$DCUFilename" -Wait -WindowStyle Hidden
    Start-Process "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList "/scan -silent" -Wait -WindowStyle Hidden
    $ZoomCheck
    Start-Process "C:\Program Files\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList "/applyupdates -reboot=disable -silent" -Wait -WindowStyle Hidden
    
    }





#This code was from a previous script that I excluded since I needed to generate the XML config more indepth.
<#
[xml]$XMLReport = get-content "$DownloadLocation\DCUApplicableUpdates.xml"
 
$AvailableUpdates = $XMLReport.updates.update
 
$BIOSUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "BIOS" }).name.Count
$ApplicationUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "Application" }).name.Count
$DriverUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "Driver" }).name.Count
$FirmwareUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "Firmware" }).name.Count
$OtherUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "Other" }).name.Count
$PatchUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "Patch" }).name.Count
$UtilityUpdates = ($XMLReport.updates.update | Where-Object { $_.type -eq "Utility" }).name.Count
$UrgentUpdates = ($XMLReport.updates.update | Where-Object { $_.Urgency -eq "Urgent" }).name.Count
#>

#We now remove the item, because we don't need it anymore, and sometimes fails to overwrite
Remove-Item "C:\TS\apps\Dell\$DCUFilename" -Force
Remove-Item "C:\TS\apps\Dell\DellCommandUpdate.exe" -Force


#Scans for the latest driver updates and creates a log til showing which ones were ready to be installed & when.



#Applies the latest updates to the target computer silently.




#Insert desktop notification
#This will be done at a later time to help encourage users to restart their computers.



