#alias:new words cat ~/tmp/slipsum.txt | lorem --words (randint 750 1000) --stdin | pbcopy
fn words [@_args]{ cat ~/tmp/slipsum.txt | lorem --words (randint 750 1000) --stdin | pbcopy $@_args }
