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
rem Disable Window Snapping
reg add "HKCU\Control Panel\Desktop" /v WindowArrangementActive /t REG_SZ /d "0" /f
rem Restore Window Snapping
reg add "HKCU\Control Panel\Desktop" /v WindowArrangementActive /t REG_SZ /d "1" /f
rem Restart Explorer to make settings above appear
taskkill /f /im explorer.exe & start explorer.exe
```

## Launch Old Windows 10 Cleanup Manager
```powershell
cleanmgr /d C:
# Launch Drive Properties (Shows Disk Space Used)
(New-Object -ComObject Shell.Application).NameSpace(17).ParseName('C:\').InvokeVerb('Properties')
```

## Group Policy
Preferred Windows Options, some may not work due to MS Changes
### `Computer Configuration` > `Administrative Templates`
-  `Start Menu and Taskbar`
   - `Remove Personalized Website Recommendations from the Recommended section in the Start Menu` : **Enabled**
   - `Remove Recommended section from Start Menu` : **Enabled**
- `Windows Components/Search`
   - `Allow Cloud Search` : **Disabled**
   - `Allow Cortana` : **Disabled**
   - `Do not allow web search` : **Enabled**
   - `Don't search the web or display web results in Search` : **Enabled**
   - `Don't search the web or display web results in Search over metered connections` : **Enabled**
- `Windows Components/Widgets`
   - `Allow widgets` : **Disabled**
   - `Disable Widgets Board` : **Enabled**
- `Windows Components/Windows AI`
   - `Allow export of Recall and snapshot information` : **Disabled**
   - `Allow Recall to be Enabled` : **Disabled**
   - `Turn off saving snapshots for use with Recall` : **Enabled**
- `Windows Components/Windows Update/Manage end user experience/Configure Automatic Updates`
   - `Configure automatic updating:` : **3 - Auto download and notify for install**
   - > Note: may toggle below based on drivers
   - `Install updates for other Microsoft products` : **Enabled**
- `Windows Components/Windows Update/Manage updates offered from Windows Update`
   - `Which Windows product version would you like to receive feature updates for? e.g., Windows 10` : **Windows 11**
   - `Target Version for Feature Updates` : **_24H2_** / **_25H2_**
### `User Configuration` > `Administrative Templates`
- `Start Menu and Taskbar` `Force classic Start Menu` : **Enabled**
- `Windows Components` > `File Explorer`
   - `Turn off display of recent search entries in the File Explorer search box` : **Enabled**
- `Windows Components` > `Search`
   - `Turn off storage and display of search history` : **Enabled**
- `Windows Components` > `Windows Copilot`
   - `Turn off Windows Copilot` : **Enabled**

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
wsl --version # Get wsl version
wsl --update # Updates wsl, doesn't prompt, see https://github.com/microsoft/WSL/releases
wsl --shutdown # Gracefully shuts down all running WSL distros.
# Show wsl disk usage
Get-Item "$env:USERPROFILE\AppData\Local\Packages\*\LocalState\*.vhdx", "$env:USERPROFILE\AppData\Local\Docker\wsl\disk\*.vhdx" -ErrorAction SilentlyContinue | ForEach-Object { "{0,-70} {1,6:N1} GB" -f $_.FullName, ($_.Length / 1GB) }
```

### Restricting WSL Windows Host Drive folder access
Currently there is no official support **from the Windows Host** to restrict WSL VM access to Windows Host folders. The only (less secure) supported option is to use ['/etc/wsl.conf'](https://learn.microsoft.com/en-us/windows/wsl/wsl-config#automount-settings) from within a WSL VM to restrict folder access via `automount` and `mountFsTab`(`/etc/fstab`).
