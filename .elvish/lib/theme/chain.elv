# See https://github.com/zzamboni/vcsh_elvish/blob/master/.elvish/lib/theme/chain.org
# for the source code from which this file is generated.

use re

prompt_segments = [ su dir git_branch git_dirty arrow ]
rprompt_segments = [ ]

glyph = [
  &prompt= ">"
  &git_branch= "⎇"
  &git_dirty= "±"
  &su= "⚡"
  &chain= "─"
]

segment_style = [
  &chain= default
  &su= yellow
  &dir= cyan
  &git_branch= blue
  &git_dirty= yellow
  &timestamp= gray
]

prompt_pwd_dir_length = 1

timestamp_format = "%R"

root_id = 0

fn -colored [what color]{
  if (!=s $color default) {
    edit:styled $what $color
  } else {
    put $what
  }
}

fn prompt_segment [style @texts]{
  text = "["(joins ' ' $texts)"]"
  -colored $text $style
}

# Return the git branch name of the current directory
fn -git_branch_name {
  out = ""
  err = ?(out = (git branch 2>/dev/null | eawk [line @f]{
        if (eq $f[0] "*") {
          if (and (> (count $f) 2) (eq $f[2] "detached")) {
            replaces ')' '' $f[4]
          } else {
            echo $f[1]
          }
        }
  }))
  put $out
}

# Return whether the current git repo is "dirty" (modified in any way)
fn -git_is_dirty {
  out = []
  err = ?(out = [(git ls-files --exclude-standard -om 2>/dev/null)])
  > (count $out) 0
}

fn segment_git_branch {
  branch = (-git_branch_name)
  if (not-eq $branch "") {
    prompt_segment $segment_style[git_branch] $glyph[git_branch] $branch
  }
}

fn segment_git_dirty {
  if (-git_is_dirty) {
    prompt_segment $segment_style[git_dirty] $glyph[git_dirty]
  }
}

fn -prompt_pwd {
  tmp = (tilde-abbr $pwd)
  if (== $prompt_pwd_dir_length 0) {
    put $tmp
  } else {
    re:replace '(\.?[^/]{'$prompt_pwd_dir_length'})[^/]*/' '$1/' $tmp
  }
}

fn segment_dir {
  prompt_segment $segment_style[dir] (-prompt_pwd)
}

fn segment_su {
  uid = (id -u)
  if (eq $uid $root_id) {
    prompt_segment $segment_style[su] $glyph[su]
  }
}

fn segment_timestamp {
  prompt_segment $segment_style[timestamp] (date +$timestamp_format)
}

fn segment_arrow {
  edit:styled $glyph[prompt]" " green
}

# List of built-in segments
segment = [
  &su= $&segment_su
  &dir= $&segment_dir
  &git_branch= $&segment_git_branch
  &git_dirty= $&segment_git_dirty
  &arrow= $&segment_arrow
  &timestamp= $&segment_timestamp
]

fn -interpret-segment [seg]{
  k = (kind-of $seg)
  if (eq $k fn) {
    # If it's a lambda, run it
    $seg
  } elif (eq $k string) {
    if (has-key $segment $seg) {
      # If it's the name of a built-in segment, run its function
      $segment[$seg]
    } else {
      # If it's any other string, return it as-is
      put $seg
    }
  } elif (eq $k styled) {
    # If it's an edit:styled, return it as-is
    put $seg
  }
}

fn -build-chain [segments]{
  first = $true
  output = ""
  for seg $segments {
    time = (-time { output = [(-interpret-segment $seg)] })
    if (> (count $output) 0) {
      if (not $first) {
        -colored $glyph[chain] $segment_style[chain]
      }
      put $@output
      first = $false
    }
  }
}

fn prompt [@skipcheck]{
  put (-build-chain $prompt_segments)
}

fn rprompt [@skipcheck]{
  put (-build-chain $rprompt_segments)
}

fn setup {
  edit:prompt = $&prompt
  edit:rprompt = $&rprompt
}
