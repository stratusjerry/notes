### Installing PowerShell
```bash
# Register the Microsoft RedHat repository
curl https://packages.microsoft.com/config/rhel/8/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo
sudo yum install -y powershell
```

### Start PowerShell
```bash
pwsh
```

### Use PowerShell Gallery repo
```powershell
Install-Module -Name AWSPowerShell -Force #-AllowClobber
Import-Module AWSPowerShell
# Set Powershell profile to load AWS module on future pwsh starts
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force
    Add-Content -Path $PROFILE -Value 'Import-Module AWSPowerShell'
}
# Old Documentation on installing individual PowerShell Gallery repo modules
#Install-Module -Name AWS.Tools.Installer -Force
#Install-AWSToolsModule AWS.Tools.AutoScaling, AWS.Tools.Backup, AWS.Tools.CloudWatch, AWS.Tools.EC2, AWS.Tools.EKS, AWS.Tools.ElasticFileSystem, AWS.Tools.ElasticLoadBalancingV2, AWS.Tools.Route53, AWS.Tools.S3 -SkipUpdate -Force # -CleanUp
```

### TODO:
> If .Net is needed on Linux (maybe only if installing AWSPowerShell.NetCore vs AWSPowerShell.NetCore?), this command will install it:
> ```bash
> #sudo yum install aspnetcore-runtime-6.0
> ```
