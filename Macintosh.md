Macintosh Notes
===

## Environment Setup
```bash
# Read current settings like Mouse Scroll Direction
defaults read NSGlobalDomain com.apple.swipescrolldirection
# Set Mouse scroll to natural (my preferred), and other settings
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
defaults write NSGlobalDomain com.apple.mouse.scaling -float 3
defaults write NSGlobalDomain com.apple.scrollwheel.scaling -float 1.7

```

### Developer Setup
```bash
# Setup git, python, pip3
xcode-select --install # Click through the prompt
# turn on vim syntax highlighting 
echo "syntax on" > ~/.vimrc
echo "alias ll='ls -lasth --color'" >> ~/.zshrc
```

### SSH Setup
To setup SSH, like to use vscode-ssh from another box:
1. Go to Apple menu → System Settings (or System Preferences in older macOS versions) → `General` → `Sharing`
1. Click `Remote Login` and select specific users/group
1. Configure to only allow key based access
   1. echo "your_public_key_content" >> ~/.ssh/authorized_keys
   1. Restrict SSH
      ```bash
      # Note Mac sed version has extra arg parameter ''; KbdInteractiveAuthentication is modern value for deprecated ChallengeResponseAuthentication
      #  May need to manually add these values if not found
      sudo sed -i '' 's/^.*KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/' /etc/ssh/sshd_config
      sudo sed -i '' 's/^.*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
      sudo sed -i '' 's/^.*UsePAM.*/UsePAM no/' /etc/ssh/sshd_config
      # SSH Config Debugging
      #   Check available config
      man sshd_config
      #   Test SSH config is valid, this only checks syntax NOT if config is valid
      sudo sshd -t -f /etc/ssh/sshd_config
      # Restart SSH service
      sudo launchctl unload /System/Library/LaunchDaemons/ssh.plist
      sudo launchctl load /System/Library/LaunchDaemons/ssh.plist
      ```

## Time Machine setup
1. Setup an external Hard Drive as a Time Machine backup location, named `TimeMachine`, and format as `APFS`
1. Enable File Sharing
   1. Go to System Settings (or System Preferences in older macOS versions) > `General` > `Sharing`.
   1. Enable `File Sharing`
      1. Also, Select `i`, then `Options` and make sure "Share files and folders using SMB" is enabled
1. Add the Drive as a shared folder. Under `File Sharing` -> `i` -> `Shared Folder`, click `+` and select `/Volumes/TimeMachine`. TODO: may need to validate user r+w is correct
1. Add the new Share as a Time Machine Destination. Under `File Sharing` -> `i` -> `Shared Folder`, select the `TimeMachine` folder (setup in the previous step); right click and select `Advanced Options...`; Check `Share as a Time Machine backup destination`; Click `OK`; Click `Done`
1. Create a user account per Mac computer using the backup. `1:1` helps us enforce quotas per user/folder. Naming convention `mac1`, `mac2`, etc
   1. Go to System Settings (or System Preferences in older macOS versions) > `Users & Groups`
   1. Select `Add User...`; New User: `Sharing Only`, Full Name: `mac1 backup`, Password: `lol`, Verify: `lol`
1. Setup Time Machine on each Mac, be sure to exclude directories like
   ```bash
   sudo tmutil addexclusion "~/Library/Containers/com.docker.docker/"
   sudo tmutil addexclusion "~/Library/Containers/com.utmapp.UTM/Data/"
   sudo tmutil addexclusion "~/.android/"
   # Verify commands above worked
   defaults read /Library/Preferences/com.apple.TimeMachine SkipPaths
   ```
1. TODO add file size restrictions on per mac created timemachine `.sparsebundle` file
1. TODO document deleting exclude directories from previous backups
   1. `System Settings` -> `Privacy & Security` -> `Full Disk Access` -> Select `Terminal`
      ```bash
      tmutil listbackups
      ```

## Fix Mac File Open Dialogs not showing Hidden Folders
Temporary Fix to show hidden files in File picker window  (Vscode .git folder, Time Machine Exclusions Picker, etc) 
is to use key combo `Command` + `Shift` + `.`. TODO: Research if this can be change via `defaults`

## TODO
- Fix Finder default view settings (`defaults`)
- Research changing keyboard shortcuts to Windows Style
  - `Ctrl` commands like Copy `Ctrl` + `c`; Paste`Ctrl` + `v`; Save `Ctrl` + `v`
    - Begin/End of word "tab" navigation like `Ctrl` + `←` and `Ctrl` + `→`
      - Group selection like `Shift` + `Ctrl` + `←` and `Shift` + `Ctrl` + `→`
    - Verify commands work across application like Main Mac, Finder, Vscode, Terminal, Notes, etc
  - `Home` and `End` keys
  - Mouse wheel Click and drag isn't scrolling in a page (Chrome, Vscode)
  - Change `Alt` + `Tab` from App only to Windows in an App?
