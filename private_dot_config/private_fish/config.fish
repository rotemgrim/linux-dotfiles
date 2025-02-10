if status is-interactive
    # Commands to run in interactive sessions can go here
end
eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
set -x NVM_DIR ~/.nvm
nvm use 20 >/dev/null

alias ll='eza -lha'

atuin init fish --disable-up-arrow | source
starship init fish | source
