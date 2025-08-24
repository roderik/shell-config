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
  printf "${BLUE}███████${CYAN}╗██${GREEN}╗  ██${YELLOW}╗███████${MAGENTA}╗██${RED}╗     ██${BLUE}╗     ${NC}\n"
  printf "${BLUE}██${CYAN}╔════╝██${GREEN}║  ██${YELLOW}║██${MAGENTA}╔════╝██${RED}║     ██${BLUE}║     ${NC}\n"
  printf "${BLUE}███████${CYAN}╗███████${GREEN}║█████${YELLOW}╗  ██${MAGENTA}║     ██${RED}║     ${NC}\n"
  printf "${BLUE}╚════██${CYAN}║██${GREEN}╔══██║██${YELLOW}╔══╝  ██${MAGENTA}║     ██${RED}║     ${NC}\n"
  printf "${BLUE}███████${CYAN}║██${GREEN}║  ██║███████${YELLOW}╗███████${MAGENTA}╗███████${RED}╗${NC}\n"
  printf "${BLUE}╚══════${CYAN}╝╚═${GREEN}╝  ╚═╝╚══════${YELLOW}╝╚══════${MAGENTA}╝╚══════${RED}╝${NC}\n"
  printf "\n"
  printf "${BOLD}${MAGENTA}╔═════════════════════════════════╗${NC}\n"
  printf "${BOLD}${CYAN}║    Modern Shell Configuration   ║${NC}\n"
  printf "${BOLD}${MAGENTA}╚═════════════════════════════════╝${NC}\n"
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
        if [ -f "$target_file" ]; then
          # Check if the existing file is different from our new one
          if ! cmp -s "$config_base/fish/config.fish" "$target_file"; then
            backup_file "$target_file"
            cp "$config_base/fish/config.fish" "$target_file"
            log_success "  → config.fish updated (old version backed up)"
          else
            log_success "  → config.fish already up to date"
          fi
        else
          cp "$config_base/fish/config.fish" "$target_file"
          log_success "  → config.fish installed"
        fi
      fi

      # Copy conf.d modules
      if [ -d "$config_base/fish/conf.d" ]; then
        mkdir -p ~/.config/fish/conf.d
        find "$config_base/fish/conf.d" -name "*.fish" -type f | sort | while read conf_file; do
          local conf_name=$(basename "$conf_file")
          local target_file=~/.config/fish/conf.d/"$conf_name"
          if [ -f "$target_file" ]; then
            if [ "$force_overwrite" -eq 0 ]; then
              backup_file "$target_file"
            fi
            cp "$conf_file" "$target_file"
            log_success "  → conf.d/$conf_name updated"
          else
            cp "$conf_file" "$target_file"
            log_success "  → conf.d/$conf_name installed"
          fi
        done
      fi
    fi
  fi
}

# Install Bash configuration
install_bash_config() {
  local config_base="$1"
  local force_overwrite="$2"
  local dry_run="$3"

  if [[ "$dry_run" -eq 1 ]]; then
    # Dry run for Bash
    if [[ -f "$config_base/bash/.bashrc" ]] || [[ -f "$config_base/bash/.bash_profile" ]] || [[ -d "$config_base/bash/conf.d" ]]; then
      print_color "$BOLD" "  🐚 Bash Configuration:"

      # Main .bashrc
      if [ -f "$config_base/bash/.bashrc" ]; then
        local target_file=~/.bashrc
        if [ -f "$target_file" ]; then
          print_color "$YELLOW" "    ⚠️  .bashrc (already exists)"
        else
          print_color "$GREEN" "    + .bashrc (new file)"
        fi
      fi

      # .bash_profile
      if [ -f "$config_base/bash/.bash_profile" ]; then
        local target_file=~/.bash_profile
        if [ -f "$target_file" ]; then
          print_color "$YELLOW" "    ⚠️  .bash_profile (already exists)"
        else
          print_color "$GREEN" "    + .bash_profile (new file)"
        fi
      fi

      # Conf.d modules
      if [ -d "$config_base/bash/conf.d" ]; then
        find "$config_base/bash/conf.d" -name "*.bash" -type f | sort | while read conf_file; do
          local conf_name=$(basename "$conf_file")
          local target_file=~/.config/bash/conf.d/"$conf_name"
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
    # Actual installation for Bash
    if [[ -f "$config_base/bash/.bashrc" ]] || [[ -f "$config_base/bash/.bash_profile" ]] || [[ -d "$config_base/bash/conf.d" ]]; then
      log_info "Installing Bash configuration..."

      # Copy main .bashrc
      if [ -f "$config_base/bash/.bashrc" ]; then
        local target_file=~/.bashrc
        if [ -f "$target_file" ] && [ "$force_overwrite" -eq 0 ]; then
          backup_file "$target_file"
        fi
        cp "$config_base/bash/.bashrc" "$target_file"
        log_success "  → .bashrc installed"
      fi

      # Copy .bash_profile
      if [ -f "$config_base/bash/.bash_profile" ]; then
        local target_file=~/.bash_profile
        if [ -f "$target_file" ] && [ "$force_overwrite" -eq 0 ]; then
          backup_file "$target_file"
        fi
        cp "$config_base/bash/.bash_profile" "$target_file"
        log_success "  → .bash_profile installed"
      fi

      # Copy conf.d modules
      if [ -d "$config_base/bash/conf.d" ]; then
        mkdir -p ~/.config/bash/conf.d
        find "$config_base/bash/conf.d" -name "*.bash" -type f | sort | while read conf_file; do
          local conf_name=$(basename "$conf_file")
          local target_file=~/.config/bash/conf.d/"$conf_name"
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

# Install Ghostty terminal configuration
install_ghostty_config() {
  local config_base="$1"
  local force_overwrite="$2"
  local dry_run="$3"

  if [[ "$dry_run" -eq 1 ]]; then
    if [ -f "$config_base/ghostty/config" ]; then
      print_color "$BOLD" "  👻 Ghostty Configuration:"
      local target_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
      local target_file="$target_dir/config"
      if [ -f "$target_file" ]; then
        print_color "$YELLOW" "    ⚠️  ghostty/config (already exists)"
      else
        print_color "$GREEN" "    + ghostty/config (new file)"
      fi
      printf "\n"
    fi
  else
    if [ -f "$config_base/ghostty/config" ]; then
      log_info "Installing Ghostty configuration..."
      local target_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
      local target_file="$target_dir/config"

      # Create directory if it doesn't exist
      mkdir -p "$target_dir"

      if [ -f "$target_file" ] && [ "$force_overwrite" -eq 0 ]; then
        backup_file "$target_file"
      fi
      cp "$config_base/ghostty/config" "$target_file"
      log_success "  → Ghostty config installed"
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

Installs modern shell configuration for Fish, Zsh, and Bash shells with development tools.

Options:
  --force          Overwrite existing configurations
  --dry-run        Show what would be done without making changes
  -h, --help       Show this help message

Configuration is installed to:
  - Fish: ~/.config/fish/
  - Zsh: ~/.config/zsh/ and ~/.zshrc
  - Bash: ~/.config/bash/, ~/.bashrc and ~/.bash_profile
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

  log_info "Installing configuration for Fish, Zsh, and Bash shells"

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
    printf "  • foundry    - Ethereum development toolkit\n"
    printf "  • And more...\n"
    printf "\n"
    log_info "[DRY RUN] Would install Bun via official installer (curl -fsSL https://bun.sh/install | bash)"
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
      # Core tools from shell configs
      "starship"       # Modern prompt (used in 70-prompt.bash)
      "bat"            # Better cat (used in 20-fzf.bash for preview)
      "eza"            # Better ls (used in 10-aliases.bash)
      "fd"             # Better find (used in 20-fzf.bash)
      "ripgrep"        # Better grep (rg command)
      "fzf"            # Fuzzy finder (20-fzf.bash)
      "direnv"         # Per-project environment variables (60-modern-tools.bash)
      "zoxide"         # Smarter cd command (60-modern-tools.bash)
      "atuin"          # Better shell history (60-modern-tools.bash)
      "fnm"            # Fast Node.js version manager (10-node.bash)
      # Additional modern tools
      "neovim"         # Neovim editor (nvim in aliases)
      "lazygit"        # Terminal UI for git
      "lazydocker"     # Terminal UI for docker
      "git-delta"      # Better git diff
      "chafa"          # Terminal graphics
      "hexyl"          # Hex viewer
      "procs"          # Better ps
      "broot"          # Better tree
      "luarocks"       # Lua package manager for Neovim
      "tree-sitter"    # Parser generator for Neovim
      # Development tools
      "foundry"        # Ethereum development toolkit
      # New tools
      "ast-grep"       # Structural search/replace tool
      "awscli"         # AWS Command Line Interface
      "azure-cli"      # Azure Command Line Interface
      "bash"           # Latest Bash from Homebrew
      "codex"          # AI code assistant
      "gh"             # GitHub CLI
      "git"            # Latest Git from Homebrew
      "helm"           # Kubernetes package manager
      "helm-docs"      # Auto-generate Helm chart documentation
      "kubectx"        # Switch between kubectl contexts
      "kubernetes-cli" # kubectl command
      "node"           # Node.js JavaScript runtime
      "rsync"          # Fast file transfer
      "tilt"           # Local Kubernetes development
      "tmux"           # Terminal multiplexer
      "zellij"         # Modern terminal multiplexer
      "uv"             # Fast Python package installer
      "shellcheck"     # Shell script static analysis tool
    )

    # Install all tools in one go without checking
    log_info "Installing all tools in batch (this may take a while)..."
    "$BREW_PATH" install "${TOOLS[@]}"

    # Install cask applications
    log_info "Installing cask applications..."
    local CASKS=(
      "1password"      # Password manager
      "chatgpt"        # ChatGPT desktop app
      "cursor"         # AI-powered code editor
      "google-cloud-sdk" # Google Cloud SDK (gcloud)
      "ghostty"        # Modern terminal emulator
      "claude"        # AI-powered coding assistant
      "1password-cli"  # 1Password CLI (11-1password.bash)
      "vibetunnel"     # VibeTunnel CLI tool (vt command, used in 32-claude-function.bash)
    )

    # Get list of installed casks in one go
    local installed_casks=$("$BREW_PATH" list --cask 2>/dev/null || true)

    # Filter out already installed casks
    local casks_to_install=()
    for cask in "${CASKS[@]}"; do
      if echo "$installed_casks" | grep -q "^${cask}$"; then
        log_success "$cask is already installed via Homebrew"
      else
        casks_to_install+=("$cask")
      fi
    done

    # Install remaining casks in one batch if there are any
    if [ ${#casks_to_install[@]} -gt 0 ]; then
      log_info "Installing casks in batch: ${casks_to_install[*]}"
      "$BREW_PATH" install --cask "${casks_to_install[@]}" || {
        log_warning "Some casks failed to install. They may already be installed or require manual installation"
      }
    else
      log_success "All casks are already installed"
    fi

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

    # Configure tools that need special setup
    log_info "Configuring tool-specific settings..."

    # Configure kubectx/kubens
    if command -v kubectx &> /dev/null; then
      log_info "Configuring kubectx..."
      # Create completion directories if they don't exist
      mkdir -p ~/.config/fish/completions
      mkdir -p ~/.config/zsh/completions
      mkdir -p ~/.config/bash/completions

      # Link completions for kubectx and kubens
      local BREW_PREFIX
      if [[ "$ARCH" == "arm64" ]]; then
        BREW_PREFIX="/opt/homebrew"
      else
        BREW_PREFIX="/usr/local"
      fi

      # Fish completions
      if [ -f "$BREW_PREFIX/share/fish/vendor_completions.d/kubectx.fish" ]; then
        ln -sf "$BREW_PREFIX/share/fish/vendor_completions.d/kubectx.fish" ~/.config/fish/completions/
        ln -sf "$BREW_PREFIX/share/fish/vendor_completions.d/kubens.fish" ~/.config/fish/completions/
      fi

      # Zsh completions
      if [ -f "$BREW_PREFIX/share/zsh/site-functions/_kubectx" ]; then
        ln -sf "$BREW_PREFIX/share/zsh/site-functions/_kubectx" ~/.config/zsh/completions/
        ln -sf "$BREW_PREFIX/share/zsh/site-functions/_kubens" ~/.config/zsh/completions/
      fi

      log_success "kubectx/kubens completions configured"
    fi

    # Configure Google Cloud SDK
    if [ -d "/opt/homebrew/Caskroom/google-cloud-sdk" ] || [ -d "/usr/local/Caskroom/google-cloud-sdk" ]; then
      log_info "Google Cloud SDK installed - shell integration will be configured via conf.d files"
    fi

    # Configure Helm
    if command -v helm &> /dev/null; then
      log_info "Generating Helm completions..."
      helm completion bash > ~/.config/bash/completions/helm.bash 2>/dev/null || true
      helm completion zsh > ~/.config/zsh/completions/_helm 2>/dev/null || true
      helm completion fish > ~/.config/fish/completions/helm.fish 2>/dev/null || true
      log_success "Helm completions generated"
    fi

    # Configure GitHub CLI
    if command -v gh &> /dev/null; then
      log_info "Generating GitHub CLI completions..."
      gh completion -s bash > ~/.config/bash/completions/gh.bash 2>/dev/null || true
      gh completion -s zsh > ~/.config/zsh/completions/_gh 2>/dev/null || true
      gh completion -s fish > ~/.config/fish/completions/gh.fish 2>/dev/null || true
      log_success "GitHub CLI completions generated"
    fi

    # Install Claude Code CLI
    log_info "Installing Claude Code CLI..."
    if command -v claude &> /dev/null; then
      log_success "Claude Code is already installed"
      # Note: claude-code doesn't have an update command built-in
      # Users need to reinstall to update
    else
      log_info "Installing Claude Code via official installer..."
      curl -fsSL https://claude.ai/install.sh | bash -s latest
      log_success "Claude Code installed successfully"
    fi

    # Install Bun using official installer
    log_info "Installing Bun..."
    if command -v bun &> /dev/null; then
      log_success "Bun is already installed"
      log_info "Updating Bun to latest version..."
      bun upgrade
    else
      log_info "Installing Bun via official installer..."
      curl -fsSL https://bun.sh/install | bash
      log_success "Bun installed successfully"
    fi
  fi

  printf "\n"
  print_color "$BOLD" "=== Configuring Shell ==="

  if [ "$dry_run" -eq 1 ]; then
    log_info "[DRY RUN] Would add Fish shell to /etc/shells"
    log_info "[DRY RUN] Would add Zsh to /etc/shells"
    log_info "[DRY RUN] Would create configuration directories"
    log_info "[DRY RUN] Would fix Zsh compinit insecure directory permissions"
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

    # Fix Zsh compinit insecure directories
    log_info "Fixing Zsh completion directory permissions..."

    # First, fix common Homebrew directories that often have permission issues
    # This handles "compinit: insecure directories" errors
    if [ -d /opt/homebrew ]; then
      # Apple Silicon Mac - fix parent directories first
      sudo chown -R $USER /opt/homebrew/share /opt/homebrew/share/zsh /opt/homebrew/share/zsh/site-functions || true
      chmod u+w /opt/homebrew/share /opt/homebrew/share/zsh /opt/homebrew/share/zsh/site-functions || true
    fi

    if [ -d /usr/local/share ]; then
      # Intel Mac - fix parent directories first
      sudo chown -R $USE /usr/local/share /usr/local/share/zsh /usr/local/share/zsh/site-functions || true
      chmod u+w /usr/local/share /usr/local/share/zsh /usr/local/share/zsh/site-functions || true
    fi

    # Fix user's Zsh directories
    if [ -d ~/.config/zsh ]; then
      chmod 755 ~/.config/zsh 2>/dev/null || true
      chmod 755 ~/.config/zsh/conf.d 2>/dev/null || true
      chmod 755 ~/.config/zsh/completions 2>/dev/null || true
    fi

    # Now run compaudit to find any remaining insecure directories
    if command -v zsh &> /dev/null; then
      log_info "Checking for insecure Zsh directories..."
      local insecure_dirs
      # Run compaudit through zsh to get the list of insecure directories
      insecure_dirs=$(zsh -c 'compaudit' 2>/dev/null || true)

      if [ -n "$insecure_dirs" ]; then
        log_warning "Found insecure directories, fixing permissions..."
        echo "$insecure_dirs" | while IFS= read -r dir; do
          if [ -n "$dir" ] && [ -d "$dir" ]; then
            # Use sudo for system directories, regular chmod for user directories
            if [[ "$dir" == /opt/* ]] || [[ "$dir" == /usr/* ]]; then
              sudo chown -R $USER "$dir" 2>/dev/null && \
              chmod u+w "$dir" 2>/dev/null && \
              log_success "Fixed permissions and ownership for: $dir" || log_warning "Could not fix: $dir"
            else
              sudo chown -R $USER "$dir" 2>/dev/null && log_success "Fixed permissions for: $dir" || log_warning "Could not fix: $dir"
            fi
          fi
        done

        # Verify the fix by running compaudit again
        local remaining_insecure
        remaining_insecure=$(zsh -c 'compaudit' 2>/dev/null || true)
        if [ -z "$remaining_insecure" ]; then
          log_success "All Zsh directories are now secure"
        else
          log_warning "Some directories may still need attention. Run 'compaudit' after installation to check."
        fi
      else
        log_success "All Zsh directories are already secure"
      fi
    fi

    # Create Bash config directories
    log_info "Creating Bash configuration directories..."
    mkdir -p ~/.config/bash/conf.d

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

    # Install configurations for all shells
    install_fish_config "$config_base" "$force_overwrite" "$dry_run"
    install_zsh_config "$config_base" "$force_overwrite" "$dry_run"
    install_bash_config "$config_base" "$force_overwrite" "$dry_run"

    # Install Starship for any shell choice
    install_starship_config "$config_base" "$force_overwrite" "$dry_run"

    # Install Ghostty terminal configuration
    install_ghostty_config "$config_base" "$force_overwrite" "$dry_run"

  else
    # Remote installation via curl
    log_info "Remote installation - downloading configurations from GitHub..."

    # Base URL for raw GitHub content
    local GITHUB_BASE="https://raw.githubusercontent.com/roderik/shell-config/main"

    if [ "$dry_run" -eq 1 ]; then
      log_info "[DRY RUN] Would download and install:"
      printf "  • Fish configuration and conf.d modules from GitHub\n"
      printf "  • Zsh configuration and conf.d modules from GitHub\n"
      printf "  • Bash configuration and conf.d modules from GitHub\n"
      printf "  • Starship configuration from GitHub\n"
      printf "  • Ghostty terminal configuration from GitHub\n"
    else
      # Download Fish configuration
      log_info "Downloading Fish configuration..."
      mkdir -p ~/.config/fish/conf.d

      # Main config
      if [ -f ~/.config/fish/config.fish ] && [ "$force_overwrite" -eq 0 ]; then
        backup_file ~/.config/fish/config.fish
      fi
      curl -sL "$GITHUB_BASE/config/fish/config.fish" -o ~/.config/fish/config.fish

      # Fish conf.d modules - listing all actual modules
      local FISH_MODULES=(
        "00-environment.fish"
        "00-homebrew.fish"
        "02-paths.fish"
        "10-aliases.fish"
        "10-node.fish"
        "11-1password.fish"
        "20-abbreviations.fish"
        "20-functions.fish"
        "20-fzf.fish"
        "30-abbreviations.fish"
        "30-functions.fish"
        "30-git-functions.fish"
        "31-docker-functions.fish"
        "32-claude-function.fish"
        "40-completions.fish"
        "60-modern-tools.fish"
        "70-prompt.fish"
        "80-gcloud.fish"
        "81-aws.fish"
        "82-azure.fish"
        "83-kubectl.fish"
        "84-tmux.fish"
        "85-uv.fish"
        "86-additional-tools.fish"
        "87-foundry.fish"
      )
      for module in "${FISH_MODULES[@]}"; do
        curl -sL "$GITHUB_BASE/config/fish/conf.d/$module" -o ~/.config/fish/conf.d/$module 2>/dev/null || true
      done
      log_success "Fish configuration and modules installed"

      # Download Zsh configuration
      log_info "Downloading Zsh configuration..."
      mkdir -p ~/.config/zsh/conf.d

      # Main .zshrc
      if [ -f ~/.zshrc ] && [ "$force_overwrite" -eq 0 ]; then
        backup_file ~/.zshrc
      fi
      curl -sL "$GITHUB_BASE/config/zsh/.zshrc" -o ~/.zshrc

      # Zsh conf.d modules
      local ZSH_MODULES=(
        "00-environment.zsh"
        "10-options.zsh"
        "20-completions.zsh"
        "30-aliases.zsh"
        "40-functions.zsh"
        "50-keybindings.zsh"
        "60-plugins.zsh"
      )
      for module in "${ZSH_MODULES[@]}"; do
        curl -sL "$GITHUB_BASE/config/zsh/conf.d/$module" -o ~/.config/zsh/conf.d/$module 2>/dev/null || true
      done
      log_success "Zsh configuration and modules installed"

      # Download Bash configuration
      log_info "Downloading Bash configuration..."
      mkdir -p ~/.config/bash/conf.d

      # Main .bashrc
      if [ -f ~/.bashrc ] && [ "$force_overwrite" -eq 0 ]; then
        backup_file ~/.bashrc
      fi
      curl -sL "$GITHUB_BASE/config/bash/.bashrc" -o ~/.bashrc

      # .bash_profile
      if [ -f ~/.bash_profile ] && [ "$force_overwrite" -eq 0 ]; then
        backup_file ~/.bash_profile
      fi
      curl -sL "$GITHUB_BASE/config/bash/.bash_profile" -o ~/.bash_profile

      # Bash conf.d modules - we need to list all actual bash modules
      local BASH_MODULES=(
        "00-environment.bash"
        "10-aliases.bash"
        "10-node.bash"
        "11-1password.bash"
        "12-direnv.bash"
        "13-gcloud.bash"
        "14-foundry.bash"
        "20-fzf.bash"
        "21-ssh-keys.bash"
        "30-modern-tools.bash"
        "31-navigation.bash"
        "32-claude-function.bash"
        "33-git-functions.bash"
        "40-network.bash"
        "50-keybindings.bash"
        "60-modern-tools.bash"
        "70-prompt.bash"
        "80-completion.bash"
      )
      for module in "${BASH_MODULES[@]}"; do
        curl -sL "$GITHUB_BASE/config/bash/conf.d/$module" -o ~/.config/bash/conf.d/$module 2>/dev/null || true
      done
      log_success "Bash configuration and modules installed"

      # Download Starship configuration
      log_info "Downloading Starship configuration..."
      if [ -f ~/.config/starship.toml ] && [ "$force_overwrite" -eq 0 ]; then
        backup_file ~/.config/starship.toml
      fi
      curl -sL "$GITHUB_BASE/config/starship/starship.toml" -o ~/.config/starship.toml
      log_success "Starship configuration installed"

      # Download Ghostty configuration (macOS specific)
      if [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "Downloading Ghostty configuration..."
        local ghostty_dir="$HOME/Library/Application Support/com.mitchellh.ghostty"
        mkdir -p "$ghostty_dir"

        local ghostty_config="$ghostty_dir/config"
        if [ -f "$ghostty_config" ] && [ "$force_overwrite" -eq 0 ]; then
          backup_file "$ghostty_config"
        fi
        curl -sL "$GITHUB_BASE/config/ghostty/config" -o "$ghostty_config"
        log_success "Ghostty configuration installed"
      fi
    fi
  fi

  sed "s/^#auth/auth/" /etc/pam.d/sudo_local.template | sudo tee /etc/pam.d/sudo_local

  # Create manifest for uninstall
  if [ "$dry_run" -eq 0 ]; then
    local manifest=~/.config/.shell-config-manifest.json
    cat > "$manifest" <<EOF
{
  "version": "1.0",
  "installed": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "shell": "fish,zsh,bash",
  "source": "$repo_root",
  "configurations": [
EOF

    echo '    "~/.config/fish/",' >> "$manifest"
    echo '    "~/.zshrc",' >> "$manifest"
    echo '    "~/.config/zsh/",' >> "$manifest"
    echo '    "~/.bashrc",' >> "$manifest"
    echo '    "~/.bash_profile",' >> "$manifest"
    echo '    "~/.config/bash/",' >> "$manifest"
    echo '    "~/.config/nvim/",' >> "$manifest"
    echo '    "~/.config/starship.toml",' >> "$manifest"
    echo '    "~/Library/Application Support/com.mitchellh.ghostty/config"' >> "$manifest"

    cat >> "$manifest" <<EOF
  ],
  "tools": [
    "starship", "bat", "eza", "ripgrep", "fd", "fzf",
    "lazygit", "lazydocker", "fnm", "direnv", "zoxide", "atuin",
    "bun", "foundry"
  ]
}
EOF
    log_success "Created manifest: $manifest"
  fi

  printf "\n"

  # Validate configuration
  print_color "$BOLD" "=== Validating Configuration ==="

  if [ "$dry_run" -eq 0 ]; then
    local validation_errors=0

    # Test Zsh configuration
    if command -v zsh &> /dev/null; then
      log_info "Validating Zsh configuration..."
      local zsh_test_output
      zsh_test_output=$(zsh -c 'source ~/.zshrc 2>&1' 2>&1)
      if [ $? -eq 0 ] && [ -z "$zsh_test_output" ]; then
        log_success "Zsh configuration is valid"
      else
        log_warning "Zsh configuration has issues:"
        echo "$zsh_test_output" | head -10
        validation_errors=$((validation_errors + 1))
      fi
    fi

    # Test Bash configuration
    if command -v bash &> /dev/null; then
      log_info "Validating Bash configuration..."
      local bash_test_output
      bash_test_output=$(bash -c 'source ~/.bashrc 2>&1' 2>&1)
      if [ $? -eq 0 ] && [[ ! "$bash_test_output" =~ "error" ]]; then
        log_success "Bash configuration is valid"
      else
        if [[ -n "$bash_test_output" ]] && [[ "$bash_test_output" =~ "error" ]]; then
          log_warning "Bash configuration has issues:"
          echo "$bash_test_output" | grep -i error | head -5
          validation_errors=$((validation_errors + 1))
        else
          log_success "Bash configuration is valid"
        fi
      fi
    fi

    # Test Fish configuration
    if command -v fish &> /dev/null; then
      log_info "Validating Fish configuration..."
      local fish_test_output
      fish_test_output=$(fish -c 'source ~/.config/fish/config.fish 2>&1' 2>&1)
      if [ $? -eq 0 ] && [[ ! "$fish_test_output" =~ "error" ]]; then
        log_success "Fish configuration is valid"
      else
        if [[ -n "$fish_test_output" ]] && [[ "$fish_test_output" =~ "error" ]]; then
          log_warning "Fish configuration has issues:"
          echo "$fish_test_output" | grep -i error | head -5
          validation_errors=$((validation_errors + 1))
        else
          log_success "Fish configuration is valid"
        fi
      fi
    fi

    # Check for common issues
    if command -v zsh &> /dev/null; then
      log_info "Checking for Zsh compinit issues..."
      local compaudit_output
      compaudit_output=$(zsh -c 'compaudit' 2>&1)
      if [ -z "$compaudit_output" ]; then
        log_success "No insecure directories found"
      else
        log_warning "Insecure directories still exist:"
        echo "$compaudit_output"
        log_info "Run 'sudo chmod 755' on the directories listed above"
        validation_errors=$((validation_errors + 1))
      fi
    fi

    if [ $validation_errors -eq 0 ]; then
      log_success "All configurations validated successfully!"
    else
      log_warning "Some configuration issues were detected. They may not affect normal usage."
      log_info "You can check the messages above for details."
    fi
  fi

  printf "\n"

  # Success message
  print_color "$BOLD$GREEN" "╔════════════════════════════════════════╗"
  print_color "$BOLD$GREEN" "║     ${ROCKET} Installation Complete! ${ROCKET}      ║"
  print_color "$BOLD$GREEN" "╚════════════════════════════════════════╝"
  printf "\n"

  log_success "Shell configuration has been successfully installed!"
  printf "\n"

  # Show instructions for all shells
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
  print_color "$BOLD" "For Bash:"
  printf "  • Start a new session: ${YELLOW}bash${NC}\n"
  printf "  • Make it default: ${YELLOW}chsh -s /bin/bash${NC}\n"
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
  printf "  • bun        - Fast JavaScript runtime & toolkit\n"
  printf "  • And more!\n"
  printf "\n"

  print_color "$CYAN" "Configuration files installed:"
  printf "  • ~/.config/fish/config.fish\n"
  printf "  • ~/.config/fish/conf.d/ (Fish modular configuration)\n"
  printf "  • ~/.zshrc\n"
  printf "  • ~/.config/zsh/conf.d/ (Zsh modular configuration)\n"
  printf "  • ~/.bashrc\n"
  printf "  • ~/.bash_profile\n"
  printf "  • ~/.config/bash/conf.d/ (Bash modular configuration)\n"
  printf "  • ~/.config/nvim/ (LazyVim configuration)\n"
  printf "  • ~/.config/starship.toml\n"
  printf "  • ~/Library/Application Support/com.mitchellh.ghostty/config\n"
  printf "\n"

  log_info "To uninstall, run: ./uninstall.sh"
}

# Run main function
main "$@"