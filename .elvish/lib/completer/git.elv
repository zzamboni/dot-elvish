# Completion for git
# Diego Zamboni <diego@zzamboni.org>
# Some code from https://github.com/occivink/config/blob/master/.elvish/rc.elv

commands = [(e:git help -a | grep '^  [a-z]' | tr -s "[:blank:]" "\n" | each [x]{ if (> (count $x) 0) { put $x } })]

# This allows $gitcmd to be a multi-word command and still be executed
# correctly. We cannot simply run "$gitcmd <opts>" because Elvish always
# interprets the first token (the head) to be the command.
# One example of a multi-word $gitcmd is "vcsh <repo>", after which
# any git subcommand is valid.
fn -run-git-cmd [gitcmd @rest]{
	gitcmds = [(splits &sep=" " $gitcmd)]
	if (> (count $gitcmds) 1) {
		$gitcmds[0] (explode $gitcmds[1:]) $@rest
	} else {
		$gitcmds[0] $@rest
	}
}

fn git-completer [gitcmd @rest]{
	n = (count $rest)
	if (eq $n 1) {
		put $@commands
	} else {
		# From https://github.com/occivink/config/blob/master/.elvish/rc.elv
		subcommand = $rest[0]
		if (or (eq $subcommand add) (eq $subcommand stage)) {
			-run-git-cmd $gitcmd diff --name-only
			-run-git-cmd $gitcmd ls-files --others --exclude-standard
		} elif (eq $subcommand discard) {
			-run-git-cmd $gitcmd diff --name-only
		} elif (eq $subcommand unstage) {
			-run-git-cmd $gitcmd diff --name-only --cached
		} elif (or (eq $subcommand checkout) (eq $subcommand co)) {
			-run-git-cmd $gitcmd branch --list --all --format '%(refname:short)'
		}
	}
}

edit:arg-completer[git] = [@args]{ git-completer e:git (explode $args[1:]) }
