Fixes for Windows 11
===

## File Explorer Fixes:
```batch
rem Disable new context menu:
reg.exe add "HKCU\Software\Classes\CLSID\{86CA1AA0-34AA-4E8B-A509-50C905BAE2A2}\InprocServer32" /f /ve
rem Restore new context menu:
reg.exe delete "HKCU\Software\Classes\CLSID\{86CA1AA0-34AA-4E8B-A509-50C905BAE2A2}" /f
rem Disable Explorer command bar:
reg.exe add "HKCU\Software\Classes\CLSID\{D93ED569-3B3E-4BFF-8355-3C44F6A52BB5}\InprocServer32" /f /ve
rem Restore Explorer command bar:
reg.exe delete "HKCU\Software\Classes\CLSID\{D93ED569-3B3E-4BFF-8355-3C44F6A52BB5}" /f
rem Restart Explorer to make settings above appear
taskkill /f /im explorer.exe & start explorer.exe
```

## Launch Old Windows 10 Cleanup Manager
```powershell
cleanmgr /d C:
# Launch Drive Properties (Shows Disk Space Used)
(New-Object -ComObject Shell.Application).NameSpace(17).ParseName('C:\').InvokeVerb('Properties')
```

## Windows Task Scheduler
Create a Windows Scheduled Task to set an alarm for a certain time

```powershell
$hrDelay = 4  # Configurable alarm delay
$un = "$env:USERNAME"
$taskName = "Alarm"
$actionArg = "${un} /w 'An alarm to Leave' "
$action = New-ScheduledTaskAction -Execute "msg" -Argument $actionArg
$description = "An alarm for a time"
$loggedInUser = $env:USERDOMAIN + "\" + $un
$principal = New-ScheduledTaskPrincipal -UserId $loggedInUser
$ct = Get-Date
$dt = $ct.AddHours($hrDelay)
$trigger = New-ScheduledTaskTrigger -Once -At $dt
$settings = New-ScheduledTaskSettingsSet
$task = New-ScheduledTask -Description $description -Action $action -Principal $principal -Trigger $trigger -Settings $settings
Register-ScheduledTask "Alarm" -InputObject $task
```

## Windows Subsystem for Linux (WSL)
```powershell
wsl --list --online # Show available Linux distributions
wsl --install -d Ubuntu-24.04 # Downloaded newest Ubuntu
wsl --list --running
wsl --shutdown	# Gracefully shuts down all running WSL distros.
# Show wsl disk usage
Get-Item "$env:USERPROFILE\AppData\Local\Packages\*\LocalState\*.vhdx", "$env:USERPROFILE\AppData\Local\Docker\wsl\disk\*.vhdx" -ErrorAction SilentlyContinue | ForEach-Object { "{0,-70} {1,6:N1} GB" -f $_.FullName, ($_.Length / 1GB) }
```

### Restricting WSL Windows Host Drive folder access
Currently there is no official support **from the Windows Host** to restrict WSL VM access to Windows Host folders. The only (less secure) supported option is to use ['/etc/wsl.conf'](https://learn.microsoft.com/en-us/windows/wsl/wsl-config#automount-settings) from within a WSL VM to restrict folder access via `automount` and `mountFsTab`(`/etc/fstab`).
