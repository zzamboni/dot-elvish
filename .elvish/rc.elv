# Path
paths = [
  ~/bin
  ~/Dropbox/Personal/devel/hammerspoon/spoon/bin
  /opt/X11/bin
  /Library/TeX/texbin
  /usr/local/opt/node@6/bin
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

# Git-related functions
use git
fn git [@arg]{ git:git_vcsh $@arg }

# Chain prompt, copied from fish's theme at https://github.com/oh-my-fish/theme-chain
use theme:chain
# Uncomment this to update the chain only after each command and not
# on every keystroke. This improves typing speed sometimes (e.g. in
# large git repos when you have the git segments enabled) but may
# cause prompt refresh problems sometimes until you press Enter after
# a directory change or some other change.
#theme:chain:cache_chain = $true
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

edit:arg-completer[git] = [@args]{ completer:git:git-completer $&git (explode $args[1:]) }

# Use narrow mode for location, dir-history and lastcmd modes, this
# allows hooking into the completion process (i.e. to update the prompt)
use narrow
narrow:bind-trigger-keys &location=Alt-l &lastcmd=""
update_prompt = { _ = ?(theme:chain:cache_prompts; edit:redraw) }
narrow:after-location = [ $@narrow:after-location $update_prompt ]
narrow:after-history = [ $@narrow:after-history $update_prompt ]
narrow:after-lastcmd = [ $@narrow:after-lastcmd $update_prompt ]

# Use !! and !$ to insert the last command and its last argument, respectively.
# Because muscle memory is too strong to give up
use bang-bang
bang-bang:bind-trigger-keys
bang-bang:after-lastcmd = [ $@bang-bang:after-lastcmd $update_prompt ]

# Directory history
use dir
dir:setup
edit:insert:binding[Alt-b] = $dir:&left-word-or-prev-dir
edit:insert:binding[Alt-f] = $dir:&right-word-or-next-dir
edit:insert:binding[Alt-i] = $dir:&history-chooser
dir:after-cd = [ $@dir:after-cd $update_prompt ]
fn cd [@dir]{ dir:cd $@dir }

# Atlas-related functions
use atlas

# Set up Nix environment
use nix

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
prompt_hooks:add-after-readline [cmd]{ set-title (re:split '\s' $cmd | take 1)" "(tilde-abbr $pwd) }

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

# Aliases and other misc functions
fn ls [@arg]{ e:ls -G $@arg }
fn more [@arg]{ less $@arg }
fn cdb [p]{ cd (dirname $p) }

# Environment variables
E:LESS = "-i -R"
E:GOPATH = ~/Personal/devel/go/
E:EDITOR = "vim"
paths = [ $@paths $E:GOPATH/bin ]
