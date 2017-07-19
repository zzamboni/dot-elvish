# Completion for git
# Diego Zamboni <diego@zzamboni.org>
# Some code from https://github.com/occivink/config/blob/master/.elvish/rc.elv

fn git-completer [gitcmd @rest]{
	n = (count $rest)
	if (eq $n 1) {
		cmds = [($gitcmd help -a | grep '^  [a-z]' | tr -s "[:blank:]" "\n" | each [x]{ if (> (count $x) 0) { put $x } })]
		put $@cmds
	} else {
		# From https://github.com/occivink/config/blob/master/.elvish/rc.elv
		subcommand = $rest[0]
		if (or (eq $subcommand add) (eq $subcommand stage)) {
			$gitcmd diff --name-only
			$gitcmd ls-files --others --exclude-standard
		} elif (eq $subcommand discard) {
			$gitcmd diff --name-only
		} elif (eq $subcommand unstage) {
			$gitcmd diff --name-only --cached
		} elif (or (eq $subcommand checkout) (eq $subcommand co)) {
			$gitcmd branch --list --all --format '%(refname:short)'
		}
	}
}

edit:arg-completer[git] = [@args]{ git-completer $@args }
