# Elvish themes

## chain

Chain prompt theme, based on the fish theme at https://github.com/oh-my-fish/theme-chain

Ported to Elvish by Diego Zamboni <diego@zzamboni.org>

To use, put this file in ~/.elvish/lib/ and add the following to your ~/.elvish/rc.elv file:

    use chain
    chain:setup

You can also assign the prompt functions manually instead of calling `chain:setup`:

    edit:prompt = $chain:&prompt
    edit:rprompt = $chain:&rprompt

The chains on both sides can be configured by assigning to
`theme:chain:prompt_segments` and `theme:chain:rprompt_segments`,
respectively. These variables must be arrays, and the given segments
will be automatically linked by `$theme:chain:glyph[chain]`. Each
element can be any of the following:

- The name of one of the built-in segments. Available segments:
  `arrow` `timestamp` `su` `dir` `git_branch` `git_dirty`
- A string or the output of `edit:styled`, which will be displayed
  as-is.
- A lambda, which will be called and its output displayed
- The output of a call to `theme:chain:segment <style> <strings>`,
  which returns a "proper" segment, enclosed in square brackets and
  styled as requested.

Default values (all can be configured by assigning to the appropriate variable):

- Prompt configurations
```
prompt_segments = [ su dir git_branch git_dirty arrow ]
rprompt_segments = [ ]
  ```
- Glyphs to be used in the prompt
```
glyph = [
	&prompt= ">"
	&git_branch= "⎇"
	&git_dirty= "±"
	&su= "⚡"
	&chain= "─"
]
```
- Styling for each built-in segment. The value must be a valid argument to `edit:styled`
```
segment_style = [
	&chain= default
	&su= yellow
	&dir= cyan
	&git_branch= blue
	&git_dirty= yellow
	&timestamp= gray
]
```
- To how many letters to abbreviate directories in the path - 0 to show in full.
  The default of 1 results in something like `~/D/P/d/g/s/g/e/elvish` for a long
  path of `~/Dropbox/Personal/devel/go/src/github.com/elves/elvish`
```
prompt_pwd_dir_length = 1
```
- Format to use for the 'timestamp' segment,
  in [strftime(3)](http://man7.org/linux/man-pages/man3/strftime.3.html) format
```
timestamp_format = "%R"
```
- User ID that will trigger the display of the "su" segment. Defaults to root.
```
root_id=0
```
