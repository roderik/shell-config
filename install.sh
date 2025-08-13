#!/usr/bin/env bash

set -euo pipefail

# Shell Configuration installer for Fish/Zsh Shell and modern development tools
# Installs and configures Fish or Zsh shell, Starship prompt, and modern CLI tools

# Color codes for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Emoji indicators
SUCCESS="✅"
ERROR="❌"
WARNING="⚠️"
INFO="ℹ️"
ROCKET="🚀"

# Path validation function to prevent directory traversal and injection attacks
validate_path() {
  local path="$1"
  local description="${2:-path}"
  
  # Check for directory traversal attempts
  if [[ "$path" == *".."* ]]; then
    printf "${RED}${ERROR} Invalid %s: Path cannot contain '..' (directory traversal)${NC}\n" "$description" >&2
    return 1
  fi
  
  # Check for absolute paths
  if [[ "$path" == "/"* ]]; then
    printf "${RED}${ERROR} Invalid %s: Path cannot be absolute${NC}\n" "$description" >&2
    return 1
  fi
  
  # Check for path starting with tilde (home directory expansion)
  if [[ "$path" == "~"* ]]; then
    printf "${RED}${ERROR} Invalid %s: Path cannot start with '~'${NC}\n" "$description" >&2
    return 1
  fi
  
  # Check for command injection characters in filenames
  # These characters pose significant security risks in shell contexts
  if [[ "$path" == *";"* ]] || [[ "$path" == *"|"* ]] || [[ "$path" == *"&"* ]] || \
     [[ "$path" == *'`'* ]] || [[ "$path" == *'$('* ]] || [[ "$path" == *">"* ]] || \
     [[ "$path" == *"<"* ]]; then
    printf "${RED}${ERROR} Invalid %s: Path contains potentially dangerous characters${NC}\n" "$description" >&2
    return 1
  fi
  
  return 0
}

# Print colored output
print_color() {
  local color=$1
  shift
  printf "${color}%s${NC}\n" "$*"
}

# Print status messages
log_success() { printf "${GREEN}${SUCCESS} %s${NC}\n" "$*"; }
log_error() { printf "${RED}${ERROR} %s${NC}\n" "$*" >&2; }
log_warning() { printf "${YELLOW}${WARNING} %s${NC}\n" "$*"; }
log_info() { printf "${CYAN}${INFO} %s${NC}\n" "$*"; }

# Display ASCII art with gradient colors
show_banner() {
  printf "\n"
  printf "${BLUE}    ███████${CYAN}╗██${GREEN}╗  ██${YELLOW}╗███████${MAGENTA}╗██${RED}╗     ██${BLUE}╗     ${NC}\n"
  printf "${BLUE}    ██${CYAN}╔════╝██${GREEN}║  ██${YELLOW}║██${MAGENTA}╔════╝██${RED}║     ██${BLUE}║     ${NC}\n"
  printf "${BLUE}    ███████${CYAN}╗███████${GREEN}║█████${YELLOW}╗  ██${MAGENTA}║     ██${RED}║     ${NC}\n"
  printf "${BLUE}    ╚════██${CYAN}║██${GREEN}╔══██║██${YELLOW}╔══╝  ██${MAGENTA}║     ██${RED}║     ${NC}\n"
  printf "${BLUE}    ███████${CYAN}║██${GREEN}║  ██║███████${YELLOW}╗███████${MAGENTA}╗███████${RED}╗${NC}\n"
  printf "${BLUE}    ╚══════${CYAN}╝╚═${GREEN}╝  ╚═╝╚══════${YELLOW}╝╚══════${MAGENTA}╝╚══════${RED}╝${NC}\n"
  printf "\n"
  printf "${BOLD}${MAGENTA}          ╔═════════════════════════════════╗${NC}\n"
  printf "${BOLD}${CYAN}          ║    Modern Shell Configuration   ║${NC}\n"
  printf "${BOLD}${MAGENTA}          ╚═════════════════════════════════╝${NC}\n"
  printf "\n"
}

# Check for required dependencies
check_dependencies() {
  local missing_deps=()
  
  for cmd in curl git; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing_deps+=("$cmd")
    fi
  done
  
  if [ ${#missing_deps[@]} -gt 0 ]; then
    log_error "Missing required dependencies: ${missing_deps[*]}"
    log_info "Please install the missing tools and try again."
    
    # Provide installation hints
    if [[ "$OSTYPE" == "darwin"* ]]; then
      log_info "On macOS, you can install with: xcode-select --install"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      log_info "On Linux, install with your package manager (apt, yum, etc.)"
    fi
    exit 1
  fi
}

# Detect the script directory
script_dir() {
  local src="$0"
  while [ -h "$src" ]; do
    local dir
    dir=$(cd -P "$(dirname "$src")" && pwd)
    src=$(readlink "$src")
    case $src in
      /*) ;;
      *) src="$dir/$src" ;;
    esac
  done
  cd -P "$(dirname "$src")" >/dev/null 2>&1 && pwd
}

# Backup file if it exists
backup_file() {
  local file="$1"
  if [ -f "$file" ]; then
    local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$file" "$backup"
    log_info "Backed up existing file to: $backup"
  fi
}

# Install Fish configuration
install_fish_config() {
  local config_base="$1"
  local force_overwrite="$2"
  local dry_run="$3"
  
  if [[ "$dry_run" -eq 1 ]]; then
    if [[ -f "$config_base/fish/config.fish" ]] || [[ -d "$config_base/fish/conf.d" ]]; then
      print_color "$BOLD" "  🐟 Fish Configuration:"
      
      # Main config
      if [ -f "$config_base/fish/config.fish" ]; then
        local target_file=~/.config/fish/config.fish
        if [ -f "$target_file" ]; then
          print_color "$YELLOW" "    ⚠️  config.fish (already exists)"
        else
          print_color "$GREEN" "    + config.fish (new file)"
        fi
      fi
      
      # Conf.d modules
      if [ -d "$config_base/fish/conf.d" ]; then
        find "$config_base/fish/conf.d" -name "*.fish" -type f | sort | while read conf_file; do
          local conf_name=$(basename "$conf_file")
          local target_file=~/.config/fish/conf.d/"$conf_name"
          if [ -f "$target_file" ]; then
            print_color "$YELLOW" "    ⚠️  conf.d/$conf_name (already exists)"
          else
            print_color "$GREEN" "    + conf.d/$conf_name (new file)"
          fi
        done
      fi
      printf "\n"
    fi
  else
    # Actual installation for Fish
    if [[ -f "$config_base/fish/config.fish" ]] || [[ -d "$config_base/fish/conf.d" ]]; then
      log_info "Installing Fish configuration..."
      
      # Copy main config
      if [ -f "$config_base/fish/config.fish" ]; then
        local target_file=~/.config/fish/config.fish
        if [ -f "$target_file" ] && [ "$force_overwrite" -eq 0 ]; then
          backup_file "$target_file"
        fi
        cp "$config_base/fish/config.fish" "$target_file"
        log_success "  → config.fish installed"
      fi
      
      # Copy conf.d modules
      if [ -d "$config_base/fish/conf.d" ]; then
        mkdir -p ~/.config/fish/conf.d
        find "$config_base/fish/conf.d" -name "*.fish" -type f | sort | while read conf_file; do
          local conf_name=$(basename "$conf_file")
          local target_file=~/.config/fish/conf.d/"$conf_name"
          if [ -f "$target_file" ] && [ "$force_overwrite" -eq 0 ]; then
            backup_file "$target_file"
          fi
          cp "$conf_file" "$target_file"
          log_success "  → conf.d/$conf_name installed"
        done
      fi
    fi
  fi
}

# Install Zsh configuration
install_zsh_config() {
  local config_base="$1"
  local force_overwrite="$2"
  local dry_run="$3"
  
  if [[ "$dry_run" -eq 1 ]]; then
    # Dry run for Zsh
    if [[ -f "$config_base/zsh/.zshrc" ]] || [[ -d "$config_base/zsh/conf.d" ]]; then
      print_color "$BOLD" "  🚀 Zsh Configuration:"
      
      # Main .zshrc
      if [ -f "$config_base/zsh/.zshrc" ]; then
        local target_file=~/.zshrc
        if [ -f "$target_file" ]; then
          print_color "$YELLOW" "    ⚠️  .zshrc (already exists)"
        else
          print_color "$GREEN" "    + .zshrc (new file)"
        fi
      fi
      
      # Conf.d modules
      if [ -d "$config_base/zsh/conf.d" ]; then
        find "$config_base/zsh/conf.d" -name "*.zsh" -type f | sort | while read conf_file; do
          local conf_name=$(basename "$conf_file")
          local target_file=~/.config/zsh/conf.d/"$conf_name"
          if [ -f "$target_file" ]; then
            print_color "$YELLOW" "    ⚠️  conf.d/$conf_name (already exists)"
          else
            print_color "$GREEN" "    + conf.d/$conf_name (new file)"
          fi
        done
      fi
      printf "\n"
    fi
  else
    # Actual installation for Zsh
    if [[ -f "$config_base/zsh/.zshrc" ]] || [[ -d "$config_base/zsh/conf.d" ]]; then
      log_info "Installing Zsh configuration..."
      
      # Copy main .zshrc
      if [ -f "$config_base/zsh/.zshrc" ]; then
        local target_file=~/.zshrc
        if [ -f "$target_file" ] && [ "$force_overwrite" -eq 0 ]; then
          backup_file "$target_file"
        fi
        cp "$config_base/zsh/.zshrc" "$target_file"
        log_success "  → .zshrc installed"
      fi
      
      # Copy conf.d modules
      if [ -d "$config_base/zsh/conf.d" ]; then
        mkdir -p ~/.config/zsh/conf.d
        find "$config_base/zsh/conf.d" -name "*.zsh" -type f | sort | while read conf_file; do
          local conf_name=$(basename "$conf_file")
          local target_file=~/.config/zsh/conf.d/"$conf_name"
          if [ -f "$target_file" ] && [ "$force_overwrite" -eq 0 ]; then
            backup_file "$target_file"
          fi
          cp "$conf_file" "$target_file"
          log_success "  → conf.d/$conf_name installed"
        done
      fi
    fi
  fi
}

# Install Starship configuration
install_starship_config() {
  local config_base="$1"
  local force_overwrite="$2"
  local dry_run="$3"
  
  if [[ "$dry_run" -eq 1 ]]; then
    if [ -f "$config_base/starship/starship.toml" ]; then
      print_color "$BOLD" "  ⭐ Starship Configuration:"
      local target_file=~/.config/starship.toml
      if [ -f "$target_file" ]; then
        print_color "$YELLOW" "    ⚠️  starship.toml (already exists)"
      else
        print_color "$GREEN" "    + starship.toml (new file)"
      fi
      printf "\n"
    fi
  else
    if [ -f "$config_base/starship/starship.toml" ]; then
      log_info "Installing Starship configuration..."
      local target_file=~/.config/starship.toml
      if [ -f "$target_file" ] && [ "$force_overwrite" -eq 0 ]; then
        backup_file "$target_file"
      fi
      cp "$config_base/starship/starship.toml" "$target_file"
      log_success "  → starship.toml installed"
    fi
  fi
}

# Main installation function
main() {
  local force_overwrite=0
  local dry_run=0
  
  # Parse arguments
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --force)
        force_overwrite=1
        shift
        ;;
      --dry-run)
        dry_run=1
        shift
        ;;
      -h|--help)
        cat <<'USAGE'
Usage: ./install.sh [OPTIONS]

Installs modern shell configuration for both Fish and Zsh shells with development tools.

Options:
  --force          Overwrite existing configurations
  --dry-run        Show what would be done without making changes
  -h, --help       Show this help message

Configuration is installed to:
  - Fish: ~/.config/fish/
  - Zsh: ~/.config/zsh/ and ~/.zshrc
  - Starship: ~/.config/starship.toml
USAGE
        exit 0
        ;;
      *)
        log_error "Unknown option: $1"
        exit 2
        ;;
    esac
  done
  
  # Show banner
  show_banner
  
  # Check dependencies
  check_dependencies
  
  log_info "Installing configuration for both Fish and Zsh shells"
  
  # Detect OS and architecture
  local OS=$(uname -s)
  local ARCH=$(uname -m)
  
  if [[ "$OS" != "Darwin" ]]; then
    log_error "This script is designed for macOS only."
    exit 1
  fi
  
  log_info "Detected macOS on $ARCH architecture"
  printf "\n"
  
  # Detect Homebrew path based on architecture
  local BREW_PATH
  local FISH_PATH
  local ZSH_PATH
  if [[ "$ARCH" == "arm64" ]]; then
    BREW_PATH="/opt/homebrew/bin/brew"
    FISH_PATH="/opt/homebrew/bin/fish"
    ZSH_PATH="/opt/homebrew/bin/zsh"
  else
    BREW_PATH="/usr/local/bin/brew"
    FISH_PATH="/usr/local/bin/fish"
    ZSH_PATH="/usr/local/bin/zsh"
  fi
  
  # Detect source directory
  local repo_root
  repo_root=$(script_dir)
  local config_base="$repo_root/config"
  
  print_color "$BOLD" "=== Installing Homebrew & Development Tools ==="
  
  if [ "$dry_run" -eq 1 ]; then
    log_info "[DRY RUN] Would check/install Homebrew at: $BREW_PATH"
    log_info "[DRY RUN] Would install the following tools:"
    printf "  • neovim     - Modern Vim editor\n"
    printf "  • luarocks   - Lua package manager\n"
    printf "  • tree-sitter - Parser for syntax highlighting\n"
    printf "  • starship   - Cross-shell prompt\n"
    printf "  • bat        - Cat with syntax highlighting\n"
    printf "  • eza        - Modern replacement for ls\n"
    printf "  • ripgrep    - Fast grep alternative\n"
    printf "  • fd         - Fast find alternative\n"
    printf "  • fzf        - Fuzzy finder\n"
    printf "  • lazygit    - Terminal UI for git\n"
    printf "  • lazydocker - Terminal UI for docker\n"
    printf "  • fnm        - Fast Node.js version manager\n"
    printf "  • direnv     - Per-project environment variables\n"
    printf "  • zoxide     - Smarter cd command (z/zi)\n"
    printf "  • atuin      - Better shell history with sync\n"
    printf "  • And more...\n"
    printf "\n"
  else
    # Install or update Homebrew
    log_info "Checking Homebrew installation..."
    if ! command -v "$BREW_PATH" &> /dev/null; then
      log_warning "Installing Homebrew..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
      log_success "Homebrew is already installed"
      log_info "Updating Homebrew..."
      "$BREW_PATH" update
    fi
    
    # Install modern tools
    log_info "Installing modern development tools..."
    local TOOLS=(
      # Shells
      "zsh"            # Latest Zsh from Homebrew
      "fish"           # Fish shell
      # Zsh plugins
      "zsh-syntax-highlighting"
      "zsh-autosuggestions"
      "zsh-completions"
      # Common tools
      "starship"       # Modern prompt
      "bat"            # Better cat
      "chafa"          # Terminal graphics
      "hexyl"          # Hex viewer
      "fd"             # Better find
      "ripgrep"        # Better grep
      "git-delta"      # Better git diff
      "procs"          # Better ps
      "broot"          # Better tree
      "neovim"         # Neovim editor
      "luarocks"       # Lua package manager for Neovim
      "tree-sitter"    # Parser generator for Neovim
      "eza"            # Better ls (exa replacement)
      "fnm"            # Fast Node.js version manager
      "1password-cli"  # 1Password CLI
      "lazygit"        # Terminal UI for git
      "lazydocker"     # Terminal UI for docker
      "fzf"            # Fuzzy finder
      "direnv"         # Per-project environment variables
      "zoxide"         # Smarter cd command
      "atuin"          # Better shell history
    )
    
    for tool in "${TOOLS[@]}"; do
      if "$BREW_PATH" list --versions "$tool" &> /dev/null; then
        log_success "$tool is already installed"
      else
        log_info "Installing $tool..."
        "$BREW_PATH" install "$tool"
      fi
    done
    
    # Configure atuin
    log_info "Configuring atuin..."
    if "$BREW_PATH" services list | grep -q "atuin.*started"; then
      log_success "atuin service is already running"
    else
      # Try to start the service, but don't fail if it doesn't work
      if "$BREW_PATH" services start atuin 2>/dev/null; then
        log_success "atuin service started"
      else
        log_warning "Could not start atuin service automatically"
        log_info "This is normal on some macOS versions. Atuin will still work in your shell."
      fi
    fi
  fi
  
  printf "\n"
  print_color "$BOLD" "=== Configuring Shell ==="
  
  if [ "$dry_run" -eq 1 ]; then
    log_info "[DRY RUN] Would add Fish shell to /etc/shells"
    log_info "[DRY RUN] Would add Zsh to /etc/shells"
    log_info "[DRY RUN] Would create configuration directories"
    printf "\n"
  else
    # Configure Fish
    # Add Fish to allowed shells
    if grep -q "$FISH_PATH" /etc/shells; then
      log_success "Fish shell is already in /etc/shells"
    else
      log_info "Adding Fish to allowed shells (requires sudo)..."
      echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
      log_success "Fish shell added to /etc/shells"
    fi
    
    # Create Fish config directories
    log_info "Creating Fish configuration directories..."
    mkdir -p ~/.config/fish/conf.d
    
    # Configure Zsh
    # Add Zsh to allowed shells (if custom installation)
    if [[ -f "$ZSH_PATH" ]] && ! grep -q "$ZSH_PATH" /etc/shells; then
      log_info "Adding Zsh to allowed shells (requires sudo)..."
      echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
      log_success "Zsh added to /etc/shells"
    fi
    
    # Create Zsh config directories
    log_info "Creating Zsh configuration directories..."
    mkdir -p ~/.config/zsh/conf.d
    
    # Create Starship directory
    mkdir -p ~/.config
  fi
  
  printf "\n"
  print_color "$BOLD" "=== Configuring Neovim with LazyVim ==="
  
  if [ "$dry_run" -eq 1 ]; then
    log_info "[DRY RUN] Would install LazyVim configuration for Neovim"
    log_info "[DRY RUN] Would backup existing ~/.config/nvim if present"
    log_info "[DRY RUN] Would clone LazyVim starter configuration"
    log_info "[DRY RUN] Would download Omarchy configuration files"
    log_info "[DRY RUN] Would disable relative line numbers"
    printf "\n"
  else
    log_info "Setting up Neovim with LazyVim..."
    
    # Backup existing Neovim config if present
    if [ -d ~/.config/nvim ]; then
      local nvim_backup=~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)
      mv ~/.config/nvim "$nvim_backup"
      log_info "Backed up existing Neovim config to: $nvim_backup"
    fi
    
    # Clone LazyVim starter
    log_info "Installing LazyVim starter configuration..."
    git clone https://github.com/LazyVim/starter ~/.config/nvim
    
    # Create necessary directories
    mkdir -p ~/.config/nvim/lua/plugins
    mkdir -p ~/.config/nvim/lua/config
    
    # Create Catppuccin theme configuration
    log_info "Configuring Catppuccin theme..."
    cat > ~/.config/nvim/lua/plugins/catppuccin.lua << 'EOF'
return {
  -- Add Catppuccin colorscheme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "macchiato", -- latte, frappe, macchiato, mocha
      transparent_background = false,
      show_end_of_buffer = false,
      term_colors = true,
      dim_inactive = {
        enabled = false,
        shade = "dark",
        percentage = 0.15,
      },
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
        loops = {},
        functions = {},
        keywords = {},
        strings = {},
        variables = {},
        numbers = {},
        booleans = {},
        properties = {},
        types = {},
        operators = {},
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        telescope = true,
        notify = true,
        mini = true,
        hop = true,
        indent_blankline = {
          enabled = true,
          colored_indent_levels = false,
        },
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
        },
      },
    },
  },
  
  -- Configure LazyVim to use Catppuccin
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
EOF
    log_success "Catppuccin theme configured"
    
    # Remove the .git directory to make it your own
    rm -rf ~/.config/nvim/.git
    
    # Create custom options file with relative numbers disabled
    cat > ~/.config/nvim/lua/config/options.lua << 'EOF'
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.relativenumber = false
EOF
    log_success "Disabled relative line numbers"
    
    log_success "LazyVim installed successfully"
    log_info "LazyVim will install plugins on first launch of Neovim"
  fi
  
  printf "\n"
  print_color "$BOLD" "=== Installing Configuration Files ==="
  
  # Detect if running from local directory or curl
  if [[ -n "${BASH_SOURCE[0]:-}" ]] && ([[ -f "$config_base/fish/config.fish" ]] || [[ -f "$config_base/zsh/.zshrc" ]]); then
    # Local installation
    log_info "Local installation detected"
    
    if [ "$dry_run" -eq 1 ]; then
      log_info "[DRY RUN] Would install the following configuration files:"
      printf "\n"
    fi
    
    # Install configurations for both shells
    install_fish_config "$config_base" "$force_overwrite" "$dry_run"
    install_zsh_config "$config_base" "$force_overwrite" "$dry_run"
    
    # Install Starship for any shell choice
    install_starship_config "$config_base" "$force_overwrite" "$dry_run"
    
  else
    # Remote installation via curl
    log_info "Remote installation - downloading configurations..."
    
    # Base URL for raw GitHub content
    local GITHUB_BASE="https://raw.githubusercontent.com/roderik/shell-config/main"
    
    if [ "$dry_run" -eq 1 ]; then
      log_info "[DRY RUN] Would download and install:"
      printf "  • Fish configuration from GitHub\n"
      printf "  • Zsh configuration from GitHub\n"
      printf "  • Starship configuration from GitHub\n"
    else
      # Download Fish configuration
      log_info "Downloading Fish configuration..."
      if [ -f ~/.config/fish/config.fish ] && [ "$force_overwrite" -eq 0 ]; then
        backup_file ~/.config/fish/config.fish
      fi
      curl -sL "$GITHUB_BASE/config/fish/config.fish" -o ~/.config/fish/config.fish
      log_success "Fish configuration installed"
      
      # Download Zsh configuration
      log_info "Downloading Zsh configuration..."
      if [ -f ~/.zshrc ] && [ "$force_overwrite" -eq 0 ]; then
        backup_file ~/.zshrc
      fi
      curl -sL "$GITHUB_BASE/config/zsh/.zshrc" -o ~/.zshrc
      
      # Download conf.d files
      mkdir -p ~/.config/zsh/conf.d
      for conf_file in 00-environment 10-options 20-completions 30-aliases 40-functions 50-keybindings 60-plugins; do
        curl -sL "$GITHUB_BASE/config/zsh/conf.d/${conf_file}.zsh" -o ~/.config/zsh/conf.d/${conf_file}.zsh
      done
      log_success "Zsh configuration installed"
      
      # Download Starship configuration
      log_info "Downloading Starship configuration..."
      if [ -f ~/.config/starship.toml ] && [ "$force_overwrite" -eq 0 ]; then
        backup_file ~/.config/starship.toml
      fi
      curl -sL "$GITHUB_BASE/config/starship/starship.toml" -o ~/.config/starship.toml
      log_success "Starship configuration installed"
    fi
  fi
  
  # Create manifest for uninstall
  if [ "$dry_run" -eq 0 ]; then
    local manifest=~/.config/.shell-config-manifest.json
    cat > "$manifest" <<EOF
{
  "version": "1.0",
  "installed": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "shell": "both",
  "source": "$repo_root",
  "configurations": [
EOF
    
    echo '    "~/.config/fish/",' >> "$manifest"
    echo '    "~/.zshrc",' >> "$manifest"
    echo '    "~/.config/zsh/",' >> "$manifest"
    echo '    "~/.config/nvim/",' >> "$manifest"
    echo '    "~/.config/starship.toml"' >> "$manifest"
    
    cat >> "$manifest" <<EOF
  ],
  "tools": [
    "starship", "bat", "eza", "ripgrep", "fd", "fzf",
    "lazygit", "lazydocker", "fnm", "direnv", "zoxide", "atuin"
  ]
}
EOF
    log_success "Created manifest: $manifest"
  fi
  
  printf "\n"
  
  # Success message
  print_color "$BOLD$GREEN" "    ╔════════════════════════════════════════╗"
  print_color "$BOLD$GREEN" "    ║     ${ROCKET} Installation Complete! ${ROCKET}      ║"
  print_color "$BOLD$GREEN" "    ╚════════════════════════════════════════╝"
  printf "\n"
  
  log_success "Shell configuration has been successfully installed!"
  printf "\n"
  
  # Show instructions for both shells
  print_color "$CYAN" "To start using your new shell configuration:"
  printf "\n"
  print_color "$BOLD" "For Fish shell:"
  printf "  • Start a new session: ${YELLOW}fish${NC}\n"
  printf "  • Make it default: ${YELLOW}chsh -s $FISH_PATH${NC}\n"
  printf "\n"
  print_color "$BOLD" "For Zsh:"
  printf "  • Start a new session: ${YELLOW}zsh${NC}\n"
  printf "  • Make it default: ${YELLOW}chsh -s $ZSH_PATH${NC}\n"
  printf "\n"
  
  print_color "$CYAN" "Installed tools:"
  printf "  • neovim     - Modern Vim with LazyVim config\n"
  printf "  • starship   - Cross-shell prompt\n"
  printf "  • bat        - Cat with syntax highlighting\n"
  printf "  • eza        - Modern replacement for ls\n"
  printf "  • ripgrep    - Fast grep alternative\n"
  printf "  • fd         - Fast find alternative\n"
  printf "  • fzf        - Fuzzy finder\n"
  printf "  • lazygit    - Terminal UI for git\n"
  printf "  • lazydocker - Terminal UI for docker\n"
  printf "  • fnm        - Fast Node.js version manager\n"
  printf "  • direnv     - Per-project environment variables\n"
  printf "  • zoxide     - Smarter cd command (z/zi)\n"
  printf "  • atuin      - Better shell history with sync\n"
  printf "  • And more!\n"
  printf "\n"
  
  print_color "$CYAN" "Configuration files installed:"
  printf "  • ~/.config/fish/config.fish\n"
  printf "  • ~/.config/fish/conf.d/ (Fish modular configuration)\n"
  printf "  • ~/.zshrc\n"
  printf "  • ~/.config/zsh/conf.d/ (Zsh modular configuration)\n"
  printf "  • ~/.config/nvim/ (LazyVim configuration)\n"
  printf "  • ~/.config/starship.toml\n"
  printf "\n"
  
  log_info "To uninstall, run: ./uninstall.sh"
}

# Run main function
main "$@"