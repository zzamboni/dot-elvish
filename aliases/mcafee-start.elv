#alias:new mcafee-start sudo /usr/local/McAfee/AntiMalware/VSControl startoas
edit:add-var mcafee-start~ [@_args]{ sudo /usr/local/McAfee/AntiMalware/VSControl startoas $@_args }
