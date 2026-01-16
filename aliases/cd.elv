#alias:new cd &use=[github.com/zzamboni/elvish-modules/dir] dir:cd
edit:add-var cd~ {|@_args|  use github.com/zzamboni/elvish-modules/dir; dir:cd $@_args }
