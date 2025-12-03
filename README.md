# ZSH & LazyVim Configuration Setup

A complete, automated setup for both ZSH and LazyVim configurations, providing a professional development environment with Powerlevel10k, Zinit plugin manager, LazyVim distribution, and essential productivity tools.

## 🚀 Quick Installation

### Install Both (Recommended)
```bash
git clone https://github.com/IlanKog99/ZSH_Lazy-Nvim_Backups.git && cd ZSH_Lazy-Nvim_Backups && chmod +x setup_zsh.sh setup_lazyvim.sh && ./setup_zsh.sh && ./setup_lazyvim.sh && cd .. && rm -rf ZSH_Lazy-Nvim_Backups
```

### Install ZSH Only
```bash
git clone https://github.com/IlanKog99/ZSH_Lazy-Nvim_Backups.git && cd ZSH_Lazy-Nvim_Backups && chmod +x setup_zsh.sh && ./setup_zsh.sh && cd .. && rm -rf ZSH_Lazy-Nvim_Backups
```

### Install LazyVim Only
```bash
git clone https://github.com/IlanKog99/ZSH_Lazy-Nvim_Backups.git && cd ZSH_Lazy-Nvim_Backups && chmod +x setup_lazyvim.sh && ./setup_lazyvim.sh && cd .. && rm -rf ZSH_Lazy-Nvim_Backups
```

## 📦 What's Included

### ZSH Configuration
- **Powerlevel10k** - Beautiful, fast ZSH theme with lean prompt style
- **Zinit** - Lightning-fast ZSH plugin manager
- **Syntax Highlighting** - Command syntax highlighting
- **Auto-suggestions** - Intelligent command suggestions
- **fzf Integration** - Fuzzy finder for files and history
- **zoxide** - Smart directory navigation
- **Custom Aliases** - Productivity shortcuts
- **neofetch/fastfetch** - System information on startup (neofetch on most distros, fastfetch on Arch Linux)
- **lolcat** - Colorful terminal output

### LazyVim Configuration
- **LazyVim** - Modern Neovim distribution with sensible defaults
- **Custom Keybindings** - Productivity-focused keyboard shortcuts
- **Automated Installation** - One-command setup script
- **Multi-Distribution Support** - Works on Ubuntu, Debian, Fedora, Arch, and more

## 🛠️ Prerequisites

Before running the installation scripts, ensure you have the following installed:

### Required (Must Have)
- **Git** - For cloning the repository and plugin management
- **curl** - For downloading dependencies
- **sudo access** - For installing system packages

**Important**: If you don't have `git` and `curl` installed, install them first:

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y git curl

# Fedora
sudo dnf install -y git curl

# Arch Linux
sudo pacman -S git curl

# openSUSE
sudo zypper install -y git curl
```

### Optional (Auto-installed if missing)
The scripts will automatically install these if not present:
- **zsh** - The Z shell itself (ZSH setup)
- **neovim** - Text editor (both scripts install this)
- **neofetch/fastfetch** - System information display (ZSH setup)
- **lolcat** - Colorful terminal output (ZSH setup)
- **build tools** - Compilers and build utilities (ZSH setup)
- **tar** - For extracting Neovim binaries (LazyVim setup)

## 📋 Installation Guide

### ZSH Setup

#### Step-by-step Installation
1. Clone and enter the repository:
```bash
git clone https://github.com/IlanKog99/ZSH_Lazy-Nvim_Backups.git
cd ZSH_Lazy-Nvim_Backups
```

2. Run the setup script:
```bash
chmod +x setup_zsh.sh
./setup_zsh.sh
```

3. Log out and log back in (or restart your terminal)

**Note**: The script will copy `.zshrc` and `.p10k.zsh` files to your home directory, ensuring you get the exact same configuration.

### LazyVim Setup

#### Step-by-step Installation
1. Clone and enter the repository (if not already done):
```bash
git clone https://github.com/IlanKog99/ZSH_Lazy-Nvim_Backups.git
cd ZSH_Lazy-Nvim_Backups
```

2. Run the setup script:
```bash
chmod +x setup_lazyvim.sh
./setup_lazyvim.sh
```

3. Open Neovim:
```bash
nvim
```

**Note**: The script will install LazyVim and copy your custom `keymaps.lua` file to `~/.config/nvim/lua/config/keymaps.lua`. LazyVim will automatically install all plugins on first launch.

## 🎨 Customization

### ZSH Customization

#### Custom Aliases
The configuration includes the following custom aliases:
```bash
nv='nvim'           # Neovim shortcut
ls='ls --color'     # Colored ls
..='cd ..'          # Quick parent directory
reload='source ~/.zshrc'  # Reload config
parrot='curl ascii.live/parrot'  # Fun ASCII art
edit='nv ~/.zshrc'  # Edit config
cls='clear'         # Clear screen
python='python3'    # Python3 alias
free='free -h'      # Human-readable memory info
mkdir='mkcd'        # Create and enter directory
rm='rm -ri'         # Interactive recursive remove
df='df -h'          # Human-readable disk space
du='du -h'          # Human-readable disk usage
ps='ps -aux'        # Show all processes
grep='grep --color=auto'  # Colored grep
neo='cls && neofetch'  # Clear and show system info (or fastfetch on Arch)
py='python'         # Python shortcut
cat='lolcat'        # Colorful cat output
nvkeys='nv ~/.config/nvim/lua/config/keymaps.lua'  # Edit Neovim keymaps
```

#### Font Setup
This configuration uses Nerd Fonts for icons. Install a Nerd Font like:
- FiraCode Nerd Font
- JetBrains Mono Nerd Font
- Cascadia Code Nerd Font

#### Prompt Configuration
Run `p10k configure` to customize your prompt appearance.

#### Adding Plugins
Edit `~/.zshrc` and add plugins using Zinit:
```bash
zinit light username/plugin-name
```

### LazyVim Customization

#### Custom Keybindings
The configuration includes the following custom keybindings:
- **Ctrl+E** - Move to end of line (Normal and Insert mode)
- **Ctrl+A** - Move to start of line (Normal and Insert mode)
- **Ctrl+Z** - Undo (Normal, Visual, and Insert mode)
- **Ctrl+Right Arrow** - Move forward one word (Normal and Insert mode)
- **Ctrl+Left Arrow** - Move backward one word (Normal and Insert mode)

#### Adding More Keybindings
Edit `~/.config/nvim/lua/config/keymaps.lua` to add more custom keybindings. The file uses the standard Neovim keymap API:

```lua
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map("n", "<your-key>", "<your-command>", opts)
```

#### Adding Plugins
Create a new file in `~/.config/nvim/lua/plugins/` to add custom plugins. For example:

```lua
-- ~/.config/nvim/lua/plugins/myplugin.lua
return {
  "username/plugin-name",
  config = function()
    -- Plugin configuration
  end,
}
```

#### Changing Colorscheme
LazyVim uses Tokyonight by default. To change it, edit `~/.config/nvim/lua/config/lazy.lua`:

```lua
require("lazy").setup({
  install = { colorscheme = { "your-colorscheme" } },
  -- ... rest of config
})
```

## 📁 Project Structure

```
ZSH_Lazy-Nvim_Backups/
├── README.md              # This file
├── setup_lazyvim.sh       # LazyVim installation script
├── setup_zsh.sh           # ZSH installation script
├── lua/
│   └── config/
│       └── keymaps.lua    # Neovim keybindings configuration
├── .zshrc                 # Main ZSH configuration
└── .p10k.zsh              # Powerlevel10k theme configuration
```

## 🔧 Configuration Details

### ZSH Settings
- History size: 5000 entries
- History file: `~/.zsh_history`
- Auto-completion: Case-insensitive
- Key bindings: Emacs mode with custom shortcuts

### Plugin Manager
Uses Zinit for fast plugin loading:
- Automatic installation on first run
- Plugin directory: `~/.local/share/zinit/`
- Cache directory: `~/.cache/`

### LazyVim Structure
After installation, your Neovim configuration will be at:
- `~/.config/nvim/` - Main configuration directory
- `~/.config/nvim/lua/config/` - Configuration files (options, keymaps, autocmds)
- `~/.config/nvim/lua/plugins/` - Custom plugin configurations
- `~/.local/share/nvim/lazy/` - Installed plugins

### LazyVim Defaults
LazyVim comes with many plugins pre-configured:
- **Lazy.nvim** - Fast plugin manager
- **Telescope** - Fuzzy finder
- **Treesitter** - Syntax highlighting
- **LSP** - Language Server Protocol support
- **Mason** - LSP/DAP/Linter/Formatter installer
- **Which-key** - Keybinding helper
- And many more...

## 🐛 Troubleshooting

### ZSH Issues

**Icons not displaying properly:**
- Install a Nerd Font and set it in your terminal settings
- Restart your terminal after font installation

**Plugins not loading:**
- Check internet connection (Zinit downloads plugins from GitHub)
- Run `zinit update` to update plugins

**fzf not working:**
- Ensure fzf was installed correctly: `~/.fzf/install`
- Check if `~/.fzf.zsh` exists and is sourced

### LazyVim Issues

**LazyVim not loading:**
- Ensure Neovim version is 0.11.2 or higher: `nvim --version`
- Check that `~/.config/nvim/init.lua` exists
- Run `nvim` and check for error messages

**Plugins not installing:**
- Check internet connection (LazyVim downloads plugins from GitHub)
- Run `:Lazy` in Neovim to see plugin status
- Check `~/.local/share/nvim/lazy/` for installed plugins

**Keybindings not working:**
- Ensure `~/.config/nvim/lua/config/keymaps.lua` exists
- Restart Neovim after making changes
- Check for conflicts with other keybindings using `:WhichKey`

**Installation script fails:**
- Ensure you have `git` and `curl` installed
- Check that you have `sudo` access
- Verify your package manager is supported (apt, dnf, yum, pacman, zypper)

### Getting Help
1. Check the [LazyVim documentation](https://lazyvim.github.io/)
2. Visit [LazyVim GitHub](https://github.com/LazyVim/LazyVim)
3. Review [Neovim documentation](https://neovim.io/doc/)
4. Check the [Zinit documentation](https://github.com/zdharma-continuum/zinit)
5. Visit [Powerlevel10k GitHub](https://github.com/romkatv/powerlevel10k)
6. Review ZSH documentation: `man zsh`

## ⭐ Acknowledgments

### ZSH Configuration
- [romkatv](https://github.com/romkatv) for Powerlevel10k
- [zdharma-continuum](https://github.com/zdharma-continuum) for Zinit
- [zsh-users](https://github.com/zsh-users) for essential ZSH plugins
- [junegunn](https://github.com/junegunn) for fzf
- [ajeetdsouza](https://github.com/ajeetdsouza) for zoxide

### LazyVim Configuration
- [LazyVim](https://github.com/LazyVim/LazyVim) - The amazing Neovim distribution
- [folke](https://github.com/folke) - Creator of LazyVim and lazy.nvim
- [Neovim](https://neovim.io/) - The editor itself

## 📞 Support

If you find this project helpful, please give it a star ⭐!

For issues and questions, please open an issue on GitHub.

