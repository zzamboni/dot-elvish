# Directory history management
#
# Keep and move through the directory history, including a graphical
# chooser, similar to Elvish's Location mode, but showing a chronological
# directory history instead of a weighted one.
#
# Example of use:
#
#     use dir
#     dir:setup
#     edit:insert:binding[Alt-b] = $dir:&left-word-or-prev-dir
#     edit:insert:binding[Alt-f] = $dir:&right-word-or-next-dir
#     edit:insert:binding[Alt-i] = $dir:&dir-chooser
#     fn cd [@dir]{ dir:cd $@dir }

# Hooks to run before and after the directory chooser
before-chooser = []
after-chooser = []

# The stack and a pointer into it, which points to the current
# directory. Normally the cursor points to the end of the stack, but
# it can move with `back` and `forward`
-dirstack = [ $pwd ]
-cursor = (- (count $-dirstack) 1)

# Maximum stack size, 0 for no limit
-max-stack-size = 100

fn stacksize { count $-dirstack }

fn stack { put $@-dirstack }
fn pstack { pprint [(stack)] }

# Current directory in the stack, empty string if stack is empty
fn curdir {
  if (> (stacksize) 0) {
    put $-dirstack[$-cursor]
  } else {
    put ""
  }
}

# Add $pwd into the stack at $-cursor, only if it's different than the
# current directory (i.e. you can call push multiple times in the same
# directory, for example as part of a prompt hook, and it will only be
# added once). Pushing a directory invalidates (if any) any
# directories after it in the history.
fn push {
  if (or (== (stacksize) 0) (!=s $pwd (curdir))) {
    -dirstack = [ (explode $-dirstack[0:(+ $-cursor 1)]) $pwd ]
    if (> (stacksize) $-max-stack-size) {
      -dirstack = $-dirstack[(- $-max-stack-size):]
    }
    -cursor = (- (stacksize) 1)
  }
}

# Move back and forward through the stack.
fn back {
  if (> $-cursor 0) {
    -cursor = (- $-cursor 1)
    cd $-dirstack[$-cursor]
    push
  } else {
    echo "Beginning of directory stack!"
  }
}

fn forward {
  if (< $-cursor (- (stacksize) 1)) {
    -cursor = (+ $-cursor 1)
    cd $-dirstack[$-cursor]
    push
  } else {
    echo "End of directory stack!"
  }
}

# Pop the previous directory on the stack. The current dir becomes the
# previous one, so successive pops alternate between the two last
# directories.
fn pop {
  if (> $-cursor 0) {
    cd $-dirstack[(- $-cursor 1)]
    push
  } else {
    echo "No previous directory to pop!"
  }
}

# Utility functions to move the cursor by a word or move through
# the directory history, depending on the contents of the command
fn left-word-or-prev-dir {
  if (> (count $edit:current-command) 0) {
    edit:move-dot-left-word
  } else {
    back
  }
}

fn right-word-or-next-dir {
  if (> (count $edit:current-command) 0) {
    edit:move-dot-right-word
  } else {
    forward
  }
}

# cd wrapper which supports "-" to indicate the previous directory
# (calls pop)
fn cd [@dir]{
  if (and (== (count $dir) 1) (eq $dir[0] "-")) {
    pop
  } else {
    builtin:cd $@dir
  }
}

# Interactive dir history chooser
fn dir-chooser {
  for hook $before-chooser { $hook }
  index = 0
  candidates = [(each [arg]{
        put [
          &content=$arg
          &display=$index" "$arg
          &filter-text=$index" "$arg
        ]
        index = (+ $index 1)
  } $-dirstack)]
  edit:-narrow-read {
    put $@candidates
  } [arg]{
    cd $arg[content]
    push
    for hook $after-chooser { $hook }
  } &modeline="Dir history " &ignore-case=$true &keep-bottom=$true
}

# Set up callbacks to push the current directory on every prompt and,
# if `narrow` is loaded, also after location mode.
fn setup {
  edit:before-readline = [ $@edit:before-readline $&push ]
  _ = ?(narrow:after-location = [ $@narrow:after-location $&push ])
}
