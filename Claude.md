Claude Setup
===

## On Windows using WSL
```powershell
# Launch Ubuntu VM
wsl -d Ubuntu-24.04 # May prompt for a default Unix user account
```

```bash
sudo apt update && sudo apt upgrade -y
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
# Install Node.js
nvm install --lts
nvm use --lts
nvm alias default node
npm install -g @anthropic-ai/claude-code
# cd to your git repo dir (default /mnt/c/Users/jerry/)
# IF not the first time running, just run 'claude' otherwise run:
claude login # TODO API key alternative?
# From Claude prompt
/init

```

## On Mac
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
# In your Git repo, target newest LTS version
echo "22.17.0" > .nvmrc
nvm install
nvm use
# Install Claude Code locally
npm install @anthropic-ai/claude-code
# Run with npx
npx claude-code
```
