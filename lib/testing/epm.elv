# Verbosity configuration
debug-mode = $false
silent-mode = $false

# Internal configuration
-data-dir = ~/.elvish
-lib-dir = $-data-dir/lib

# Runtime state
-domain-config = [&]

# Configuration for common domains
-default-domain-config = [
  &"github.com"= [
    &method= git
    &protocol= https
    &levels= 2
  ]
]

# Utility functions
fn -debug [text]{
  if $debug-mode {
    print (edit:styled '=> ' blue)
    echo $text
  }
}

fn -info [text]{
  if (not $silent-mode) {
    print (edit:styled '=> ' green)
    echo $text
  }
}

fn -warn [text]{
  print (edit:styled '=> ' yellow)
  echo $text
}

fn -error [text]{
  print (edit:styled '=> ' red)
  echo $text
}

fn dest [pkg]{
  put $-lib-dir/$pkg
}

fn is-installed [pkg]{
  put ?(test -e (dest $pkg))
}

# Known domain method handlers. Each entry is indexed by method name
# (the value of the "method" key in the domain configs), and must
# contain two keys: install and upgrade, each one must be a closure
# that received two arguments: package name and the domain config
# entry
-method-handler = [
  &git= [
    &install= [pkg dom-cfg]{
      dest = (dest $pkg)
      if (is-installed $pkg) {
        -info "Package "$pkg" is already installed."
        return
      }
      -info "Installing "$pkg
      mkdir -p $dest
      git clone $dom-cfg[protocol]"://"$pkg $dest
    }

    &upgrade= [pkg dom-cfg]{
      dest = (dest $pkg)
      if (not (is-installed $pkg)) {
        -error "Package "$pkg" is not installed."
        return
      }
      -info "Updating "$pkg
      git -C $dest pull
    }
  ]
]

fn -package-domain [pkg]{
  splits / $pkg | take 1
}

fn -domain-config-file [dom]{
  put $-lib-dir/(-package-domain $dom)/epm-domain.cfg
}

fn -read-domain-config [dom]{
  cfgfile = (-domain-config-file $dom)
  # Only read config if it hasn't been loaded already
  if (not (has-key $-domain-config $dom)) {
    if ?(test -f $cfgfile) {
      # If the config file exists, read it...
      -domain-config[$dom] = (cat $cfgfile | from-json)
      -debug "Read domain config for "$dom": "(to-string $-domain-config[$dom])
    } else {
      # ...otherwise check if we have a default config for the domain, and save it
      if (has-key $-default-domain-config $dom) {
        -domain-config[$dom] = $-default-domain-config[$dom]
        -debug "No existing config for "$dom", using the default: "(to-string $-domain-config[$dom])
        mkdir -p (dirname $cfgfile)
        put $-domain-config[$dom] | to-json > $cfgfile
      } else {
        fail "No existing config for "$dom" and no default available. Please create config file "(tilde-abbr $cfgfile)" by hand"
      }
    }
  }
}

# Invoke package operations defined in $-method-handler above
fn -package-op [pkg what]{
  res = $false
  dom = (-package-domain $pkg)
  -read-domain-config $dom
  if (has-key $-domain-config $dom) {
    cfg = $-domain-config[$dom]
    if (has-key $-method-handler $cfg[method]) {
      $-method-handler[$cfg[method]][$what] $pkg $cfg
    } else {
      fail "No handler defined for method '"$cfg[method]"', specified in in config file "(-domain-config-file $dom)
    }
  }
}

fn -install-package [pkg]{
  -package-op $pkg install
}

fn -upgrade-package [pkg]{
  -package-op $pkg upgrade
}

fn -uninstall-package [pkg]{
  if (not (is-installed $pkg)) {
    -error "Package "$pkg" is not installed."
    return
  }
  dest = (dest $pkg)
  -info "Removing package "$pkg
  rm -rf $dest
}

fn installed {
  find $-lib-dir -depth 1 -type d | each [dir]{
    dom = (replaces $-lib-dir/ "" $dir)
    if ?(test -f (-domain-config-file $dom)) {
      -read-domain-config $dom
      if (has-key $-domain-config $dom) {
        lvl = $-domain-config[$dom][levels]
        find $-lib-dir/$dom -type d -depth $lvl | each [pkg]{
          replaces $-lib-dir/ "" $pkg
        }
      }
    }
  }
}

######################################################################

fn install [@pkgs]{
  if (eq $pkgs []) {
    fail 'Must specify at least one package.'
    return
  }
  for pkg $pkgs {
    -install-package $pkg
  }
}

fn upgrade [@pkgs]{
  if (eq $pkgs []) {
    pkgs = [(installed)]
    -info 'Upgrading all installed packages'
  }
  for pkg $pkgs {
    -upgrade-package $pkg
  }
}

fn uninstall [@pkgs]{
  if (eq $pkgs []) {
    fail 'Must specify at least one package.'
    return
  }
  for pkg $pkgs {
    -uninstall-package $pkg
  }
}
