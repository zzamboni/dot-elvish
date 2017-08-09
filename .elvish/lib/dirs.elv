stack = [ ]
oldpwd = $pwd
stackpos = 0

fn pushd {
  if (!=s $pwd $oldpwd) {
    stack = [ $stack $oldpwd ]
    echo "Added to stack: "$oldpwd
    oldpwd = $pwd
    stackpos = (count $stack)
  }
}

fn popd {
  if (> (count $stack) 0) {
    cd $stack[-1]
    stack = $stack[0:-1]
    pushd 
  } else {
    print "Directory stack is empty!"
  }
}

edit:before-readline = [ $@edit:before-readline $&pushd ]
narrow:after-location = [ $@narrow:after-location $&pushd ]
