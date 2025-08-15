Claude Code Setup
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

## Claude Code Commands
```bash
/agents   # Creates and manage agents
/history  # Shows your recent prompts and responses in Claude Code.
/logout   # 
/clear    # Clears the current conversation context.
/cost     # See current session usage
/status   # See running config (Env Vars, inherited settings, etc)
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
