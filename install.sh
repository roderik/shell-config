#!/usr/bin/env bash

set -euo pipefail

# Shell Configuration installer for Fish Shell and modern development tools
# Installs and configures Fish shell, Starship prompt, and modern CLI tools

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

Installs modern shell configuration for Fish shell and development tools.

Options:
  --force          Overwrite existing configurations
  --dry-run        Show what would be done without making changes
  -h, --help       Show this help message

Configuration is installed to:
  - ~/.config/fish/
  - ~/.config/starship/
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
  if [[ "$ARCH" == "arm64" ]]; then
    BREW_PATH="/opt/homebrew/bin/brew"
    FISH_PATH="/opt/homebrew/bin/fish"
  else
    BREW_PATH="/usr/local/bin/brew"
    FISH_PATH="/usr/local/bin/fish"
  fi
  
  # Detect source directory
  local repo_root
  repo_root=$(script_dir)
  local config_base="$repo_root/config"
  
  print_color "$BOLD" "=== Installing Homebrew & Development Tools ==="
  
  if [ "$dry_run" -eq 1 ]; then
    log_info "[DRY RUN] Would check/install Homebrew at: $BREW_PATH"
    log_info "[DRY RUN] Would install the following tools:"
    printf "  • fish       - Friendly interactive shell\n"
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
      "fish"           # Fish shell
      "starship"       # Modern prompt
      "bat"            # Better cat
      "chafa"          # Terminal graphics
      "hexyl"          # Hex viewer
      "fd"             # Better find
      "ripgrep"        # Better grep
      "git-delta"      # Better git diff
      "procs"          # Better ps
      "broot"          # Better tree
      "nvim"           # Neovim
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
  print_color "$BOLD" "=== Configuring Fish Shell ==="
  
  if [ "$dry_run" -eq 1 ]; then
    log_info "[DRY RUN] Would add Fish shell to /etc/shells"
    log_info "[DRY RUN] Would create configuration directories:"
    printf "  • ~/.config/fish/\n"
    printf "  • ~/.config/starship/\n"
    printf "\n"
  else
    # Add Fish to allowed shells
    if grep -q "$FISH_PATH" /etc/shells; then
      log_success "Fish shell is already in /etc/shells"
    else
      log_info "Adding Fish to allowed shells (requires sudo)..."
      echo "$FISH_PATH" | sudo tee -a /etc/shells > /dev/null
      log_success "Fish shell added to /etc/shells"
    fi
    
    # Create config directories
    log_info "Creating configuration directories..."
    mkdir -p ~/.config/fish
    mkdir -p ~/.config/starship
  fi
  
  printf "\n"
  print_color "$BOLD" "=== Installing Configuration Files ==="
  
  # Detect if running from local directory or curl
  if [[ -n "${BASH_SOURCE[0]:-}" ]] && [[ -f "$config_base/fish/config.fish" ]]; then
    # Local installation
    log_info "Local installation detected"
    
    if [ "$dry_run" -eq 1 ]; then
      log_info "[DRY RUN] Would install the following configuration files:"
      printf "\n"
      
      # Fish configuration
      if [ -f "$config_base/fish/config.fish" ]; then
        local target_file=~/.config/fish/config.fish
        if [ -f "$target_file" ]; then
          print_color "$YELLOW" "  ⚠️  config.fish (already exists - showing diff):"
          if command -v delta >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$config_base/fish/config.fish" 2>/dev/null | \
              delta --no-gitconfig \
                    --paging=never \
                    --line-numbers \
                    --syntax-theme="Dracula" \
                    --width="${COLUMNS:-120}" \
                    --max-line-length=512 \
                    --diff-so-fancy 2>/dev/null || true
          elif command -v diff >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$config_base/fish/config.fish" 2>/dev/null | head -20 | while IFS= read -r line; do
              case "$line" in
                +*) print_color "$GREEN" "    $line" ;;
                -*) print_color "$RED" "    $line" ;;
                @*) print_color "$CYAN" "    $line" ;;
                *) echo "    $line" ;;
              esac
            done
          fi
        else
          print_color "$GREEN" "  + config.fish (new file)"
          print_color "$CYAN" "    Preview (first 10 lines):"
          head -10 "$config_base/fish/config.fish" | sed 's/^/      /'
        fi
        printf "\n"
      fi
      
      # Fish conf.d modules
      if [ -d "$config_base/fish/conf.d" ]; then
        print_color "$BOLD" "  📁 Fish configuration modules → ~/.config/fish/conf.d/"
        printf "\n"
        
        find "$config_base/fish/conf.d" -name "*.fish" -type f | sort | while read conf_file; do
          local conf_name=$(basename "$conf_file")
          local target_file=~/.config/fish/conf.d/"$conf_name"
          
          if [ -f "$target_file" ]; then
            print_color "$YELLOW" "    ⚠️  $conf_name (already exists - showing diff):"
            if command -v delta >/dev/null 2>&1; then
              diff -u --label "current" --label "new" "$target_file" "$conf_file" 2>/dev/null | \
                delta --no-gitconfig \
                      --paging=never \
                      --syntax-theme="Dracula" \
                      --width="${COLUMNS:-120}" \
                      --max-line-length=512 2>/dev/null || true
            elif command -v diff >/dev/null 2>&1; then
              diff -u --label "current" --label "new" "$target_file" "$conf_file" 2>/dev/null | head -15 | while IFS= read -r line; do
                case "$line" in
                  +*) print_color "$GREEN" "      $line" ;;
                  -*) print_color "$RED" "      $line" ;;
                  @*) print_color "$CYAN" "      $line" ;;
                  *) echo "      $line" ;;
                esac
              done
            fi
          else
            print_color "$GREEN" "    + $conf_name (new file)"
          fi
        done
        printf "\n"
      fi
      
      # Starship configuration
      if [ -f "$config_base/starship/starship.toml" ]; then
        local target_file=~/.config/starship.toml
        if [ -f "$target_file" ]; then
          print_color "$YELLOW" "  ⚠️  starship.toml (already exists - showing diff):"
          if command -v delta >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$config_base/starship/starship.toml" 2>/dev/null | \
              delta --no-gitconfig \
                    --paging=never \
                    --line-numbers \
                    --syntax-theme="Dracula" \
                    --width="${COLUMNS:-120}" \
                    --max-line-length=512 \
                    --diff-so-fancy 2>/dev/null || true
          elif command -v diff >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$config_base/starship/starship.toml" 2>/dev/null | head -20 | while IFS= read -r line; do
              case "$line" in
                +*) print_color "$GREEN" "    $line" ;;
                -*) print_color "$RED" "    $line" ;;
                @*) print_color "$CYAN" "    $line" ;;
                *) echo "    $line" ;;
              esac
            done
          fi
        else
          print_color "$GREEN" "  + starship.toml (new file)"
          print_color "$CYAN" "    Preview (first 10 lines):"
          head -10 "$config_base/starship/starship.toml" | sed 's/^/      /'
        fi
        printf "\n"
      fi
      
    else
      # Copy Fish configuration
      if [ -f "$config_base/fish/config.fish" ]; then
        local target_file=~/.config/fish/config.fish
        if [ -f "$target_file" ]; then
          if [ "$force_overwrite" -eq 0 ]; then
            backup_file "$target_file"
          fi
          
          # Show diff before copying
          print_color "$YELLOW" "Updating config.fish (showing changes):"
          if command -v delta >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$config_base/fish/config.fish" 2>/dev/null | \
              delta --no-gitconfig \
                    --paging=never \
                    --syntax-theme="Dracula" \
                    --width="${COLUMNS:-120}" \
                    --max-line-length=512 2>/dev/null || true
          elif command -v diff >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$config_base/fish/config.fish" 2>/dev/null | head -20 | while IFS= read -r line; do
              case "$line" in
                +*) print_color "$GREEN" "  $line" ;;
                -*) print_color "$RED" "  $line" ;;
                @*) print_color "$CYAN" "  $line" ;;
                *) echo "  $line" ;;
              esac
            done
          fi
        fi
        cp "$config_base/fish/config.fish" "$target_file"
        log_success "Fish configuration installed"
      fi
      
      # Copy Fish conf.d modules
      if [ -d "$config_base/fish/conf.d" ]; then
        mkdir -p ~/.config/fish/conf.d
        log_info "Installing Fish configuration modules..."
        
        # Iterate through conf.d files
        find "$config_base/fish/conf.d" -name "*.fish" -type f | sort | while read conf_file; do
          local conf_name=$(basename "$conf_file")
          local target_file=~/.config/fish/conf.d/"$conf_name"
          
          if [ -f "$target_file" ]; then
            if [ "$force_overwrite" -eq 0 ]; then
              backup_file "$target_file"
            fi
            
            # Show diff before copying
            print_color "$YELLOW" "  Updating $conf_name (showing changes):"
            if command -v delta >/dev/null 2>&1; then
              diff -u --label "current" --label "new" "$target_file" "$conf_file" 2>/dev/null | \
                delta --no-gitconfig \
                      --paging=never \
                      --syntax-theme="Dracula" \
                      --width="${COLUMNS:-120}" \
                      --max-line-length=512 2>/dev/null || true
            elif command -v diff >/dev/null 2>&1; then
              diff -u --label "current" --label "new" "$target_file" "$conf_file" 2>/dev/null | head -15 | while IFS= read -r line; do
                case "$line" in
                  +*) print_color "$GREEN" "    $line" ;;
                  -*) print_color "$RED" "    $line" ;;
                  @*) print_color "$CYAN" "    $line" ;;
                  *) echo "    $line" ;;
                esac
              done
            fi
          fi
          
          cp "$conf_file" "$target_file"
          log_success "  → $conf_name installed"
        done
      fi
      
      # Copy Starship configuration
      if [ -f "$config_base/starship/starship.toml" ]; then
        local target_file=~/.config/starship.toml
        if [ -f "$target_file" ]; then
          if [ "$force_overwrite" -eq 0 ]; then
            backup_file "$target_file"
          fi
          
          # Show diff before copying
          print_color "$YELLOW" "Updating starship.toml (showing changes):"
          if command -v delta >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$config_base/starship/starship.toml" 2>/dev/null | \
              delta --no-gitconfig \
                    --paging=never \
                    --syntax-theme="Dracula" \
                    --width="${COLUMNS:-120}" \
                    --max-line-length=512 2>/dev/null || true
          elif command -v diff >/dev/null 2>&1; then
            diff -u --label "current" --label "new" "$target_file" "$config_base/starship/starship.toml" 2>/dev/null | head -20 | while IFS= read -r line; do
              case "$line" in
                +*) print_color "$GREEN" "  $line" ;;
                -*) print_color "$RED" "  $line" ;;
                @*) print_color "$CYAN" "  $line" ;;
                *) echo "  $line" ;;
              esac
            done
          fi
        fi
        cp "$config_base/starship/starship.toml" "$target_file"
        log_success "Starship configuration installed"
      fi
      
    fi
  else
    # Remote installation via curl
    log_info "Remote installation - downloading configurations..."
    
    # Base URL for raw GitHub content
    local GITHUB_BASE="https://raw.githubusercontent.com/roderik/shell-config/main"
    
    if [ "$dry_run" -eq 1 ]; then
      log_info "[DRY RUN] Would download and install:"
      printf "  • Fish configuration from GitHub\n"
      printf "  • Starship configuration from GitHub\n"
    else
      # Download Fish configuration
      log_info "Downloading Fish configuration..."
      if [ -f ~/.config/fish/config.fish ] && [ "$force_overwrite" -eq 0 ]; then
        backup_file ~/.config/fish/config.fish
      fi
      if curl -sL "$GITHUB_BASE/config/fish/config.fish" -o ~/.config/fish/config.fish; then
        log_success "Fish configuration installed"
      else
        log_error "Failed to download Fish configuration"
        exit 1
      fi
      
      # Download Starship configuration
      log_info "Downloading Starship configuration..."
      if [ -f ~/.config/starship.toml ] && [ "$force_overwrite" -eq 0 ]; then
        backup_file ~/.config/starship.toml
      fi
      if curl -sL "$GITHUB_BASE/config/starship/starship.toml" -o ~/.config/starship.toml; then
        log_success "Starship configuration installed"
      else
        log_error "Failed to download Starship configuration"
        exit 1
      fi
      
    fi
  fi
  
  # Create manifest for uninstall
  if [ "$dry_run" -eq 0 ]; then
    local manifest=~/.config/fish/.shell-config-manifest.json
    cat > "$manifest" <<EOF
{
  "version": "1.0",
  "installed": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "source": "$repo_root",
  "configurations": [
    "~/.config/fish/config.fish",
    "~/.config/fish/conf.d/",
    "~/.config/starship.toml"
  ],
  "tools": [
    "fish", "starship", "bat", "eza", "ripgrep", "fd", "fzf",
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
  
  # Show instructions
  print_color "$CYAN" "To start using Fish shell:"
  printf "  1. Change your default shell:\n"
  printf "     ${YELLOW}chsh -s $FISH_PATH${NC}\n"
  printf "\n"
  printf "  2. Start a new Fish shell session:\n"
  printf "     ${YELLOW}$FISH_PATH${NC}\n"
  printf "\n"
  
  print_color "$CYAN" "Installed tools:"
  printf "  • fish       - Friendly interactive shell\n"
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
  printf "  • ~/.config/fish/conf.d/ (modular configuration)\n"
  printf "  • ~/.config/starship.toml\n"
  printf "\n"
  
  log_info "To uninstall, run: ./uninstall.sh"
}

# Run main function
main "$@"