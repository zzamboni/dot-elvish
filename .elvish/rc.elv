# Path
paths = [
  /Users/taazadi1/bin
  /Users/taazadi1/Dropbox/Personal/devel/hammerspoon/spoon/bin
  /opt/X11/bin
  /Library/TeX/texbin
  /usr/local/bin
  /usr/local/sbin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
]

# Emacs keybinding
use readline-binding

# Prompt hook manipulation
use prompt_hooks

# Chain prompt, copied from fish's theme at https://github.com/oh-my-fish/theme-chain
use theme:chain
theme:chain:setup

# Automatically set proxy
use proxy
proxy:test = { and ?(test -f /etc/resolv.conf) ?(egrep -q '^(search|domain).*corproot.net' /etc/resolv.conf) }
proxy:host = "http://proxy.corproot.net:8079"
# Add the hook both before and after the prompt so that it's configured correctly in case the conditions change
# while you are typing a command.
prompt_hooks:add-before-readline { proxy:autoset }
prompt_hooks:add-after-readline [cmd]{ proxy:autoset }

# Notifications for long-running-commands
use long-running-notifications
long-running-notifications:setup

# Completions
use completer:vcsh
use completer:git

# Read in private settings - normally you should not check in lib/private.elv into git
if ?(test -f ~/.elvish/lib/private.elv) { use private }

## Other keybindings

# Alt-backspace to delete word
edit:insert:binding[Alt-Backspace] = $edit:&kill-small-word-left
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

# Smart-case completion (if your pattern is entirely lower
# case it ignores case, otherwise it's case sensitive).
# "&smart-case" can be "&ignore-case" to make it always
# case-insensitive.
edit:-matcher[''] = [p]{ edit:match-prefix &smart-case $p }

# Aliases
fn ls [@arg]{ e:ls -G $@arg }
fn more [@arg]{ less $@arg }

# Environment variables
E:LESS = "-i -R"
E:GOPATH = ~/Personal/devel/go/
E:EDITOR = "vim"
paths = [ $@paths $E:GOPATH/bin ]
