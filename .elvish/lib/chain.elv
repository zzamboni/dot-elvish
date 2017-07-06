# Initialize glyphs to be used in the prompt.
prompt_glyph=">"
git_branch_glyph="⎇"
git_dirty_glyph="±"
chain_su_glyph="⚡"

fn prompt_segment {
   color @rest = $@args
   text = "["(echo $@rest)"]-"
   edit:styled $text $color
}

fn is_git_repo {
   put ?(git status 2>/dev/null >/dev/null)
}

fn git_branch_name {
   if (is_git_repo) {
     echo (git symbolic-ref HEAD 2>/dev/null | sed -e "s|^refs/heads/||")
   } else {
     echo ""
   }
}

fn is_git_dirty {
   put (and (is_git_repo) (not (eq "" (command git status -s --ignore-submodules=dirty 2>/dev/null))))
}

fn prompt_root {
   uid=(id -u $E:USER)
   if (eq (id -u $E:USER) 0) {
     prompt_segment yellow $chain_su_glyph
   } else {
     put ""
   }
}

fn prompt_dir {
   prompt_segment cyan (tilde-abbr $pwd)
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
   chain:prompt_root
   chain:prompt_dir
   chain:prompt_git
   chain:prompt_arrow
}

fn rprompt {
   put ""
}
