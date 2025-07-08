## Node Cheatsheet
```bash
npm install -g typescript # Install globally
npm install -g sharp --platform=linux --arch=x64
# Suppress deprecated warnings (warn level), levels include:
#  silent, error, warn, http, info (default)
npm install typescript --loglevel=error
# Install from a Git repo
npm install github:user/repo
# Install from file path
npm install ./local-folder
# Uninstall/update
npm uninstall
npm update
# Remove dependencies, clean cache, prune unused
rm -rf node_modules
npm cache clean --force
npm prune
# Audit and Fix Vulnerabilities
npm audit
npm audit fix
npm audit fix --force    # May apply breaking changes
```

## Common VARS

| Variable                   | Description                                                                     |
| -------------------------- | ------------------------------------------------------------------------------- |
| `NODE_ENV`                 | Controls the environment mode (`development`, `production`, etc.).              |
| `NODE_OPTIONS`             | Pass default command-line flags to Node.js (e.g., `--max-old-space-size=4096`). |
| `NODE_PATH`                | Add custom paths for module resolution.                                         |
| `NODE_DISABLE_COLORS`      | Disable colored output (set to `1`).                                            |
| `NODE_NO_WARNINGS`         | Suppress all Node.js process warnings (set to `1`).                             |
| `NODE_REPL_HISTORY`        | Path to REPL history file.                                                      |
| `NODE_EXTRA_CA_CERTS`      | Path to a file containing one or more trusted CA certificates.                  |
| `NODE_PENDING_DEPRECATION` | Emits pending deprecations (set to `1` to enable).                              |
| `NO_UPDATE_NOTIFIER` (npm) | Suppress NPM's update notifier.                                                 |

### Debugging and Dev
| Variable         | Use Case                                                         |
| ---------------- | ---------------------------------------------------------------- |
| `DEBUG=*`        | Enables debugging output for modules using the `debug` module.   |
| `INSPECTOR_PORT` | Sets the default port for the inspector (e.g., Chrome DevTools). |
| `PORT`           | Common convention for web servers to read port from env.         |
| `HOST`           | Often used alongside `PORT` in server configuration.             |

### `.env` File Example
```bash
NODE_ENV=development
PORT=3000
API_KEY=abc123
```
