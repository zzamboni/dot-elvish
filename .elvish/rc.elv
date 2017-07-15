# Path
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

# Prompt hook manipulation
use prompt_hooks

# Chain prompt, copied from fish's theme at https://github.com/oh-my-fish/theme-chain
use chain
edit:prompt = chain:prompt
edit:rprompt = chain:rprompt

# Read in private settings
use private

## Other keybindings

# Alt-backspace to delete word
edit:binding[insert][Alt-Backspace] = { edit:kill-word-left }

# Set terminal title
fn set-title [title]{ print "\e]2;"$title"\e\\" }
prompt_hooks:add-before-readline { set-title "elvish "(tilde-abbr $pwd) > /dev/tty }
prompt_hooks:add-after-readline [cmd]{ set-title (echo $cmd | sed 's/[ \t].*//')" "(tilde-abbr $pwd) }

# Automatically set proxy
use proxy
proxy:test = { and ?(test -f /etc/resolv.conf) ?(egrep -q '^(search|domain).*corproot.net' /etc/resolv.conf) }
proxy:host = "proxy.corproot.net:8079"
prompt_hooks:add-before-readline { proxy:autoset }

# Aliases
fn ls [@arg]{ e:ls -G $@arg }
fn more [@arg]{ less $@arg }

# Environment variables
E:LESS="-i -R"
E:ATLAS_TOKEN=$private:ATLAS_TOKEN
ATLAS_TOKEN=$E:ATLAS_TOKEN
