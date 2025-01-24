Notes on Linux commands

## SELinux
```bash
# Check SELinux status
sestatus
# Temporarily Disable SELinux
setenforce 0
# Another Option for temporarily disabling
setenforce Permissive
# Yet another Option for temporarily disabling
echo 0 > /selinux/enforce
# Permanently disable SELinux by setting "SELINUX=disabled" in "vi /etc/sysconfig/selinux"
vi /etc/sysconfig/selinux
# Search audit log for SELINUX blocks
ausearch -m AVC,USER_AVC,SELINUX_ERR -ts today
#type=AVC msg=audit(1688751779.719:7276): avc:  denied  { write } for  pid=1033785 comm="python3" name="pvc-aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1_mongodb" dev="nvme0n1p2" ino=345119533 scontext=system_u:system_r:container_t:s0:c395,c878 tcontext=system_u:object_r:usr_t:s0 tclass=dir permissive=0
#type=AVC msg=audit(1688751799.866:7279): avc:  denied  { write } for  pid=1035742 comm="java" name="pvc-aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5_data-elasticsearch-0" dev="nvme0n1p2" ino=353260961 scontext=system_u:system_r:container_t:s0:c207,c570 tcontext=system_u:object_r:usr_t:s0 tclass=dir permissive=0
# Create an SELinux policy to allow the blocked action
grep python3 /var/log/audit/audit.log  | audit2allow -M python3
grep java /var/log/audit/audit.log  | audit2allow -M java
semodule -i python3.pp
semodule -i java.pp
# list semanage filecontexts
semanage fcontext --list
```

## Networking
```bash
# Check if firewalld Log Denied is enabled
firewall-cmd --get-log-denied
# Enable firewalld Log Denied
firewall-cmd --set-log-denied=all
# Permanently enable LogDenied messages in "/etc/firewalld/firewalld.conf" by setting "LogDenied=all"
vi /etc/firewalld/firewalld.conf
# Set firewalld debug logging to highest level in "/etc/firewalld/firewalld.conf" by setting "FIREWALLD_ARGS=--debug=10"
vi /etc/firewalld/firewalld.conf
# Restart the firewalld service
systemctl restart firewalld.service
# Check firewalld Log
tail -f /var/log/firewalld
# List iptables rules in a chain or all chains (--list OR -L)
sudo iptables --list  # uses "filter" tables as default if no table specified
sudo iptables --table nat --list
sudo iptables --table nat --list | grep -v 8443 | grep 443
# Print the rules in a chain or all chains (--list-rules OR -S). Useful when adding rules
sudo iptables --list-rules  # If no chain is selected, all chains are printed
## RHEL 7, 8, 9 Avahi
# Temporarily disable avahi
systemctl stop avahi-daemon.socket
systemctl stop avahi-daemon.service
# Permanently disable avahi
systemctl disable avahi-daemon.socket
systemctl disable avahi-daemon.service
```

`firewall-cmd` options, note these may not show the running config
| `firewall-cmd` option    | Description |
|-                         |-            |
| `--state`                | Return and print firewalld state            | 
| `--reload`               | Reload firewall and keep state information  |
| `--complete-reload`      | Reload firewall and lose state information  |
| `--runtime-to-permanent` | Create permanent from runtime configuration |
| `--check-config`         | Check permanent configuration for errors    |

## Search / Find
```bash
# Search for text in all files under a directory
grep -r "text to find" .
# Find files with name suffix ".txt" and look for text within those files
#  Note: running with '+' is significantly faster as it only invokes 1 instance of grep against all files as
#  parameters versus a find and invocation of grep for every file match
find . -name \*.txt -type f -exec grep -Hn 'searchtext' {} \+
# Find a file using mlocate
sudo yum install -y mlocate
sudo updatedb
#  Find uses regex by default, use "-b \filename" option to find specific file
sudo locate -b "\kubectl"
```

## SSH
```bash
# Use ssh-agent as a keystore. Verify ~/.ssh/config file has "ForwardAgent" set for host
eval $(ssh-agent)
ssh-add '/home/user/.ssh/id_rsa.pem'
# List loaded certs
ssh-add -l
# -Y : Enables X11 forwarding
ssh -Y hostname
# Test SSH ForwardAgent
echo "$SSH_AUTH_SOCK"
```

## (Un)Compress files
```bash
# Create a tar/gz file with the contents of the directory ./dir
#   -c : Create new archive; -z Filter archive through gzip;  -v : verbose; -f : file to output
tar -czvf file.tar.gz ./dir
# Extract to current working directory
tar -xvf file.tar.gz
```

## Grub bootloader
```bash
# Display info for all kernel menu entries
grubby --info=ALL
# Display default kernel path/index/title
grubby --default-kernel # --default-index ; --default-title
# Display boot information for kernel in path 0
grubby --info=0
# Set the default kernel to index entry 0
grubby --set-default-index=0
# Changes to default kernel above, requiring updating file
#   BIOS based machines: "/boot/grub2/grub.cfg"
#   UEFI based machines: "/boot/efi/EFI/redhat/grub.cfg"
grub2-mkconfig -o /boot/grub2/grub.cfg
```

## Yum / RPM / Package install

```bash
# Get yum history and get detailed package information about a specific yum action
sudo yum history
sudo yum history info 151
# Get a list of packages available in yum repo "kubernetes"
sudo yum repo-pkgs kubernetes list
sudo dnf repo-pkgs rancher-rke2-1-28-latest list
sudo dnf repo-pkgs rancher-rke2-common-latest list
# RPM package information
rpm -qpil --changelog --scripts file.rpm # Get RPM package information
rpm -qa --last # View installed packaged sorted by install order
# Add 7zip support and extract a 7zip file
sudo yum install p7zip p7zip-plugins -y
7za x foo.7z
# Get the list of install scripts from an rpm
rpm -qp --scripts salt-ssh-3006.3-0.x86_64.rpm
# Get the list of dependencies from an rpm
rpm -qR salt-ssh-3006.3-0.x86_64.rpm
# cpio extract
```

cpio flags
- `-i`/`--extract` : Run in copy-in mode
- `-d`/`--make-directories` : Create leading directories
- `-m`/`--preserve-modification-time` : Retain file modification times

Use the `repoquery` command to determine what packages require a certain package
```bash
repoquery -q --installed --whatrequires dbus-x11
```

Install updates from a specific repo
```bash
## CentOS 7
# Get a list of CentOS 7 repositories
yum repolist
# Disable docker-ce and hashicorp yum repositories. A useful alternative to something like locking packages, if
#  someone is blindly running non repo scoped updates (total hypothetical :P )
yum-config-manager --disable docker-ce hashicorp
# List CentOS 7 available packages only for specific repositories like 'updates' (kernel)
yum --disablerepo='*' --enablerepo='updates' list updates
# CentOS7 elrepo repo
yum --disablerepo='*' --enablerepo='elrepo-kernel' list updates

## RHEL 8
# Get a list of RHEL 8 repositories
sudo dnf repolist
sudo dnf repolist all # Also show disabled repositories
# Disable docker-ce repository. A useful alternative to something like locking packages, if
#  someone is blindly running non repo scoped updates (total hypothetical :P )
sudo dnf config-manager --disable docker-ce-stable
# Work around RHEL 'subscription-manager' error messages by enabling EPEL. Required to install certain EPEL packages
sudo dnf config-manager --enable epel
# List RHEL 8 available packages only for specific repositories like rhel-8-baseos-rhui-rpms (kernel)
sudo dnf --disablerepo='*' --enablerepo=epel list available
sudo dnf --disablerepo='*' --enablerepo=rhel-8-baseos-rhui-rpms list available
sudo dnf --disablerepo='*' --enablerepo=rhel-8-appstream-rhui-rpms list available
# List RHEL 8 upgradeable packages only for specific repositories
sudo dnf --disablerepo='*' --enablerepo=epel list updates
sudo dnf --disablerepo='*' --enablerepo=rhel-8-baseos-rhui-rpms list updates
sudo dnf --disablerepo='*' --enablerepo=rhel-8-appstream-rhui-rpms list updates
# dnf upgrade RHEL 8 package from specific repositories. We may need "--nobest" AND/OR "--skip-broken" flags
sudo dnf --disablerepo='*' --enablerepo=epel upgrade
sudo dnf --disablerepo='*' --enablerepo=rhel-8-baseos-rhui-rpms upgrade --nobest
sudo dnf --disablerepo='*' --enablerepo=rhel-8-appstream-rhui-rpms upgrade
# Update a single package from the rhel-8-baseos-rhui-rpms repository
sudo dnf --disablerepo='*' --enablerepo=rhel-8-baseos-rhui-rpms upgrade curl
# If packages in one repo have dependencies in another repo, like "NetworkManager-cloud-setup" in the "rhel-8-appstream-rhui-rpms"
#   repository requires a matching version of "NetworkManager" from the "rhel-8-baseos-rhui-rpms" repository, you may have to
#   enable multiple repos to install updates. Example:
sudo dnf --disablerepo='*' --enablerepo=rhel-8-baseos-rhui-rpms --enablerepo=rhel-8-appstream-rhui-rpms --enablerepo=epel upgrade
```

Download an rpm package
```bash
# Download container-selinux to the /tmp directory
dnf download --destdir /tmp/ container-selinux
```

## Yum / RPM Package Repositories Troubleshooting
Not every YUM/RPM repository allows directory content listing via web browser, especially ones that might be backed by S3 buckets. This requires knowledge and configuration of specific paths in yum `.repo` files.

YUM repositories typically contain these metadata files:
| File | Contents |
|-     |-         |
| repomd.xml       | Index containing the location, checksums, and timestamp of the other XML metadata files listed below |
| repomd.xml.asc   | Generated only if the repository creator has signed the repomd.xml file using GPG, as shown in the above example. yum will download and verify this signature if the user has the pygpgme package installed |
| primary.xml.gz   | Detailed information about each package in the repository. Contains name, version, license, dependency information, timestamps, size, and more |
| filelists.xml.gz | Information about every file and directory in each package in the repository |
| other.xml.gz     | Changelog entries found in the RPM SPEC file for each package in the repository |

> In debugging, found [CI Job](https://drone-publish.rancher.io/rancher/rke2-packaging/716/3/4) that shows `TARGET_S3_PATH=rke2/stable/1.22/centos/8/x86_64`

Because viewing `repomd.xml` in a web browser typically requires downloading then viewing [Example](https://rpm.rancher.io/rke2/stable/common/centos/8/noarch/repodata/repomd.xml), we can use `curl` to list the file contents and perform other discover. Look for any files in the root directory or for a `repodata` folder in one of the relevant child directories. Example: https://rpm.rancher.io/rke2/stable/common/centos/8/noarch/repodata/
```bash
curl -Ls https://rpm.rancher.io/public.key
# https://docs.rke2.io/install/methods/#enterprise-linux-8 lists paths 'https://rpm.rancher.io/rke2/latest/1.18/centos/8/x86_64' 
# and 'https://rpm.rancher.io/rke2/latest/common/centos/8/noarch' . Let's try a subdir of the latter
curl -Ls https://rpm.rancher.io/rke2/stable/common/centos/8/noarch/repodata/repomd.xml
## From above xml attribute "location" we see relevant files:
#https://rpm.rancher.io/rke2/stable/common/centos/8/noarch/repodata/cb82efbd93107c2768554d8293e02d077ada7cf60dbd8a8d3a5d96c17e7c8f33-filelists.xml.gz
#https://rpm.rancher.io/rke2/stable/common/centos/8/noarch/repodata/f189544161972196b332e6378bfef7571f6a27e66b55f6d27db85765b6da2801-primary.xml.gz
#https://rpm.rancher.io/rke2/stable/common/centos/8/noarch/repodata/e588a49a35676af8180a5eb751f97810cac648346c26ebeaf0f42ecf00bfb43e-primary.sqlite.bz2
#https://rpm.rancher.io/rke2/stable/common/centos/8/noarch/repodata/c7f525fc648786c25190122199f1e0e2e4a83a7a9b1c0ec6678cec06381ddbaa-other.sqlite.bz2
#https://rpm.rancher.io/rke2/stable/common/centos/8/noarch/repodata/a4783bef8f4c1421fbdaac8a6d3440dea352aba547db2e57965ad5452058971c-other.xml.gz
#https://rpm.rancher.io/rke2/stable/common/centos/8/noarch/repodata/526ae366b3f249eac0c145b4a8c0f86a4baaa41451b39e907c40259ddf6f8f69-filelists.sqlite.bz2
```

## Alpine
```shell
# Run apk update first then install a package
apk update
apk add --repositories /tmp/nohttp --no-cache curl # Use a custom repositories file and no local cache
apk add --no-cache aws-cli
```

## Systemd / System V
Systemd is the newer replacement for System V starting in RHEL 7+. Service cheatsheet:

| Sysvinit Command  | Systemd Command   | Notes |
| ----------------- | ----------------- | ----- |
| `service foobar start`   | `systemctl start foobar`   | Start a service (not reboot persistent) |
| `service foobar stop`    | `systemctl stop foobar`    | Stop a service (not reboot persistent) |
| `service foobar restart` | `systemctl restart foobar` | Stop and then start a service |
| `service foobar reload`  | `systemctl reload foobar`  | Reload config file without interrupting pending operations |
| `service foobar condrestart` | `systemctl condrestart foobar` | Restarts if the service is already running |
| `service foobar status` | `systemctl status foobar`  | Tells whether a service is currently running |
| `ls /etc/rc.d/init.d/`  | `systemctl` **OR** `systemctl list-unit-files --type=service` **OR** `ls /lib/systemd/system/*.service /etc/systemd/system/*.service` | Used to list the services that can be started or stopped. Used to list all the services and other units |
| `chkconfig foobar on`   | `systemctl enable foobar`  | Turn the service on, for start at next boot, or other trigger |
| `chkconfig foobar off`  | `systemctl disable foobar` | Turn the service off for the next reboot, or any other trigger |
| `chkconfig foobar` | `systemctl is-enabled foobar` | Check whether a service is configured to start or not in the current environment |
| `chkconfig --list` | `systemctl list-unit-files --type=service` **OR** `ls /etc/systemd/system/*.wants/` | Print a table of services that lists which runlevels each is configured on or off |
| `chkconfig foobar --list` | `ls /etc/systemd/system/*.wants/foobar.service` | List what levels this service is configured on or off |
| `chkconfig foobar --add`  | `systemctl daemon-reload` | Used when you create a new service file or modify any configuration |

## POSIX compliant scripts
Busybox uses ash, not bash forcing POSIX compliant syntax like:

### Shell Parameter Expansion
```shell
var1="this is the real value"
a="var1"
## Bash would support the parameter expansion below
#echo "${!a}" # outputs 'this is the real value'
## POSIX 'eval' command does the same thing
eval y='$'$a
echo $y # outputs 'this is the real value'
```

### Check for a variable
```shell
if [ -z ${SOME_VAR+x} ]; then
  echo "SOME_VAR is NOT set"
else
  echo "SOME_VAR SET to ${SOME_VAR}"
fi
```

### For loops
```shell
## With a known list
for component in "a" "b" "c" "d"
do
  echo "component is: ${component}"
done

# With a range
for var in `seq 1 5`
do
  echo $var
done
```

## Growing Linux Drive
```bash
# Get the partition to grow
sudo lsblk
sudo lsblk --json
# Given Partition 2, grow it
sudo growpart /dev/nvme0n1 2 # --dry-run
# Assuming we are growing the root mounted Filesystem, get the Filesystem type
df -hT /
# Assuming the Filesystem type is xfs, grow the root mount
sudo xfs_growfs -d /
# Via Salt
#sudo /local/bin/salt-ssh -i -v --roster-file=/local/salt/roster "minion-name" -c /local/salt/ --ssh-option="StrictHostKeyChecking=no" cmd.run "lsblk --json"
#sudo /local/bin/salt-ssh -i -v --roster-file=/local/salt/roster "minion-name" -c /local/salt/ --ssh-option="StrictHostKeyChecking=no" cmd.run "lsblk --json"
#sudo /local/bin/salt-ssh -i -v --roster-file=/local/salt/roster "minion-name" -c /local/salt/ --ssh-option="StrictHostKeyChecking=no" cmd.run "lsblk --json"
#sudo /local/bin/salt-ssh -i -v --roster-file=/local/salt/roster "minion-name" -c /local/salt/ --ssh-option="StrictHostKeyChecking=no" cmd.run "growpart /dev/nvme0n1 2 --dry-run"
#sudo /local/bin/salt-ssh -i -v --roster-file=/local/salt/roster "minion-name" -c /local/salt/ --ssh-option="StrictHostKeyChecking=no" cmd.run "growpart /dev/nvme0n1 2 --dry-run"
#sudo /local/bin/salt-ssh -i -v --roster-file=/local/salt/roster "minion-name" -c /local/salt/ --ssh-option="StrictHostKeyChecking=no" cmd.run "growpart /dev/nvme0n1 2 --dry-run"
#sudo /local/bin/salt-ssh -i -v --roster-file=/local/salt/roster "minion-name" -c /local/salt/ --ssh-option="StrictHostKeyChecking=no" cmd.run "xfs_growfs -d /"
#sudo /local/bin/salt-ssh -i -v --roster-file=/local/salt/roster "minion-name" -c /local/salt/ --ssh-option="StrictHostKeyChecking=no" cmd.run "xfs_growfs -d /"
#sudo /local/bin/salt-ssh -i -v --roster-file=/local/salt/roster "minion-name" -c /local/salt/ --ssh-option="StrictHostKeyChecking=no" cmd.run "xfs_growfs -d /"
```

## Mounting a Disk
If you restore a Linux XFS EBS Volume and can't mount it to the EC2 instance it was created from, you will probably have duplicate UUIDs on the volumes an need to force the mount with override option:
```bash
mount -o nouuid /dev/nvme1n1p2 /mnt/restore/
```

## Monitoring Processes
Linux doesn't have a tool as good as Windows Process Monitor so we have to hack commands together to try and monitor processes and files touched with commands such as
- `lsof` : list open files
- `strace` : run a process and trace the system calls
- `fuser`
- `watch` (interactively runs a process until killed)
- `top`
- `ps`
- others

Here's some attempts to emulate a process monitor functionality:
```bash
# This doesn't show much of what the script is doing
watch -n 1 "fuser -v /home/ec2-user/foo.sh"
```

## Logs
```bash
# strace view only files
strace -e trace=open,openat,close,read,write,connect,accept df
# bash search for multiple patterns by using extended regex
cat somefile | grep -E 'foo|bar'  # Can probably remove cat and just "grep -E 'foo|bar' somefile"
sudo last # Last user logins, checks /var/log/wtmp
sudo lastlog -t 2 # Logins in last 2 days, checks /var/log/lastlog
```

# Vi
```bash
vim -b somefile # Open in binary mode, so it loads full file in RAM
setlocal undolevels=-1 # Turn off undo for local session
gg  # Go to first line in file
G   # Go to end of file
dgg # Delete all lines above current
dG  # Delete all lines below current
# Filtering lines in /var/log/messages
:g/^.*audispd.*type=\(CRED\|CRYPTO\|USER_\(AUTH\|LOGIN\|START\)\).*/d
:g/^.*exe="\/usr\/sbin\/crond".*/d
:g/^.*systemd: \(Created\|Started\|Removed\).*root\..*/d
```

# Linting via shellcheck
```bash
sudo yum -y install epel-release
sudo yum install ShellCheck
find . -name "*.sh" -exec sh -c 'shellcheck "$1"' _ {} \;
```

# Linux Kernel Tweaks
TODO: Need to investigate what kernel settings may be needed. Specifically for databases Transparent Huge Page and Redis and how to pass through those values to K8S pods. See Kubernetes [sysctl documentation](https://kubernetes.io/docs/tasks/administer-cluster/sysctl-cluster/) and [Rancher Ghist](https://gist.github.com/brooksphilip/c9ed00c8db921b5e0a2a1c8c8903dfdb):

```bash
echo " updating kernel settings"
cat << EOF >> /etc/sysctl.conf
# SWAP settings
vm.swappiness=0
vm.panic_on_oom=0
vm.overcommit_memory=1
kernel.panic=10
kernel.panic_on_oops=1
vm.max_map_count = 262144

# Have a larger connection range available
net.ipv4.ip_local_port_range=1024 65000

# Increase max connection
net.core.somaxconn=10000

# Reuse closed sockets faster
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_fin_timeout=15

# The maximum number of "backlogged sockets".  Default is 128.
net.core.somaxconn=4096
net.core.netdev_max_backlog=4096

# 16MB per socket - which sounds like a lot,
# but will virtually never consume that much.
net.core.rmem_max=16777216
net.core.wmem_max=16777216

# Various network tunables
net.ipv4.tcp_max_syn_backlog=20480
net.ipv4.tcp_max_tw_buckets=400000
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_syn_retries=2
net.ipv4.tcp_synack_retries=2
net.ipv4.tcp_wmem=4096 65536 16777216

# ARP cache settings for a highly loaded docker swarm
net.ipv4.neigh.default.gc_thresh1=8096
net.ipv4.neigh.default.gc_thresh2=12288
net.ipv4.neigh.default.gc_thresh3=16384

# ip_forward and tcp keepalive for iptables
net.ipv4.tcp_keepalive_time=600
net.ipv4.ip_forward=1

# monitor file system events
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
EOF
sysctl -p > /dev/null 2>&1
```
