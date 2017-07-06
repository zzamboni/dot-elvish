# Chain prompt theme, based on the fish theme at https://github.com/oh-my-fish/theme-chain
# Ported to Elvish by Diego Zamboni <diego@zzamboni.org>
# To use, put this file in ~/.elvish/lib/ and add the following to your ~/.elvish/rc.elv file:
#   use chain
#   edit:prompt=chain:prompt
#   edit:rprompt=chain:rprompt

# Initialize glyphs to be used in the prompt.
prompt_glyph = ">"
git_branch_glyph = "⎇"
git_dirty_glyph = "±"
chain_su_glyph = "⚡"
# To how many letters to abbreviate directories in the path - 0 to show in full
prompt_pwd_dir_length = 1

fn prompt_segment [style @texts]{
   text = "["(joins ' ' $texts)"]-"
   edit:styled $text $style
}

fn is_git_repo {
   put ?(git status 2>/dev/null >/dev/null)
}

fn git_branch_name {
   if (is_git_repo) {
     git symbolic-ref HEAD 2>/dev/null | sed -e "s|^refs/heads/||"
   } else {
     echo ""
   }
}

fn is_git_dirty {
   and (is_git_repo) (not (eq "" (git status -s --ignore-submodules=dirty 2>/dev/null)))
}

fn prompt_root {
   uid = (id -u)
   if (eq $uid 0) {
     prompt_segment yellow $chain_su_glyph
   } else {
     put ""
   }
}

fn prompt_pwd {
  tmp = (tilde-abbr $pwd)
  if (== $prompt_pwd_dir_length 0) {
    put $tmp
  } else {
    re:replace '(\.?[^/]{'$prompt_pwd_dir_length'})[^/]*/' '$1/' $tmp
  }
}

fn prompt_dir {
   prompt_segment cyan (prompt_pwd)
}

fn prompt_git {
   if (is_git_repo) {
      prompt_segment blue $git_branch_glyph (git_branch_name)
      if (is_git_dirty) {
         prompt_segment yellow $git_dirty_glyph
      }
   }
}

fn prompt_arrow {
   edit:styled $prompt_glyph" " green
   # Is it possible to get the status of the last command? I'm still not clear on elvish's exceptions concept
}

# function __chain_prompt_arrow
#   if test $last_status = 0
#     set_color green
#   else
#     set_color red
#     echo -n "($last_status)-"
#   end

#   echo -n "$chain_prompt_glyph "
# end

fn prompt {
   prompt_root
   prompt_dir
   prompt_git
   prompt_arrow
}

fn rprompt {
   put ""
}
