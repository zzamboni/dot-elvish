# Directory history

# The stack and a pointer into it, which points to the current
# directory. Normally the cursor points to the end of the stack, but
# it can move with `back` and `forward`
stack = [ $pwd ]
cursor = (- (count $stack) 1)

fn stacksize { count $stack }

# Current directory, empty string if stack is empty
fn curdir {
  if (> (stacksize) 0) {
    put $stack[$cursor]
  } else {
    put ""
  }
}

# Add $pwd into the stack at $cursor, only if it's different than the
# current directory (i.e. you can call push multiple times in the same
# directory, for example as part of a prompt hook, and it will only be
# added once). Pushing a directory invalidates (if any) any
# directories after it in the history.
fn push {
  if (or (== (stacksize) 0) (!=s $pwd (curdir))) {
    stack = [ (explode $stack[0:(+ $cursor 1)]) $pwd ]
    echo "Added to stack: "$pwd
    cursor = (- (count $stack) 1)
  }
}

# Move back and forward through the stack. `pop` is the same
# as `back`.
fn back {
  if (> $cursor 0) {
    cursor = (- $cursor 1)
    cd $stack[$cursor]
    push
  } else {
    echo "Beginning of directory stack!"
  }
}

fn pop { back }

fn forward {
  if (< $cursor (- (stacksize) 1)) {
    cursor = (+ $cursor 1)
    cd $stack[$cursor]
    push
  } else {
    echo "End of directory stack!"
  }
}

# Utility functions to move the cursor by a word or move through
# the directory history, depending on the contents of the command
fn left-word-or-prev-dir {
  if (> (count $edit:current-command) 0) {
    edit:move-dot-left-word
  } else {
    dirs:back
  }
}

fn right-word-or-next-dir {
  if (> (count $edit:current-command) 0) {
    edit:move-dot-right-word
  } else {
    dirs:forward
  }
}

# Set up callbacks to push the current directory on every prompt and,
# if `narrow` is loaded, also after location mode.
fn setup {
  edit:before-readline = [ $@edit:before-readline $&push ]
  _ = ?(narrow:after-location = [ $@narrow:after-location $&push ])
}
