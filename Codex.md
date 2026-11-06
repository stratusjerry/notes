Codex Setup
===

## Windows

Don't use current Codex vscode extension due to issues. If extension eventually gets fixed, wsl passthrough can be used via setting
```json
{
    "chatgpt.runCodexInWindowsSubsystemForLinux": true
}
```

### Windows using WSL
```powershell
# Launch Ubuntu VM
wsl -d Ubuntu-26.04 # May prompt for a default Unix user account
```

```bash
sudo apt update && sudo apt upgrade -y
curl -fsSL https://chatgpt.com/codex/install.sh | sh  # This is ugly but sandboxing npm can be a pain
source ~/.bashrc
codex
```

## Codex on Bedrock

Configure Codex model provider `~/.codex/config.toml`
```toml
model = "openai.gpt-5.6-luna"
#model = "openai.gpt-6-astra"
model_provider = "amazon-bedrock"

[model_providers.amazon-bedrock.aws]
region = "us-east-1"
wire_api = "responses"
```

Per [Anthropic Documentation](https://docs.anthropic.com/en/docs/claude-code/amazon-bedrock) if using Bedrock API keys, only environmental variable should be needed

```bash
# Set our region and settings (this may be easier done in a config file ~/.codex/.env )
export AWS_REGION=us-east-1
export AWS_BEARER_TOKEN_BEDROCK=YOUR_BEDROCK_API_KEY

```

