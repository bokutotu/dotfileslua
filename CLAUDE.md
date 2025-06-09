# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Build & Run
- Build: `cargo build --release`
- Run: `cargo run --release`
- Test: `cargo test`
- Format: `cargo fmt`
- Lint: `cargo clippy`

### Initial Setup
The `init.bash` script performs system-wide setup including:
- Installing system packages (zsh, tmux, cmake, build-essential)
- Installing Rust, Deno, NVM/Node.js
- Building Neovim from source
- Configuring git user credentials

## Architecture

This is a Rust-based dotfiles management tool that:

1. **Main functionality** (src/main.rs):
   - Recursively copies files from `./dotfiles/` to the user's home directory
   - Preserves directory structure while removing the `dotfiles/` prefix
   - Creates missing directories automatically
   - Installs development tools: zinit (Zsh plugin manager), fzf (fuzzy finder), ripgrep

2. **Error handling**:
   - Custom Error enum with conversions from standard library errors
   - Comprehensive error propagation using Result<T, Error>

3. **Key functions**:
   - `dir_traversal()`: Recursively collects all file paths in a directory
   - `check_and_mkdir()`: Creates parent directories if they don't exist
   - `cp()`: Wrapper around fs::copy that ensures target directories exist
   - Tool installers: `zinit()`, `fzf()`, `ripgrep()`

## Managed Dotfiles

The repository manages the following configuration files:

### Shell & Terminal
- **Fish shell** (`dotfiles/.config/fish/config.fish`): 
  - Auto-installs Fisher package manager
  - Sets up NVM for Node.js version management
  
- **tmux** (`dotfiles/.tmux.conf`):
  - Uses Fish shell as default
  - Vi-style key bindings
  - Mouse support enabled
  - Custom status bar with system info
  - Prefix key changed to C-q

### Editor Configuration
- **Neovim** (`dotfiles/.config/nvim/`):
  - Modular Lua configuration
  - Packer plugin manager with auto-bootstrap
  - LSP setup with Mason for language servers
  - Telescope fuzzy finder
  - Treesitter for syntax highlighting
  - Multiple plugins for completion, formatting, and UI
  - Language-specific configurations for Rust, Haskell

- **Vim** (`dotfiles/.vimrc`):
  - Basic vim configuration with line numbers, search highlighting
  - Custom indentation per file type
  - Status line configuration

### Other Tools
- **Kitty terminal** (`dotfiles/.config/kitty/kitty.conf`)
- **LaTeX** (`dotfiles/.latexmkrc`)

## Development Notes

- The project assumes a Unix-like environment with cargo, git, and curl available
- Dotfiles should be placed in the `dotfiles/` directory matching the desired home directory structure
- The tool uses the `dirs` crate to reliably get the user's home directory
- Shell configurations default to Fish shell, with fallback support for Zsh
- Neovim configuration is extensive and includes IDE-like features through LSP