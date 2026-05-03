# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git vi-mode)

# vi-mode configuration
VI_MODE_RESET_PROMPT_ON_MODE_CHANGE=true
VI_MODE_SET_CURSOR=true
KEYTIMEOUT=1

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
source ~/powerlevel10k/powerlevel10k.zsh-theme

# zsh stuff
ZLE_RPROMPT_INDENT=0  # remove padding from the right

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
alias 'ocd'='opencode --agent yolo'

# `oc` wraps opencode so `oc patch` runs the smile-logo rebuild script
function oc() {
  if [[ "${1:-}" == "patch" ]]; then
    shift
    bash "$HOME/.dotfiles/config/opencode/rebuild-with-smile.sh" "$@"
  else
    opencode "$@"
  fi
}

# zoxide
eval "$(zoxide init zsh)"

# fzf
source <(fzf --zsh)
export FZF_CTRL_R_OPTS="--layout=reverse --no-info --no-separator --border=none"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
alias 'pn'='pnpm'

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# editor
export EDITOR="nvim"

# this isn't default for some reason
export XDG_CONFIG_HOME="$HOME/.config"

# better exiting/qutting
alias ':q'=exit
alias ':qa'=exit
alias 'q'=exit

# lazygit
alias 'lg'='lazygit'

# neovim
alias 'n'='nvim'

# neofetch
alias 'nf'='neofetch'

# python
alias 'python'='python3'

# yazi
alias 'y'='yazi'

# Source local overrides (tokens, machine-specific config)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Replace ls with eza
alias ls='eza --icons --color=always --group-directories-first'
alias ll='eza -l --icons --git --color=always --group-directories-first'
alias la='eza -la --icons --git --color=always --group-directories-first'
alias lt='eza --tree --icons --color=always --group-directories-first'

# Replace cd with eza preview (optional)
# eza doesn't replace cd directly since it's a navigation command,
# but you can add a function to auto-list after cd:
function cd() {
  builtin cd "$@" && eza --icons --color=always
}

# syntax highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# starship
eval "$(starship init zsh)"

# claude
alias 'cc'='claude'
alias 'ccd'='claude --dangerously-skip-permissions'

# bun
alias 'bn'='bun'
alias 'bnx'='bunx'

# skills
alias 'skills'='bunx skills'

# open 
alias 'o'='open .'

# tmux
alias t='tmux'
alias tn='tmux new-session -s'         # tn <name>  — new named session
alias ta='tmux attach-session -t'      # ta <name>  — attach to named session
alias tl='tmux list-sessions'          # list all sessions
alias tk='tmux kill-session -t'        # tk <name>  — kill a session
alias td='tmux detach'                 # detach from current session

# attach to last session, or create a default one if none exists
function ts() {
  if tmux list-sessions &>/dev/null; then
    tmux attach-session
  else
    tmux new-session -s main
  fi
}

# fuzzy-pick a tmux session to attach to (requires fzf)
function taf() {
  local session
  session=$(tmux list-sessions -F '#{session_name}' 2>/dev/null | fzf --prompt='tmux session: ') && tmux attach-session -t "$session"
}

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/manu/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/manu/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/manu/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/manu/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
