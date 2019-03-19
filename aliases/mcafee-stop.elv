#alias:new mcafee-stop sudo /usr/local/McAfee/AntiMalware/VSControl stopoas
fn mcafee-stop [@_args]{ sudo /usr/local/McAfee/AntiMalware/VSControl stopoas $@_args }
