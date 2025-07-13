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

## TODO
- Fix App Store Failure to login
- Fix Finder default view settings (`defaults`)
- Research changing keyboard shortcuts to `Ctrl` (especially copy/paste/save)
