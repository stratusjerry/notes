Fixes for Windows 11
===

File Explorer Fixes:
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

Launch Old Windows 10 Cleanup Manager
```powershell
cleanmgr /d C:
# Launch Drive Properties (Shows Disk Space Used)
(New-Object -ComObject Shell.Application).NameSpace(17).ParseName('C:\').InvokeVerb('Properties')
```
