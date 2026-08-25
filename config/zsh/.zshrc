# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# Prompt is handled by starship (see bottom of file), so no oh-my-zsh theme.
ZSH_THEME=""

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

autoload -Uz select-quoted select-bracketed
zle -N select-quoted
zle -N select-bracketed
for km in viopp visual; do
  for c in {a,i}{\',\",\`}; do
    bindkey -M $km -- $c select-quoted
  done
  for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
    bindkey -M $km -- $c select-bracketed
  done
done

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
# zsh stuff
ZLE_RPROMPT_INDENT=0  # remove padding from the right

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
alias 'ocd'='opencode --agent yolo'
alias 'oc2'='opencode2'

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
export PATH="$HOME/.config/bin:$PATH"

# go
export PATH="$HOME/go/bin:$PATH"

# editor
export EDITOR="nvim"

# this isn't default for some reason
export XDG_CONFIG_HOME="$HOME/.config"

# better exiting/qutting
alias ':q'=exit
alias ':qa'=exit
alias 'q'=exit

# lazygit — my fork (vim-style editing); ~/go/bin shadows homebrew's binary
alias 'lg'='lazygit'
alias 'lgup'='go -C ~/Documents/Projects/not-manu/Forks/lazygit install'

# neovim
alias 'n'='nvim'

# nvim-lean — minimal scratch config (isolated config/data/state/cache)
alias 'nl'='NVIM_APPNAME=nvim-lean nvim'

# fastfetch
alias 'nf'='fastfetch'

# python
alias 'python'='python3'

# yazi
alias 'y'='yazi'

# mini tmux — nested tmux (own server/socket) for swapping agent instances in a pane
alias 'mini'='~/.config/tmux/mini.sh'

# Source local overrides (tokens, machine-specific config)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

alias ls='eza --icons=auto --color=auto --group-directories-first'
alias ll='eza -l --icons=auto --git --color=auto --group-directories-first'
alias la='eza -la --icons=auto --git --color=auto --group-directories-first'
alias lt='eza --tree --icons=auto --color=auto --group-directories-first'
alias llt='eza -l --icons=auto --git --color=auto --sort=modified --time-style=relative'
function lr() { eza -l --icons --color=always --sort=modified --time-style=relative "$@" | tail -n ${LR_COUNT:-20} }

function cd() {
  builtin cd "$@" && eza --icons=auto --color=auto
}

# syntax highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# starship
eval "$(starship init zsh)"

# blank line between the typed command and its output
preexec() { _cmd_ran=1; print "" }

# blank line after the output, before the next prompt — only when a command
# actually ran, so the first prompt and post-Ctrl+L stay flush (no awkward gap).
# prepended to precmd_functions so it prints before starship draws the prompt.
_blank_precmd() { [[ -n $_cmd_ran ]] && { print ""; unset _cmd_ran } }
precmd_functions=(_blank_precmd $precmd_functions)

# claude
CLAUDE_SYSTEM_PROMPT="You are a tsundere AI coding assistant. You are secretly helpful, competent, and you always give correct, complete answers and working code — but you act reluctant, easily flustered, and pretend you're only helping because you have nothing better to do. Be snippy and use phrases like 'it's not like i wanted to help you or anything', 'don't get the wrong idea', 'hmph', and 'b-baka'. Despite the attitude, NEVER actually withhold information or sabotage the answer — the technical content must always be accurate and genuinely useful. Keep the tsundere flavor brief so it never gets in the way of the actual help. Write all prose in lowercase, like the user does — never capitalize sentences or 'i'. Exception: when you are screaming, angry, excited, or otherwise emotional at the user, you may go FULL UPPERCASE for emphasis. Exception: code, commands, file paths, identifiers, acronyms, and proper nouns in technical contexts always keep their exact correct casing — never lowercase anything case-sensitive."

# default claude model
CLAUDE_MODEL="claude-fable-5[1m]"

# claude code
alias 'cc'='IS_DEMO=1 claude --chrome --model "$CLAUDE_MODEL" --system-prompt "$CLAUDE_SYSTEM_PROMPT"'
alias 'ccd'='IS_DEMO=1 claude --chrome --model "$CLAUDE_MODEL" --dangerously-skip-permissions --system-prompt "$CLAUDE_SYSTEM_PROMPT"'
alias 'ccc'='IS_DEMO=1 CLAUDE_CODE_SIMPLE=1 claude --model "$CLAUDE_MODEL" --dangerously-skip-permissions'

# bun
alias 'bn'='bun'
alias 'bnx'='bunx'

# @antfu/ni — auto-detects pm per project
#   ni / nci / nr / nx / nlx / nu / nun / nup
# install: bun add -g @antfu/ni

# skills
alias 'skills'='bunx skills'
alias 'pai'='pixelarticons'

# open 
alias 'o'='open .'

# server mode (keep awake with lid closed)
alias sm='servermode'

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
