# Alias management
# Diego Zamboni <diego@zzamboni.org>
#
# Usage:
#
# - In your rc.elv, add `use alias`
# - To define an alias: `alias:def alias command`
# - To list existing aliases: `alias:list`
# - To remove an alias: `alias:undef alias`
#   NOTE: the change will only take effect in future shells
#
# Each alias is stored in a separate file under $alias:dir
# (~/.elvish/aliases by default).

dir = ~/.elvish/aliases

fn list {
  _ = ?(grep '^#alias:def ' $dir/*.elv | sed 's/^.*#//')
}

fn def [name @cmd]{
  file = $dir/$name.elv
  echo "#alias:def" $name $@cmd > $file
  echo fn $name '[@_args]{' $@cmd '$@_args }' >> $file
  echo (edit:styled "Defining alias "$name green)
  is_ok = ?(-source $file)
  if (not $is_ok) {
    echo (edit:styled "Your alias definition has a syntax error. Please recheck it.\nError: "(echo $is_ok) red)
    rm $file
  }
}

fn undef [name]{
  file = $dir/$name.elv
  if ?(test -f $file) {
    echo (edit:styled "Removing file for alias "$name". The change will take effect in new shells only." yellow)
    rm $file
  } else {
    echo (edit:styled "Alias "$name" does not exist.")
  }
}

# Init code, run when the library is loaded

# Create alias directory if it doesn't exist
if (not ?(test -d $dir)) {
  mkdir -p $dir
}

# Load all the existing alias definitions
for file [(_ = ?(put $dir/*.elv))] {
  is_ok = ?(-source $file)
  if (not $is_ok) {
    echo (edit:styled "Error when loading alias file "$file" - please check it." red)
  }
}
