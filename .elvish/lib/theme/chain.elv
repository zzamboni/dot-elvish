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
#
# The chains on both sides can be configured by assigning to `theme:chain:prompt_segments` and
# `theme:chain:rprompt_segments`, respectively. These variables must be arrays, and the given
# segments will be automatically linked by `$theme:chain:glyph[chain]`. Each element can be any
# of the following:
#
# - The name of one of the built-in segments. Available segments: `arrow` `timestamp` `su` `dir` `git_branch` `git_dirty`
# - A string or the output of `edit:styled`, which will be displayed as-is.
# - A lambda, which will be called and its output displayed
# - The output of a call to `theme:chain:segment <style> <strings>`, which returns a "proper" segment, enclosed in
#   square brackets and styled as requested.
#

# Default values (all can be configured by assigning to the appropriate variable):

# Configurable prompt segments for each prompt
prompt_segments = [ su dir git_branch git_dirty arrow ]
rprompt_segments = [ ]

# Glyphs to be used in the prompt
glyph = [
	&prompt= ">"
	&git_branch= "⎇"
	&git_dirty= "±"
	&su= "⚡"
	&chain= "─"
]

# Styling for each built-in segment. The value must be a valid argument to `edit:styled`
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
root_id = 0

# Cached generated prompt - since arbitrary commands can be executed, we compute
# the prompt only before displaying it and not on every keystroke, and we cache
# the prompts here.
cached_prompt = [ ]
cached_rprompt = [ ]

######################################################################

# Internal function to return a styled string, or plain if color == "default"
fn -colored [what color]{
	if (!=s $color default) {
		edit:styled $what $color
	} else {
		put $what
	}
}

# Build a prompt segment in the given style, surrounded by square brackets
fn prompt_segment [style @texts]{
	text = "["(joins ' ' $texts)"]"
	-colored $text $style
}

# Check if the current directory is a git repo
fn is_git_repo {
	put ?(git status 2>/dev/null >/dev/null)
}

# Return the git branch name of the current directory
fn -git_branch_name {
	if (is_git_repo) {
		git symbolic-ref HEAD 2>/dev/null | sed -e "s|^refs/heads/||"
	}
}

# Return whether the current git repo is "dirty" (modified in any way)
fn -git_is_dirty {
	and (is_git_repo) (not (eq "" (git status -s --ignore-submodules=dirty 2>/dev/null)))
}

# Return the current directory, shortened according to `$prompt_pwd_dir_length`
fn -prompt_pwd {
	tmp = (tilde-abbr $pwd)
	if (== $prompt_pwd_dir_length 0) {
		put $tmp
	} else {
		re:replace '(\.?[^/]{'$prompt_pwd_dir_length'})[^/]*/' '$1/' $tmp
	}
}

######################################################################
# Built-in chain segments

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

# Given a segment specification, return the appropriate value, depending
# on whether it's the name of a built-in segment, a lambda, a string
# or an edit:styled
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

# Return a string of values, including the appropriate chain connectors
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

fn generate_prompt { cached_prompt = [(-build-chain $prompt_segments)] }
fn generate_rprompt { cached_rprompt = [(-build-chain $rprompt_segments)] }

# Prompt and rprompt functions
fn prompt { put $@cached_prompt }
fn rprompt { put $@cached_rprompt }

# Default setup, assigning our functions to `edit:prompt` and `edit:rprompt`
fn setup {
  edit:before-readline=[ $@edit:before-readline $&generate_prompt ]
  edit:prompt = $&prompt
  edit:rprompt = $&rprompt
}
