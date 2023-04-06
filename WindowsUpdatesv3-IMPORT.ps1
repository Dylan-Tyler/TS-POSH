# .Net methods for hiding/showing the console in the background
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

function Show-Console {
    $consolePtr = [Console.Window]::GetConsoleWindow()

    # Hide = 0,
    # ShowNormal = 1,
    # ShowMinimized = 2,
    # ShowMaximized = 3,
    # Maximize = 3,
    # ShowNormalNoActivate = 4,
    # Show = 5,
    # Minimize = 6,
    # ShowMinNoActivate = 7,
    # ShowNoActivate = 8,
    # Restore = 9,
    # ShowDefault = 10,
    # ForceMinimized = 11

    [Console.Window]::ShowWindow($consolePtr, 4)
}

function Hide-Console {
    $consolePtr = [Console.Window]::GetConsoleWindow()
    #0 hide
    [Console.Window]::ShowWindow($consolePtr, 0)
}

Hide-Console
#Show-Console -hide
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
New-Item -Path "C:\TS\" -ItemType Directory -Force
if (! (Test-Path "C:\TS\WindowsUpdates\logs")) {
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\.NetFramework\v4.0.30319' -Name 'SchUseStrongCrypto' -Value '1' -Type DWord
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Register-PSRepository -Name "PSGallery" –SourceLocation "https://www.powershellgallery.com/api/v2/" -InstallationPolicy Trusted
Invoke-WebRequest https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile 'C:\TS\Nuget.exe'
Get-PackageProvider 'NuGet' -Force
Import-PackageProvider -Name 'NuGet'
Install-PackageProvider -Name 'NuGet' -MinimumVersion 3.0.0.1 -Force
Install-Module PowershellGet -RequiredVersion 2.2.4.1 -Force
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Get-Module PSWindowsUpdate
Import-Module PSWindowsUpdate -Force
Install-Module PSWindowsUpdate -Confirm:$False -Force
Add-WUServiceManager -ServiceID "7971f918-a847-4430-9279-4a52d1efe18d" -Confirm:$false
}
#Add-WUServiceManager -ServiceID "9482f4b4-e343-43b6-b170-9a65bc822c77" -Confirm:$False
<#[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    if (!($true -eq (Get-Module PSWindowsUpdate))) {
        Get-PackageProvider -Name "nuget" -ForceBootstrap
        Install-Module PSWindowsUpdate -Force
#>
#More info on how to use the module to fit your needs
#https://www.techrepublic.com/article/how-to-use-powershell-to-manage-microsoft-updates-on-windows/
Get-WindowsUpdate
Start-Sleep 5
New-Item -Path "C:\TS\WindowsUpdates\logs" -ItemType Directory -Force
#Get specific updates
#Get-WindowsUpdate -KBArticleID "KB1111111","KB2222222","etc" -Install 

#Exclude updates or specific Microsoft apps
#Install-WindowsUpdate -NotTitle "Teams" -AcceptAll
#Install-WindowsUpdate -NotCategory "Drivers","FeaturePacks" -AcceptAll 

Install-WindowsUpdate -MicrosoftUpdate -NotCategory "Drivers","FeaturePacks" -AcceptAll -IgnoreReboot | Out-File "C:\TS\WindowsUpdates\logs\$(get-date -f yyyy-MM-dd)-MicrosoftUpdates.log" -Force -Append
Install-WindowsUpdate -WindowsUpdate -NotCategory "Drivers","FeaturePacks" -AcceptAll -IgnoreReboot | Out-File "C:\TS\WindowsUpdates\logs\$(get-date -f yyyy-MM-dd)-WindowsUpdates.log" -Force -Append
#Exit