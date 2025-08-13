# Shell Config

Modern shell setup with Fish, powerful CLI tools, and professional development environment configurations.

## Features

### 🐚 Fish Shell Environment

- **User-Friendly Shell**: Interactive shell with autosuggestions and intelligent tab completion
- **Web-Based Configuration**: Built-in `fish_config` for easy customization
- **Smart History**: Searchable command history with arrow key navigation
- **Abbreviations**: Git shortcuts that expand on space for faster workflow

### ⭐ Starship Prompt

- **Context-Aware**: Shows git status, package versions, execution time
- **Fast Performance**: Minimal latency with asynchronous rendering
- **Beautiful Theme**: Pre-configured Catppuccin Macchiato theme
- **Cross-Shell**: Works with Fish, Bash, and Zsh

### 🛠️ Modern CLI Tools

| Tool           | Description                                  | Replaces  |
| -------------- | -------------------------------------------- | --------- |
| **bat**        | Syntax highlighting and Git integration      | `cat`     |
| **eza**        | Modern listing with icons and git status     | `ls`      |
| **ripgrep**    | Ultra-fast text search                       | `grep`    |
| **fd**         | User-friendly file finder                    | `find`    |
| **fzf**        | Fuzzy finder for files and history           | -         |
| **lazygit**    | Terminal UI for git commands                 | -         |
| **lazydocker** | Terminal UI for docker management            | -         |
| **fnm**        | Fast Node.js version manager                 | `nvm`     |
| **git-delta**  | Beautiful git diffs with syntax highlighting | -         |
| **hexyl**      | Hex viewer with colored output               | `hexdump` |
| **procs**      | Modern process viewer                        | `ps`      |
| **broot**      | Interactive tree view with search            | `tree`    |
| **zoxide**     | Smarter directory navigation                 | `cd`      |
| **atuin**      | Better shell history with sync               | -         |
| **direnv**     | Per-project environment variables            | -         |

### 🎯 Developer Experience

- **Smart Aliases**: Pre-configured shortcuts for common tasks
- **Git Abbreviations**: Expand on space for faster git workflow
- **Environment Variables**: Optimized for Node.js and AI assistant development
- **Idempotent Setup**: Run multiple times to update configuration

## Quick Install

### Basic One-liner

```bash
# Default installation
curl -sL https://raw.githubusercontent.com/roderik/wt/main/setup-fish.sh | bash
```

### Clone and Install

```bash
git clone https://github.com/roderik/wt.git
cd wt
./setup-fish.sh
```

## Installation Process

The setup script performs the following steps:

1. **Installs Homebrew** (if not present) - macOS package manager
2. **Installs Fish shell** and adds it to allowed shells
3. **Installs modern development tools** via Homebrew
4. **Configures Fish** with aliases, completions, and environment setup
5. **Configures Starship** with beautiful, informative prompt
6. **Installs wt** (git worktree manager) automatically

## Configuration Locations

Configurations are installed to:

- **Fish Shell**: `~/.config/fish/config.fish`
- **Starship Prompt**: `~/.config/starship.toml`
- **Fish Functions**: `~/.config/fish/functions/`

## What Gets Configured

### Environment Variables

```bash
NODE_NO_WARNINGS=1                    # Suppresses Node.js warnings
FORCE_AUTO_BACKGROUND_TASKS=1         # Claude Code automatic background tasks
ENABLE_BACKGROUND_TASKS=1             # Claude Code background task execution
EDITOR=nvim                           # Default editor
VISUAL=nvim                           # Visual editor
```

### Aliases

#### File Operations

- `ls` → `eza` (enhanced listing)
- `ll` → `eza -alh` (detailed listing)
- `la` → `eza -a` (all files)
- `cat` → `bat` (syntax highlighted viewing)

#### Git Shortcuts

- `g` → `git`
- `ga` → `git add`
- `gcm` → `git commit -m`
- `gp` → `git push`
- `gpu` → `git pull`
- `gst` → `git status`

#### Tool Shortcuts

- `lzg` → `lazygit`
- `lzd` → `lazydocker`
- `ff` → `fzf --preview 'bat --color=always {}'`
- `cd` → `zoxide` (smarter cd)
- `cdi` → `zoxide interactive`
- `claude` → `claude --skip-permissions`

### Git Abbreviations

Fish abbreviations that expand on space:

```fish
g     → git
ga    → git add
gaa   → git add --all
gb    → git branch
gco   → git checkout
gcm   → git commit -m
gd    → git diff
gp    → git push
gpu   → git pull
gst   → git status
```

And many more available abbreviations for common git operations.

## Post-Installation

After installation:

1. **Change your default shell** (optional):

   ```bash
   chsh -s $(which fish)
   ```

2. **Start a new Fish shell session**:

   ```bash
   fish
   ```

3. **Explore the features**:
   - Try typing a command and pressing Tab for completions
   - Use up/down arrows to search command history
   - Type `help` to open Fish documentation
   - Run `fish_config` to customize your setup

## Customization

### Modifying Configuration

Edit your Fish configuration:

```fish
nano ~/.config/fish/config.fish
```

Edit your Starship prompt:

```fish
nano ~/.config/starship.toml
```

### Adding Custom Functions

Create custom Fish functions:

```fish
# Create a new function
function myfunction
    echo "Hello from my function!"
end

# Save it permanently
funcsave myfunction
```

### Updating Tools

Update all installed tools:

```bash
brew update && brew upgrade
```

## Troubleshooting

### Fish not found after installation

Make sure Homebrew's bin directory is in your PATH:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

### Permission issues

If you get permission errors when changing your shell:

```bash
# Add Fish to allowed shells manually
sudo sh -c "echo $(which fish) >> /etc/shells"
```

### Tools not working

Ensure Fish is loading the configuration:

```fish
source ~/.config/fish/config.fish
```

## Project Structure

```
shell-config/
├── setup-fish.sh              # Main installation script
├── config/
│   ├── config.fish           # Fish shell configuration
│   └── starship.toml         # Starship prompt theme
├── functions/
│   └── wt.fish              # Git worktree manager function
└── README.md                # This file
```

## Uninstalling

To remove Fish shell and revert to your previous shell:

```bash
# Change back to bash or zsh
chsh -s /bin/bash  # or /bin/zsh

# Remove Fish configuration
rm -rf ~/.config/fish

# Uninstall Fish (optional)
brew uninstall fish

# Remove other tools (optional)
brew uninstall starship bat eza ripgrep fd fzf # etc...
```

## Requirements

- **macOS** (Intel or Apple Silicon)
- **Internet connection** for downloading tools
- **Admin privileges** for changing shell (optional)

## Contributing

Found an issue or have a suggestion? Please open an issue or submit a PR on the [GitHub repository](https://github.com/roderik/wt).

## License

MIT - See [LICENSE](LICENSE) file for details

## Support

- Issues: [GitHub Issues](https://github.com/roderik/wt/issues)
- Discussions: [GitHub Discussions](https://github.com/roderik/wt/discussions)
