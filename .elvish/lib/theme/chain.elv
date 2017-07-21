# Chain prompt theme, based on the fish theme at https://github.com/oh-my-fish/theme-chain
# Ported to Elvish by Diego Zamboni <diego@zzamboni.org>
#
# To use, put this file in ~/.elvish/lib/ and add the following to your ~/.elvish/rc.elv file:
#   use chain
#   chain:setup
#
# You can also assign the prompt functions manually instead of calling `chain:setup`:
#   edit:prompt = $chain:&prompt
#   edit:rprompt = $chain:&rprompt

# Configurable prompt segments for each prompt
# Available segments: arrow timestamp su dir git_branch git_dirty
prompt_segments = [ su dir git_branch git_dirty arrow ]
rprompt_segments = [ ]

# Initialize glyphs to be used in the prompt.
glyph = [
	&prompt= ">"
	&git_branch= "⎇"
	&git_dirty= "±"
	&su= "⚡"
	&chain= "─"
]

segment_style = [
	&chain= default
	&su= yellow
	&dir= cyan
	&git_branch= blue
	&git_dirty= yellow
	&timestamp= gray
]

# To how many letters to abbreviate directories in the path - 0 to show in full
prompt_pwd_dir_length = 1

# Format to use for the 'timestamp' segment, in strftime(3) format
timestamp_format = "%R"

# User ID that will trigger the "su" segment. Defaults to root.
root_id=0

fn -colored [what color]{
	if (!=s $color default) {
		edit:styled $what $color
	} else {
		put $what
	}
}

fn prompt_segment [style @texts]{
	text = "["(joins ' ' $texts)"]"
	-colored $text $style
}

fn is_git_repo {
	put ?(git status 2>/dev/null >/dev/null)
}

fn -git_branch_name {
	if (is_git_repo) {
		git symbolic-ref HEAD 2>/dev/null | sed -e "s|^refs/heads/||"
	}
}

fn -git_is_dirty {
	and (is_git_repo) (not (eq "" (git status -s --ignore-submodules=dirty 2>/dev/null)))
}

fn -prompt_pwd {
	tmp = (tilde-abbr $pwd)
	if (== $prompt_pwd_dir_length 0) {
		put $tmp
	} else {
		re:replace '(\.?[^/]{'$prompt_pwd_dir_length'})[^/]*/' '$1/' $tmp
	}
}

fn segment_su {
	uid = (id -u)
	if (eq $uid $root_id) {
		prompt_segment $segment_style[su] $glyph[su]
	}
}

fn segment_dir {
	prompt_segment $segment_style[dir] (-prompt_pwd)
}

fn segment_git_branch {
	if (is_git_repo) {
		prompt_segment $segment_style[git_branch] $glyph[git_branch] (-git_branch_name)
	}
}

fn segment_git_dirty {
	if (and (is_git_repo) (-git_is_dirty)) {
		prompt_segment $segment_style[git_dirty] $glyph[git_dirty]
	}
}

fn segment_arrow {
	edit:styled $glyph[prompt]" " green
	# Is it possible to get the status of the last command? I'm still not clear on elvish's exceptions concept
}

fn segment_timestamp {
	prompt_segment $segment_style[timestamp] (date +$timestamp_format)
}

# List of built-in segments
segment = [
	&su= $&segment_su
	&dir= $&segment_dir
	&git_branch= $&segment_git_branch
	&git_dirty= $&segment_git_dirty
	&arrow= $&segment_arrow
	&timestamp= $&segment_timestamp
]

fn -interpret-segment [seg]{
	k = (kind-of $seg)
	if (eq $k fn) {
		# If it's a lambda, run it
		$seg
	} elif (eq $k string) {
		if (has-key $segment $seg) {
			# If it's the name of a built-in segment, run its function
			$segment[$seg]
		} else {
			# If it's any other string, return it as-is
			put $seg
		}
	} elif (eq $k styled) {
		# If it's an edit:styled, return it as-is
		put $seg
	}
}

fn -build-chain [segments]{
	first = $true
	for seg $segments {
		output = [(-interpret-segment $seg)]
		if (> (count $output) 0) {
			if (not $first) {
				-colored $glyph[chain] $segment_style[chain]
			}
			put $@output
			first = $false
		}
	}
}

fn prompt { -build-chain $prompt_segments }
fn rprompt { -build-chain $rprompt_segments }

fn setup {
	edit:prompt = $&prompt
	edit:rprompt = $&rprompt
}
