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

# Automatically set proxy
use proxy
proxy:test = { and ?(test -f /etc/resolv.conf) ?(egrep -q '^(search|domain).*corproot.net' /etc/resolv.conf) }
proxy:host = "proxy.corproot.net:8079"
prompt_hooks:add-before-readline { proxy:autoset }

# Notifications for long-running-commands
use long-running-notifications
long-running-notifications:setup

# Read in private settings - normally you should not check in lib/private.elv into git
if ?(test -f ~/.elvish/lib/private.elv) { use private }

## Other keybindings

# Alt-backspace to delete word
edit:insert:binding[Alt-Backspace] = { edit:kill-word-left }
# Alt-d to delete the word under the cursor
edit:insert:binding[Alt-d] = { edit:move-dot-right-word; edit:kill-word-left }

# Set terminal title
fn set-title [title]{ print "\e]2;"$title"\e\\" }
prompt_hooks:add-before-readline { set-title "elvish "(tilde-abbr $pwd) > /dev/tty }
prompt_hooks:add-after-readline [cmd]{ set-title (echo $cmd | sed 's/[ \t].*//')" "(tilde-abbr $pwd) }

# Misc functions
fn dotify_string [str dotify_length]{
  if (or (== $dotify_length 0) (<= (count $str) $dotify_length)) {
    put $str
  } else {
    re:replace '(.{'$dotify_length'}).*' '$1…' $str
  }
}

# Aliases
fn ls [@arg]{ e:ls -G $@arg }
fn more [@arg]{ less $@arg }

# Environment variables
E:LESS="-i -R"
