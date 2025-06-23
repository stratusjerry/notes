## Searching with RipGrep
Setup on Windows
```powershell
$rgVersion = "14.1.1"
$zipUrl = "https://github.com/BurntSushi/ripgrep/releases/download/$rgVersion/ripgrep-$rgVersion-x86_64-pc-windows-msvc.zip"
$downloads = Join-Path $env:USERPROFILE "Downloads"
$zipPath = Join-Path $downloads "ripgrep-$rgVersion.zip"
# Download the Zip file
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath
# Extract the Zip
Expand-Archive -Path $zipPath -DestinationPath $downloads -Force
# Set the ripgrep executable to a variable then invoke it with "&"
$rg = Join-Path $downloads "ripgrep-$rgVersion-x86_64-pc-windows-msvc\rg.exe"
# Search sub directories for text 'aws_lb_target_group' in file types ending in tf
& $rg "aws_lb_target_group" --type tf
# Find saltstack formulas using invalid python string formatter
cd ..\saltstack-formulas\
& $rg "%s'\.format"
```
