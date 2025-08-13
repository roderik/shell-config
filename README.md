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

### 📝 Neovim with LazyVim

- **Modern IDE Features**: LSP, treesitter, and telescope integration
- **LazyVim Config**: Pre-configured with sensible defaults
- **Omarchy Customizations**: Enhanced with Basecamp's Omarchy theme and settings
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

### 🎯 Developer Experience

- **Smart Aliases**: Pre-configured shortcuts for common tasks
- **Git Abbreviations**: Expand on space for faster git workflow
- **Environment Variables**: Optimized for Node.js and AI assistant development
- **Idempotent Setup**: Run multiple times to update configuration

## Quick Install

### Basic One-liner

```bash
# Default installation
curl -sL https://raw.githubusercontent.com/roderik/shell-config/main/setup-fish.sh | bash
```

### Clone and Install

```bash
git clone https://github.com/roderik/shell-config.git
cd shell-config
./setup-fish.sh
```

## Installation Process

The setup script performs the following steps:

1. **Installs Homebrew** (if not present) - macOS package manager
2. **Installs both shells** - Latest Zsh and Fish from Homebrew
3. **Installs Zsh plugins** - Syntax highlighting, autosuggestions, completions
4. **Installs modern development tools** via Homebrew (including Neovim)
5. **Configures Fish** with aliases, completions, and environment setup
6. **Configures Zsh** with modular conf.d structure
7. **Configures Neovim** with LazyVim starter configuration
8. **Configures Starship** with beautiful, informative prompt for both shells

## Configuration Locations

Configurations are installed to:

- **Fish Shell**: `~/.config/fish/config.fish`
- **Fish Modules**: `~/.config/fish/conf.d/`
- **Zsh Shell**: `~/.zshrc`
- **Zsh Modules**: `~/.config/zsh/conf.d/`
- **Neovim**: `~/.config/nvim/` (LazyVim configuration)
- **Starship Prompt**: `~/.config/starship.toml`

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

After installation, both shells are ready to use:

### Using Fish Shell

1. **Start a Fish session**:

   ```bash
   fish
   ```

2. **Make Fish your default shell** (optional):
   ```bash
   chsh -s /opt/homebrew/bin/fish  # Apple Silicon
   chsh -s /usr/local/bin/fish      # Intel Mac
   ```

### Using Zsh

1. **Start a Zsh session**:

   ```bash
   zsh
   ```

2. **Make Zsh your default shell** (optional):
   ```bash
   chsh -s /opt/homebrew/bin/zsh   # Apple Silicon
   chsh -s /usr/local/bin/zsh       # Intel Mac
   ```

### Explore the features:

- Try typing a command and pressing Tab for completions
- Use up/down arrows to search command history
- In Fish: Run `fish_config` for web-based configuration
- In Zsh: Edit `~/.config/zsh/conf.d/` files for customization

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

Found an issue or have a suggestion? Please open an issue or submit a PR on the [GitHub repository](https://github.com/roderik/shell-config).

## License

MIT - See [LICENSE](LICENSE) file for details

## Support

- Issues: [GitHub Issues](https://github.com/roderik/shell-config/issues)
- Discussions: [GitHub Discussions](https://github.com/roderik/shell-config/discussions)
