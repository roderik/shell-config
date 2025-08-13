# Shell Config

Modern tri-shell configuration with Fish, Zsh, and Bash support, featuring powerful CLI tools and professional development environment.

## Features

### 🐚 Triple Shell Support

- **Fish Shell**: Interactive shell with autosuggestions and intelligent tab completion
- **Zsh Shell**: Enhanced with plugins for syntax highlighting and autosuggestions
- **Bash Shell**: Modern Bash with comprehensive modular configuration
- **Unified Experience**: Consistent aliases, functions, and tools across all shells

### ⭐ Starship Prompt

- **Context-Aware**: Shows git status, package versions, execution time
- **Fast Performance**: Minimal latency with asynchronous rendering
- **Beautiful Theme**: Pre-configured Catppuccin Macchiato theme
- **Cross-Shell**: Works seamlessly with Fish, Bash, and Zsh

### 📝 Neovim with LazyVim

- **Modern IDE Features**: LSP, treesitter, and telescope integration
- **LazyVim Config**: Pre-configured with sensible defaults
- **Catppuccin Theme**: Beautiful macchiato color scheme
- **Plugin Management**: Lazy loading for fast startup
- **Relative Numbers Disabled**: Clean line number display

### 🛠️ Modern CLI Tools

| Tool           | Description                                  | Replaces  |
| -------------- | -------------------------------------------- | --------- |
| **neovim**     | Modern Vim with LazyVim configuration        | `vim`     |
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
| **vibetunnel** | VibeTunnel CLI (vt command)                  | -         |
| **1password**  | 1Password CLI integration                    | -         |

### 🎯 Developer Experience

- **Modular Configuration**: Clean `conf.d/` structure for all shells
- **Smart Aliases**: Consistent shortcuts across all shells
- **Git Integration**: Comprehensive git shortcuts and functions
- **Claude Function**: Smart Claude Code wrapper with auto-detection
- **Docker Functions**: Helpful Docker management utilities
- **Environment Variables**: Optimized for Node.js and AI development

## Quick Install

### Basic One-liner

```bash
# Install complete tri-shell configuration
curl -sL https://raw.githubusercontent.com/roderik/shell-config/main/install.sh | bash
```

### Clone and Install

```bash
git clone https://github.com/roderik/shell-config.git
cd shell-config
./install.sh
```

### Installation Options

```bash
./install.sh --help       # Show help
./install.sh --dry-run    # Preview changes without installing
./install.sh --force      # Overwrite existing configurations
```

## Installation Process

The setup script performs the following steps:

1. **Installs Homebrew** (if not present) - macOS package manager
2. **Installs all three shells** - Fish, Zsh, and Bash with enhancements
3. **Installs shell plugins** - Syntax highlighting, autosuggestions, completions
4. **Installs modern development tools** via Homebrew
5. **Configures Fish** with modular `conf.d/` structure
6. **Configures Zsh** with comprehensive modular configuration
7. **Configures Bash** with modern features and modular setup
8. **Configures Neovim** with LazyVim and Catppuccin theme
9. **Configures Starship** prompt for all three shells
10. **Installs Bun** JavaScript runtime and toolkit

## Configuration Structure

### Modular Organization

Each shell uses a modular `conf.d/` structure with numbered files for predictable loading order:

```
config/
├── bash/
│   ├── .bashrc                       # Main Bash configuration
│   ├── .bash_profile                 # Bash profile
│   └── conf.d/
│       ├── 00-environment.bash       # Environment variables
│       ├── 00-homebrew.bash          # Homebrew setup
│       ├── 02-paths.bash             # PATH configuration
│       ├── 10-aliases.bash           # Command aliases
│       ├── 10-node.bash              # Node.js (fnm) setup
│       ├── 11-1password.bash         # 1Password CLI
│       ├── 20-functions.bash         # Utility functions
│       ├── 20-fzf.bash               # FZF configuration
│       ├── 30-abbreviations.bash     # Git shortcuts
│       ├── 30-git-functions.bash    # Git utilities
│       ├── 31-docker-functions.bash # Docker utilities
│       ├── 32-claude-function.bash  # Claude wrapper
│       ├── 40-completions.bash      # Shell completions
│       ├── 60-modern-tools.bash     # Modern CLI tools
│       └── 70-prompt.bash           # Starship prompt
├── zsh/
│   ├── .zshrc                       # Main Zsh configuration
│   └── conf.d/
│       ├── 00-environment.zsh       # Environment setup
│       ├── 00-homebrew.zsh          # Homebrew configuration
│       ├── 02-paths.zsh             # PATH setup
│       ├── 10-node.zsh              # Node.js management
│       ├── 11-1password.zsh         # 1Password CLI
│       ├── 20-functions.zsh         # Utility functions
│       ├── 20-fzf.zsh               # FZF integration
│       ├── 30-aliases.zsh           # Command aliases
│       ├── 30-abbreviations.zsh     # Git shortcuts
│       ├── 30-git-functions.zsh    # Git utilities
│       ├── 31-docker-functions.zsh # Docker helpers
│       ├── 32-claude-function.zsh  # Claude wrapper
│       ├── 40-completions.zsh      # Completions
│       ├── 60-modern-tools.zsh     # Tool integrations
│       └── 70-prompt.zsh           # Starship setup
├── fish/
│   ├── config.fish                  # Main Fish configuration
│   └── conf.d/
│       ├── 00-environment.fish      # Environment variables
│       ├── 10-starship.fish         # Starship prompt
│       ├── 20-functions.fish        # Utility functions
│       ├── 30-abbreviations.fish    # Git abbreviations
│       ├── 30-git-functions.fish   # Git utilities
│       ├── 31-docker-functions.fish # Docker helpers
│       └── 32-claude-function.fish # Claude wrapper
└── starship/
    └── starship.toml                # Starship configuration
```

### Configuration Locations

After installation, configurations are placed at:

- **Fish**: `~/.config/fish/` (config.fish and conf.d/)
- **Zsh**: `~/.zshrc` and `~/.config/zsh/conf.d/`
- **Bash**: `~/.bashrc`, `~/.bash_profile`, and `~/.config/bash/conf.d/`
- **Neovim**: `~/.config/nvim/` (LazyVim configuration)
- **Starship**: `~/.config/starship.toml`

## What Gets Configured

### Environment Variables

```bash
NODE_NO_WARNINGS=1                    # Suppresses Node.js warnings
FORCE_AUTO_BACKGROUND_TASKS=1         # Claude Code automatic background tasks
ENABLE_BACKGROUND_TASKS=1             # Claude Code background task execution
EDITOR=nvim                           # Default editor
VISUAL=nvim                           # Visual editor
```

### Enhanced Aliases (All Shells)

#### File Operations

- `ls` → `eza -lh --group-directories-first`
- `l` → `eza --git-ignore --group-directories-first`
- `ll` → `eza --all --header --long --group-directories-first`
- `llm` → `eza --all --header --long --sort=modified --group-directories-first`
- `la` → `eza -lbhHigUmuSa`
- `lt` → `eza --tree`
- `cat` → `bat`
- `vim` → `nvim`

#### Git Shortcuts (60+ aliases)

- `g` → `git`
- `ga` → `git add`
- `gaa` → `git add --all`
- `gc` → `git commit --verbose`
- `gcm` → `git commit --message`
- `gco` → `git checkout`
- `gp` → `git push`
- `gl` → `git pull`
- `gs` → `git status`
- And many more...

#### Tool Shortcuts

- `lzg` → `lazygit`
- `lzd` → `lazydocker`
- `ff` → `fzf --preview 'bat --color=always {}'`
- `cdi` → `zi` (zoxide interactive)
- `claude` → Smart wrapper with auto-detection

#### Docker Shortcuts

- `d` → `docker`
- `dc` → `docker compose`
- `dps` → `docker ps`
- `dpsa` → `docker ps -a`

### Special Functions

#### Claude Function

Smart wrapper that auto-detects project settings:

```bash
# Automatically uses .claude/AUTO_PLAN_MODE.txt if present
# Falls back to vt (VibeTunnel) if available
claude [args]
```

#### Git Functions

- `gclone` - Clone and cd into repository
- `gprune` - Clean up merged branches
- `greset` - Reset to origin/main
- `gundo` - Undo last commit

#### Docker Functions

- `dexec` - Execute command in container
- `dlogs` - View container logs
- `dstop` - Stop all containers
- `dclean` - Clean unused resources

### Modern Tool Integrations

- **direnv**: Automatic per-project environment variables
- **zoxide**: Smart directory jumping with `z` command
- **atuin**: Enhanced shell history with search and sync
- **fzf**: Fuzzy finder integration with preview
- **fnm**: Fast Node.js version management

## Post-Installation

### Choose Your Shell

After installation, all three shells are ready to use:

#### Fish Shell

```bash
# Start a Fish session
fish

# Make Fish your default shell (optional)
chsh -s /opt/homebrew/bin/fish  # Apple Silicon
chsh -s /usr/local/bin/fish      # Intel Mac
```

#### Zsh

```bash
# Start a Zsh session
zsh

# Make Zsh your default shell (optional)
chsh -s /opt/homebrew/bin/zsh   # Apple Silicon
chsh -s /usr/local/bin/zsh       # Intel Mac
```

#### Bash

```bash
# Start a Bash session
bash

# Make Bash your default shell (optional)
chsh -s /bin/bash
```

### First Launch

1. **Neovim**: First launch will install all LazyVim plugins automatically
2. **Atuin**: Run `atuin register` to enable history sync (optional)
3. **Direnv**: Create `.envrc` files in projects for automatic environment setup

## Customization

### Adding Personal Configuration

Each shell supports local overrides:

```bash
# Fish
echo "alias myalias='mycommand'" >> ~/.config/fish/conf.d/99-local.fish

# Zsh
echo "alias myalias='mycommand'" >> ~/.config/zsh/conf.d/99-local.zsh

# Bash
echo "alias myalias='mycommand'" >> ~/.config/bash/conf.d/99-local.bash
```

### Modifying Starship Prompt

Edit the Starship configuration:

```bash
nvim ~/.config/starship.toml
```

### Updating Tools

Update all installed tools:

```bash
brew update && brew upgrade
```

## Troubleshooting

### Shell not found after installation

Ensure Homebrew's bin directory is in your PATH:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

### Permission issues

If you get permission errors when changing your shell:

```bash
# Add shell to allowed shells manually
sudo sh -c "echo $(which fish) >> /etc/shells"
sudo sh -c "echo $(which zsh) >> /etc/shells"
```

### Tools not working

Reload your shell configuration:

```bash
# Fish
source ~/.config/fish/config.fish

# Zsh
source ~/.zshrc

# Bash
source ~/.bashrc
```

## Uninstalling

To uninstall, use the provided uninstall script:

```bash
./uninstall.sh
```

Or manually remove configurations:

```bash
# Change back to default shell
chsh -s /bin/bash

# Remove configurations
rm -rf ~/.config/fish
rm -rf ~/.config/zsh
rm -rf ~/.config/bash
rm -f ~/.zshrc
rm -f ~/.bashrc
rm -f ~/.bash_profile
rm -rf ~/.config/nvim
rm -f ~/.config/starship.toml

# Uninstall tools (optional)
brew uninstall fish zsh starship bat eza ripgrep fd fzf
```

## Requirements

- **macOS** (Intel or Apple Silicon)
- **Internet connection** for downloading tools
- **Admin privileges** for changing shell (optional)

## Contributing

Found an issue or have a suggestion? Please open an issue or submit a PR on the [GitHub repository](https://github.com/roderik/shell-config).

## License

MIT - See [LICENSE](LICENSE) file for details

## Support

- Issues: [GitHub Issues](https://github.com/roderik/shell-config/issues)
- Discussions: [GitHub Discussions](https://github.com/roderik/shell-config/discussions)
