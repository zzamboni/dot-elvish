#alias:new mcafee-stop sudo /usr/local/McAfee/AntiMalware/VSControl stopoas
edit:add-var mcafee-stop~ {|@_args| sudo /usr/local/McAfee/AntiMalware/VSControl stopoas $@_args }
