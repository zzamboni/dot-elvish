#alias:new dfc e:dfc -p '-/dev/disk1s4,devfs,map,com.apple.TimeMachine'
edit:add-var dfc~ [@_args]{ e:dfc -p '-/dev/disk1s4,devfs,map,com.apple.TimeMachine' $@_args }
