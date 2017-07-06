paths = [/Users/taazadi1/bin
         /Users/taazadi1/Dropbox/Personal/devel/hammerspoon/spoon/bin
         /opt/X11/bin
         /Library/TeX/texbin
         /usr/local/bin
         /usr/local/sbin
         /usr/bin
         /bin
         /usr/sbin
         /sbin]
         
# Emacs keybinding
use readline-binding

edit:binding[insert][Alt-Backspace] = { edit:kill-word-left }

# Set terminal title
fn set-title { print "\e]2;"$0"\e\\" }
edit:before-readline=[ { set-title "elvish "(tilde-abbr $pwd) > /dev/tty } ]
edit:after-readline=[ { set-title (echo $0 | sed 's/[ \t].*//')" "(tilde-abbr $pwd) } ]

# Some aliases
fn ls { e:ls -G $@ }

# Chain prompt, copied from fish's theme at https://github.com/oh-my-fish/theme-chain
use chain
edit:prompt=chain:prompt
edit:rprompt=chain:rprompt
