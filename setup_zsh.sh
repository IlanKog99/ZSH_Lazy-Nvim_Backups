#!/bin/bash

# ZSH Setup Script - Automated installation of your exact ZSH configuration
# This script will install all dependencies and set up your ZSH environment
#
# PREREQUISITES (must be installed before running this script):
#   - git (for cloning repositories and plugin management)
#   - curl (for downloading dependencies)
#   - sudo access (for installing system packages)
#
# IMPORTANT FOR ARCH LINUX USERS:
#   - This script does NOT perform a full system upgrade (pacman -Syu) to avoid
#     potential system bricking if interrupted or if disk space is insufficient.
#   - You should update your Arch system manually BEFORE running this script:
#     sudo pacman -Syu
#   - The script will check for sufficient disk space (2GB minimum) before
#     installing packages on Arch Linux.
#
# All other dependencies (zsh, neofetch/fastfetch, neovim, lolcat, etc.) will be 
# automatically installed by this script. The script automatically selects
# neofetch or fastfetch based on distribution support.

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check available disk space
check_disk_space() {
    local required_gb=${1:-2}  # Default to 2GB if not specified
    local available_kb
    
    # Get available space in KB (works on Linux)
    # Use -k flag to force 1KB blocks, avoiding POSIXLY_CORRECT 512-byte block issue
    if command_exists df; then
        available_kb=$(df -k / | tail -1 | awk '{print $4}')
        if [ -z "$available_kb" ]; then
            print_warning "Could not determine available disk space, skipping check"
            return 0
        fi
        
        # Convert KB to GB (approximately)
        local available_gb=$((available_kb / 1024 / 1024))
        
        if [ "$available_gb" -lt "$required_gb" ]; then
            print_error "Insufficient disk space: ${available_gb}GB available, ${required_gb}GB required"
            print_error "Please free up disk space before continuing"
            return 1
        else
            print_status "Disk space check passed: ${available_gb}GB available"
            return 0
        fi
    else
        print_warning "df command not found, skipping disk space check"
        return 0
    fi
}

# Function to determine which fetch tool to use based on distribution
determine_fetch_tool() {
    print_status "Determining which system info tool to use..."
    
    if command_exists pacman; then
        # Arch Linux - use fastfetch
        FETCH_TOOL="fastfetch"
        print_status "Arch Linux detected: using fastfetch"
    else
        # All other distributions - use neofetch
        FETCH_TOOL="neofetch"
        if command_exists apt; then
            print_status "Debian/Ubuntu detected: using neofetch"
        elif command_exists dnf; then
            print_status "Fedora detected: using neofetch"
        elif command_exists yum; then
            print_status "RHEL/CentOS detected: using neofetch"
        elif command_exists zypper; then
            print_status "openSUSE detected: using neofetch"
        else
            print_status "Unknown distribution: defaulting to neofetch"
        fi
    fi
    
    print_success "Will use $FETCH_TOOL for system information display"
}

# Function to install lolcat with fallback methods
install_lolcat() {
    print_status "Installing lolcat..."
    
    # Check if already installed
    if command_exists lolcat; then
        print_success "lolcat is already installed"
        return 0
    fi
    
    # Try installing via package manager first
    local installed=false
    
    if command_exists apt; then
        if sudo apt install -y lolcat 2>/dev/null; then
            installed=true
        fi
    elif command_exists yum; then
        # Try EPEL repository first for RHEL/CentOS
        if ! rpm -q epel-release >/dev/null 2>&1; then
            print_status "EPEL repository not found, attempting to install..."
            if sudo yum install -y epel-release 2>/dev/null; then
                print_success "EPEL repository installed"
            fi
        fi
        if sudo yum install -y lolcat 2>/dev/null; then
            installed=true
        fi
    elif command_exists dnf; then
        # Try EPEL repository first for RHEL-based distros (AlmaLinux, Rocky Linux)
        if command_exists rpm; then
            if ! rpm -q epel-release >/dev/null 2>&1; then
                print_status "EPEL repository not found, attempting to install..."
                if sudo dnf install -y epel-release 2>/dev/null; then
                    print_success "EPEL repository installed"
                fi
            fi
        fi
        if sudo dnf install -y lolcat 2>/dev/null; then
            installed=true
        fi
    elif command_exists pacman; then
        if sudo pacman -S --needed --noconfirm lolcat 2>/dev/null; then
            installed=true
        fi
    elif command_exists zypper; then
        if sudo zypper install -y lolcat 2>/dev/null; then
            installed=true
        fi
    fi
    
    # If package manager installation succeeded, verify
    if [ "$installed" = true ] && command_exists lolcat; then
        print_success "lolcat installed via package manager"
        return 0
    fi
    
    # Fallback: Try installing via Ruby gem
    print_warning "lolcat not available in package repositories, trying Ruby gem..."
    if command_exists gem; then
        if gem install lolcat 2>/dev/null; then
            # Ensure gem bin directory is in PATH
            # Find the actual Ruby gem bin path
            if command_exists gem; then
                local gem_bin_path=$(gem env gemdir 2>/dev/null)/bin
                if [ -n "$gem_bin_path" ] && [ -d "$gem_bin_path" ]; then
                    export PATH="$gem_bin_path:$PATH"
                fi
            fi
            # Reload PATH and check if lolcat is now available
            hash -r 2>/dev/null || true
            if command_exists lolcat; then
                print_success "lolcat installed via Ruby gem"
                return 0
            fi
        fi
    else
        # Try installing Ruby and then gem
        print_status "Ruby not found, attempting to install Ruby..."
        local ruby_installed=false
        if command_exists apt; then
            if sudo apt install -y ruby ruby-dev 2>/dev/null; then
                ruby_installed=true
            fi
        elif command_exists yum; then
            if sudo yum install -y ruby ruby-devel 2>/dev/null; then
                ruby_installed=true
            fi
        elif command_exists dnf; then
            if sudo dnf install -y ruby ruby-devel 2>/dev/null; then
                ruby_installed=true
            fi
        elif command_exists pacman; then
            if sudo pacman -S --needed --noconfirm ruby 2>/dev/null; then
                ruby_installed=true
            fi
        elif command_exists zypper; then
            if sudo zypper install -y ruby ruby-devel 2>/dev/null; then
                ruby_installed=true
            fi
        fi
        
        if [ "$ruby_installed" = true ] && command_exists gem; then
            if gem install lolcat 2>/dev/null; then
                # Ensure gem bin directory is in PATH
                if command_exists gem; then
                    local gem_bin_path=$(gem env gemdir 2>/dev/null)/bin
                    if [ -n "$gem_bin_path" ] && [ -d "$gem_bin_path" ]; then
                        export PATH="$gem_bin_path:$PATH"
                    fi
                fi
                # Reload PATH and check if lolcat is now available
                hash -r 2>/dev/null || true
                if command_exists lolcat; then
                    print_success "lolcat installed via Ruby gem"
                    return 0
                fi
            fi
        fi
    fi
    
    # If all methods failed, make it optional
    print_warning "Could not install lolcat via package manager or Ruby gem"
    print_warning "lolcat is optional - your ZSH setup will work without it"
    print_warning "You can install it manually later with: gem install lolcat"
    print_warning "Or visit: https://github.com/busyloop/lolcat"
    return 1
}

# Function to install packages based on distro
install_packages() {
    print_status "Detecting package manager and installing dependencies..."
    
    # Ensure FETCH_TOOL is set
    if [ -z "$FETCH_TOOL" ]; then
        determine_fetch_tool
    fi
    
    # Temporarily disable exit on error to handle package installation failures gracefully
    set +e
    
    if command_exists apt; then
        # Debian/Ubuntu
        print_status "Using apt package manager (Debian/Ubuntu)"
        sudo apt update
        sudo apt install -y zsh "$FETCH_TOOL" neovim build-essential
    elif command_exists yum; then
        # RHEL/CentOS/Fedora
        print_status "Using yum package manager (RHEL/CentOS/Fedora)"
        sudo yum update -y
        sudo yum install -y zsh "$FETCH_TOOL" neovim gcc gcc-c++ make
    elif command_exists dnf; then
        # Fedora/RHEL-based (AlmaLinux, Rocky Linux)
        print_status "Using dnf package manager (Fedora/RHEL-based)"
        sudo dnf update -y
        sudo dnf install -y zsh "$FETCH_TOOL" neovim gcc gcc-c++ make
    elif command_exists pacman; then
        # Arch Linux
        # NOTE: We use -S (not -Syu) to avoid full system upgrade which can brick
        # the system if interrupted or if disk space is insufficient. Users should
        # update their system manually with 'sudo pacman -Syu' before running this script.
        print_status "Using pacman package manager (Arch Linux)"
        print_warning "For Arch Linux, ensure your system is up to date before running this script"
        print_warning "Run 'sudo pacman -Syu' manually if needed"
        
        # Check disk space before installing (critical for Arch)
        if ! check_disk_space 2; then
            print_error "Disk space check failed. Aborting package installation."
            exit 1
        fi
        
        sudo pacman -S --needed --noconfirm zsh "$FETCH_TOOL" neovim base-devel
    elif command_exists zypper; then
        # openSUSE
        print_status "Using zypper package manager (openSUSE)"
        sudo zypper refresh
        sudo zypper install -y zsh "$FETCH_TOOL" neovim gcc gcc-c++ make
    else
        print_error "Unsupported package manager. Please install zsh, $FETCH_TOOL, and neovim manually."
        set -e
        exit 1
    fi
    
    local package_install_status=$?
    set -e  # Re-enable exit on error
    
    # Check if core packages were installed successfully
    if [ $package_install_status -ne 0 ]; then
        print_error "Failed to install core packages. Please check your package manager and try again."
        exit 1
    fi
    
    print_success "Core packages installed successfully"
    
    # Install lolcat separately (optional, won't fail the script)
    install_lolcat || true
}

# Function to install fzf
install_fzf() {
    print_status "Installing fzf (fuzzy finder)..."
    
    if [ -d "$HOME/.fzf" ]; then
        print_warning "fzf already exists, updating..."
        cd "$HOME/.fzf" && git pull
    else
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    fi
    
    # Install fzf
    "$HOME/.fzf/install" --key-bindings --completion --no-update-rc
    
    print_success "fzf installed successfully"
}

# Function to install zoxide
install_zoxide() {
    print_status "Installing zoxide (smart directory navigation)..."
    
    if command_exists zoxide; then
        print_warning "zoxide already installed"
        return 0
    fi
    
    # Install zoxide using the official installer
    if curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash; then
        # Verify installation by checking if zoxide is now available
        # The installer typically adds zoxide to ~/.local/bin or /usr/local/bin
        # We need to ensure the PATH includes these locations
        export PATH="$HOME/.local/bin:$PATH"
        
        # Wait a moment for PATH to be updated
        sleep 1
        
        if command_exists zoxide; then
            print_success "zoxide installed successfully"
            return 0
        else
            print_warning "zoxide installer completed but zoxide command not found in PATH"
            print_warning "You may need to add ~/.local/bin to your PATH or restart your terminal"
            print_warning "Try running: export PATH=\"\$HOME/.local/bin:\$PATH\""
            return 1
        fi
    else
        print_error "Failed to install zoxide"
        print_warning "You can install it manually with: curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash"
        return 1
    fi
}

# Function to install Nerd Font
install_nerd_font() {
    print_status "Installing Nerd Font for Powerlevel10k icons..."
    
    # Try to install via package manager first
    if command_exists apt; then
        # Try to install FiraCode Nerd Font
        if sudo apt install -y fonts-firacode 2>/dev/null; then
            print_success "FiraCode Nerd Font installed via apt"
            return
        fi
    elif command_exists dnf; then
        # Try to install via dnf
        if sudo dnf install -y fira-code-fonts 2>/dev/null; then
            print_success "FiraCode Nerd Font installed via dnf"
            return
        fi
    fi
    
    # Manual installation if package manager fails
    print_warning "Installing Nerd Font manually..."
    
    # Check if unzip is available
    if ! command_exists unzip; then
        print_warning "unzip not found, attempting to install..."
        if command_exists apt; then
            sudo apt install -y unzip
        elif command_exists dnf; then
            sudo dnf install -y unzip
        elif command_exists yum; then
            sudo yum install -y unzip
        elif command_exists pacman; then
            sudo pacman -S --noconfirm unzip
        elif command_exists zypper; then
            sudo zypper install -y unzip
        else
            print_error "Could not install unzip. Please install it manually to get Nerd Fonts."
            return 1
        fi
    fi
    
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
    
    # Download and install FiraCode Nerd Font using curl (required prerequisite)
    cd /tmp
    curl -fLo FiraCode.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
    unzip -q FiraCode.zip -d fira-code
    cp fira-code/*.ttf "$FONT_DIR/"
    rm -rf fira-code FiraCode.zip
    
    # Update font cache
    fc-cache -fv "$FONT_DIR" 2>/dev/null || true
    
    print_success "FiraCode Nerd Font installed manually"
    print_warning "You may need to restart your terminal or set the font manually in your terminal settings"
}

# Function to create .zshrc
create_zshrc() {
    print_status "Setting up .zshrc configuration..."
    
    # Check if .zshrc exists in script directory
    if [ -f "$SCRIPT_DIR/.zshrc" ]; then
        cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
        print_success ".zshrc copied from script directory"
    else
        print_error "No .zshrc found in script directory!"
        print_error "Please ensure .zshrc is in the same directory as this script."
        print_error "You can download it from: https://github.com/IlanKog99/ZSH_Lazy-Nvim_Backups"
        exit 1
    fi
}

# Function to update .zshrc with the correct fetch tool
update_zshrc_fetch_tool() {
    print_status "Updating .zshrc to use $FETCH_TOOL..."
    
    # Ensure FETCH_TOOL is set
    if [ -z "$FETCH_TOOL" ]; then
        print_error "FETCH_TOOL is not set. Cannot update .zshrc."
        return 1
    fi
    
    # Replace fastfetch with the determined tool in .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        # Use sed to replace all instances of fastfetch with the determined tool
        if sed -i "s/fastfetch/$FETCH_TOOL/g" "$HOME/.zshrc" 2>/dev/null; then
            print_success ".zshrc updated to use $FETCH_TOOL"
        else
            # Fallback for systems without GNU sed (macOS uses BSD sed)
            if sed -i '' "s/fastfetch/$FETCH_TOOL/g" "$HOME/.zshrc" 2>/dev/null; then
                print_success ".zshrc updated to use $FETCH_TOOL"
            else
                print_warning "Could not automatically update .zshrc. Please manually replace 'fastfetch' with '$FETCH_TOOL' in ~/.zshrc"
                return 1
            fi
        fi
    else
        print_error ".zshrc not found at $HOME/.zshrc"
        return 1
    fi
}

# Function to create .p10k.zsh
create_p10k_config() {
    print_status "Setting up Powerlevel10k configuration..."
    
    # Check if .p10k.zsh exists in script directory
    if [ -f "$SCRIPT_DIR/.p10k.zsh" ]; then
        cp "$SCRIPT_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
        print_success ".p10k.zsh copied from script directory"
    else
        print_error "No .p10k.zsh found in script directory!"
        print_error "Please ensure .p10k.zsh is in the same directory as this script."
        print_error "You can download it from: https://github.com/IlanKog99/ZSH_Lazy-Nvim_Backups"
        exit 1
    fi
}

# Function to set zsh as default shell
set_default_shell() {
    print_status "Setting ZSH as default shell..."
    
    ZSH_PATH=$(which zsh)
    if [ -z "$ZSH_PATH" ]; then
        print_error "ZSH not found in PATH"
        return 1
    fi
    
    # Check if zsh is already the default shell
    if [ "$SHELL" = "$ZSH_PATH" ]; then
        print_warning "ZSH is already the default shell"
        return 0
    fi
    
    # Add zsh to /etc/shells if not present
    if ! grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi
    
    # Change default shell
    chsh -s "$ZSH_PATH"
    print_success "ZSH set as default shell"
    print_warning "You may need to log out and log back in for the changes to take effect"
}

# Function to create necessary directories
create_directories() {
    print_status "Creating necessary directories..."
    
    mkdir -p "$HOME/.cache"
    mkdir -p "$HOME/.local/share"
    mkdir -p "$HOME/.config"
    
    print_success "Directories created successfully"
}

# Main installation function
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    ZSH Setup Script - Automated Install${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    # Check if running as root
    if [ "$EUID" -eq 0 ]; then
        print_warning "Running as root user detected."
        print_warning "This is not recommended for regular desktop systems."
        print_warning "If this is a container or minimal system, you can continue."
        print_status "Press Ctrl+C to cancel, or Enter to continue..."
        read -r
    fi
    
    # Check for required commands
    if ! command_exists git; then
        print_error "Git is required but not installed. Please install git first."
        exit 1
    fi
    
    if ! command_exists curl; then
        print_error "curl is required but not installed. Please install curl first."
        exit 1
    fi
    
    # Start installation
    create_directories
    determine_fetch_tool
    install_packages
    install_fzf
    if ! install_zoxide; then
        print_warning "zoxide installation had issues, but continuing..."
        print_warning "You may need to manually install zoxide or add ~/.local/bin to your PATH"
    fi
    install_nerd_font
    create_zshrc
    if ! update_zshrc_fetch_tool; then
        print_error "Failed to update .zshrc with the correct fetch tool."
        print_error "Please manually replace 'fastfetch' with '$FETCH_TOOL' in ~/.zshrc"
        exit 1
    fi
    create_p10k_config
    set_default_shell
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}    Installation Complete!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Log out and log back in (or restart your terminal)"
    echo "2. Make sure your terminal is using a Nerd Font for proper icon display"
    echo ""
    echo -e "${BLUE}Your ZSH setup includes:${NC}"
    echo "• Powerlevel10k theme with lean prompt"
    echo "• Zinit plugin manager"
    echo "• Syntax highlighting and autosuggestions"
    echo "• fzf fuzzy finder integration"
    echo "• zoxide smart directory navigation"
    echo "• Custom aliases and keybindings"
    echo "• $FETCH_TOOL on startup"
    echo "• lolcat for colorful terminal output"
    echo ""
    echo -e "${YELLOW}Cleanup (optional):${NC}"
    echo "You can now delete the downloaded files:"
    echo "  rm -rf ZSH_Lazy-Nvim_Backups/"
    echo ""
    echo -e "${GREEN}Enjoy your new ZSH setup!${NC}"
}

# Run main function
main "$@"

