if status is-interactive
    # Commands to run in interactive sessions can go here
end
eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)
set -x NVM_DIR ~/.nvm
nvm use 20 >/dev/null

alias ll='eza -lha'

atuin init fish --disable-up-arrow | source
starship init fish | source

function fish_greeting
    # this should be inside the greeting function
    cat ~/motd | lolcat
    echo -n "Have a great day! "
    printf "%s%s%s" (set_color cyan; echo -n (whoami)) (set_color purple; printf " 󰿄 ") (set_color green; echo -n (hostname))
    set_color normal
    echo ""
end

alias air='~/go/bin/air'
set -x GOROOT /usr/local/go
set -x GOPATH $HOME/go
set -x PATH $PATH $GOPATH/bin:$GOROOT/bin
