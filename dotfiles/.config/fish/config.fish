function get_venv_info
    set -l venvs
    
    # Python virtual environments
    set -q VIRTUAL_ENV; and set -a venvs (basename $VIRTUAL_ENV)
    
    # Conda environments
    set -q CONDA_DEFAULT_ENV; and test "$CONDA_DEFAULT_ENV" != base; and set -a venvs "conda:$CONDA_DEFAULT_ENV"
    
    # Nix shell
    set -q IN_NIX_SHELL; and set -a venvs "nix"
    
    # Pyenv (check file-based version, faster than command)
    if test -f .python-version
        set -l pyenv_version (cat .python-version 2>/dev/null | head -1)
        test -n "$pyenv_version"; and set -a venvs "py:$pyenv_version"
    else if set -q PYENV_VERSION
        set -a venvs "py:$PYENV_VERSION"
    end
    
    # Poetry virtual env
    set -q POETRY_ACTIVE; and set -a venvs "poetry"
    
    # Pipenv
    set -q PIPENV_ACTIVE; and set -a venvs "pipenv"
    
    # Node.js version managers
    set -q NVM_BIN; and test -n "$NVM_BIN"; and set -a venvs "node:"(basename (dirname $NVM_BIN))
    
    # Ruby version managers
    set -q RBENV_VERSION; and set -a venvs "rb:$RBENV_VERSION"
    
    # Rust toolchain
    if test -f rust-toolchain.toml; or test -f rust-toolchain
        set -l toolchain (cat rust-toolchain.toml rust-toolchain 2>/dev/null | head -1)
        test -n "$toolchain"; and set -a venvs "rust:$toolchain"
    end
    
    # Return comma-separated list or empty
    test (count $venvs) -gt 0; and string join ',' $venvs
end

function fish_prompt
    set -l last_status $status
    
    # Colors
    set -l normal (set_color normal)
    set -l blue (set_color cyan)
    set -l green (set_color green)
    set -l red (set_color red)
    set -l yellow (set_color yellow)
    set -l magenta (set_color magenta)
    
    # User
    printf '%s%s%s' $green (whoami) $normal
    
    # Directory (relative to HOME)
    set -l cwd (string replace $HOME '~' (pwd))
    printf ' %s%s%s' $blue $cwd $normal
    
    # Git branch (fast check)
    if test -d .git; or git rev-parse --git-dir >/dev/null 2>&1
        set -l branch (git branch --show-current 2>/dev/null)
        test -n "$branch"; and printf ' %s(%s)%s' $yellow $branch $normal
    end
    
    # Virtual environments
    set -l venv_info (get_venv_info)
    test -n "$venv_info"; and printf ' %s[%s]%s' $magenta $venv_info $normal
    
    # Prompt symbol with status
    printf ' %s❯%s ' (test $last_status -eq 0; and echo $green; or echo $red) $normal
end

if status --is-interactive
    # Load machine-specific environment variables
    set -l env_file $HOME/.config/fish/env.fish
    if test -f $env_file
        source $env_file
    end
    
    # Set default editor to nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    
    # Create alias for vi -> nvim
    alias vi='nvim'
    
    # Create alias for ls -> lsd
    alias ls='lsd'

    # ❷ fisher の本体ファイルが無ければインストール
    set -l fisher_file $__fish_config_dir/functions/fisher.fish
    if not test -f $fisher_file
        echo "(初回のみ) Installing fisher..."
        curl -sL https://git.io/fisher | source ; and fisher install jorgebucaran/fisher
    end

    set -gx NVM_DIR $HOME/.nvm

    if not functions -q nvm
        fisher install jorgebucaran/nvm.fish
    end

    set -l nvm_repo_default $HOME/.config/.nvmrc
    if functions -q nvm; and test -f $nvm_repo_default
        set -l repo_default_version (string trim (command head -n 1 $nvm_repo_default))
        if test -n "$repo_default_version"
            if not set -q nvm_default_version; or test "$nvm_default_version" != "$repo_default_version"
                set -Ux nvm_default_version $repo_default_version
            end
        end
    end
    
    # Auto use Node versions managed via nvm when entering directories
    function __nvm_auto_use --on-variable PWD --description 'auto switch node version'
        status --is-command-substitution; and return
        if not functions -q nvm
            return
        end

        if test -f $PWD/.nvmrc
            nvm use --silent >/dev/null 2>&1
        else if set -q nvm_default_version
            nvm use --silent default >/dev/null 2>&1
        end
    end
    __nvm_auto_use
    
    # Add deno to PATH
    if test -d $HOME/.deno/bin
        set -gx PATH $HOME/.deno/bin $PATH
    end
end
