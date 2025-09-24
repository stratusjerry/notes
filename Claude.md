Claude Code Setup
===

## Windows

### Windows Binary (Beta)
Taken from https://claude.ai/install.ps1

```powershell
$GCS_BUCKET = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"
$DOWNLOAD_DIR = "${env:USERPROFILE}\.claude\downloads"
$platform = "win32-x64"
# stable, latest, or specific version
$version = "stable"
$ProgressPreference = 'SilentlyContinue'
$apiVer = (Invoke-WebRequest "${GCS_BUCKET}/${version}").Content  # 1.0.123
$manifest = "${GCS_BUCKET}/${apiVer}/manifest.json"
mkdir ${DOWNLOAD_DIR}
Invoke-WebRequest "${manifest}" -OutFile "${DOWNLOAD_DIR}\manifest.json"
$binaryPath = "${DOWNLOAD_DIR}\claude-${version}-${platform}.exe"
Invoke-WebRequest "${GCS_BUCKET}/${apiVer}/${platform}/claude.exe" -OutFile "${binaryPath}"
# Checksum here
$binHash = (Get-FileHash "${binaryPath}" -Algorithm SHA256).Hash
$jsonContent = Get-Content -Path "${DOWNLOAD_DIR}\manifest.json" -Raw | ConvertFrom-Json
$nestedValue = ($jsonContent.platforms.${platform}.checksum).ToUpper()
Write-Host "BinHash: ${binHash}"
Write-Host "Manifest Hash: ${nestedValue}"
& $binaryPath install
```

### Windows using NPM

```powershell
cd "C:\Git\local\subdir"
# Install nvm using chocolatey, abandoned attempt to install nvm locally (variable error finding settings.txt)
choco install -y nvm
#$ProgressPreference = 'SilentlyContinue'
#Invoke-WebRequest 'https://github.com/coreybutler/nvm-windows/releases/download/1.2.2/nvm-noinstall.zip' -OutFile .\nvm-noinstall.zip
#Expand-Archive .\nvm-noinstall.zip .\
# Set NVM Variable (may also be able to be set by helper script)
#$env:NVM_HOME = $PWD.Path
#.\nvm.exe install --lts
# Use chocolatey installed nvm (may need to open new terminal to get PATH vars)
nvm install --lts
nvm use lts
npm install @anthropic-ai/claude-code
.\node_modules\.bin\claude
```

### Windows using WSL
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

## Claude Code Commands
```bash
/agents   # Creates and manage agents
/history  # Shows your recent prompts and responses in Claude Code.
/logout   # 
/clear    # Clears the current conversation context.
/cost     # See current session usage
/status   # See running config (Env Vars, inherited settings, etc)
```

### Claude Code Flags
```bash
# Restore Realtime token usage by running in verbose mode
claude --verbose
#YOLO mode, should only be run from a Container, VM, or other sandbox
export IS_SANDBOX=1 && claude --dangerously-skip-permissions
```

## Claude Code on Bedrock
Per [Anthropic Documentation](https://docs.anthropic.com/en/docs/claude-code/amazon-bedrock) if using Bedrock API keys, only environmental variable should be needed

```bash
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_BEARER_TOKEN_BEDROCK=your-bedrock-api-key
# Set our region and settings (this may be easier done in a config file)
export AWS_REGION=us-east-1
export ANTHROPIC_MODEL='us.anthropic.claude-opus-4-1-20250805-v1:0'
export ANTHROPIC_SMALL_FAST_MODEL='us.anthropic.claude-3-5-haiku-20241022-v1:0'
#export ANTHROPIC_MODEL='us.anthropic.claude-opus-4-20250514-v1:0'
#export ANTHROPIC_MODEL='us.anthropic.claude-sonnet-4-20250514-v1:0'
# Recommended starting point for Claude 4 models on Bedrock
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=4096
export MAX_THINKING_TOKENS=1024
# Optionally clear env vars like:
#unset CLAUDE_CODE_USE_BEDROCK
```

Use `~/.claude/settings.json` for persistent values:
```json
{
    "env": {
        "CLAUDE_CODE_USE_BEDROCK": "1",
        "AWS_REGION": "us-east-1",
        "ANTHROPIC_SMALL_FAST_MODEL": "us.anthropic.claude-3-5-haiku-20241022-v1:0"
    }
}
```
