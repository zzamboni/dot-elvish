fn location {
  candidates = [(dir-history | each [arg]{
	      score = (splits . $arg[score] | take 1)
        put [
          &content=$arg[path]
          &display=$score" "$arg[path]
	      ]
  })]

  edit:-narrow-read {
    put $@candidates
  } [arg]{
    cd $arg[content]
    theme:chain:generate_prompt
    edit:redraw
  } &modeline="[narrow] Location " &ignore-case=$true
}

fn history {
  candidates = [(edit:command-history | each [arg]{
        put [
	        &content=$arg[cmd]
	        &display=$arg[id]" "(replaces "\t" " " (replaces "\n" " " $arg[cmd]))
        ]
  })]

  edit:-narrow-read {
    put $@candidates
  } [arg]{
    edit:replace-input $arg[content]
    theme:chain:generate_prompt
    edit:redraw
  } &modeline="[narrow] History " &keep-bottom=$true &ignore-case=$true
}

fn lastcmd {
  last = (edit:command-history -1)
  cmd = [
    &content=$last[cmd]
    &display="M-1 "$last[cmd]
	  &filter-text=""
  ]
  index = 0
  candidates = [$cmd ( edit:wordify $last[cmd] | each [arg]{
	      put [
          &content=$arg
          &display=$index" "$arg
          &filter-text=$index
	      ]
	      index = (+ $index 1)
  })]
  edit:-narrow-read {
    put $@candidates
  } [arg]{
    edit:replace-input $arg[content]
    theme:chain:generate_prompt
    edit:redraw
  } &modeline="[narrow] Lastcmd " &auto-commit=$true &bindings=[&M-1={ edit:narrow:accept-close }] &ignore-case=$true
}


# TODO: separate bindings from functions

fn bind_i [k f]{
  edit:insert:binding[$k] = $f
}

fn bind_n [k f]{
  edit:narrow:binding[$k] = $f
}

bind_i Alt-l     narrow:location
bind_i C-r       narrow:history
bind_i M-1       narrow:lastcmd

bind_n Up        $edit:narrow:&up
bind_n PageUp    $edit:narrow:&page-up
bind_n Down      $edit:narrow:&down
bind_n PageDown  $edit:narrow:&page-down
bind_n Tab       $edit:narrow:&down-cycle
bind_n S-Tab     $edit:narrow:&up-cycle
bind_n Backspace $edit:narrow:&backspace
bind_n Enter     $edit:narrow:&accept-close
bind_n M-Enter   $edit:narrow:&accept
bind_n default   $edit:narrow:&default
bind_n "C-["     $edit:insert:&start
bind_n C-G       $edit:narrow:&toggle-ignore-case
bind_n C-D       $edit:narrow:&toggle-ignore-duplication
