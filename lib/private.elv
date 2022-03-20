# Private stuff that should not be checked into git

use re
use str
use github.com/zzamboni/elvish-modules/util

######################################################################
# Some utility functions I wrote for cleaning up old maildir-format
# directories

fn maildir-cleanup {
  du -cka | sort -rn | tail -n +3 | eawk {|line size f|
    echo $f
    less -p Subject: -i $f
    if (util:y-or-n &style=yellow "Remove "$f"?") {
      rm $f
    }
  }
}

fn search-remove {|s|
  ag -l $s | each {|f| echo "Removing "$f; rm $f }
}

######################################################################

# # Proof of concept for executing the last command if Enter is pressed on an empty line
# fn last-cmd-if-enter {
#   lastcmd = [(edit:command-history)][-1][cmd]
#   if (eq $edit:current-command "") {
#     edit:current-command = $lastcmd
#   }
#   edit:smart-enter
# }

# edit:insert:binding[Enter] = $last-cmd-if-enter~

######################################################################

# List filenames invalid for myCloud, according to https://help.mycloud.ch/hc/en-us/articles/115001201914-Technical-limitations
# Optional args: directories to search, defaults to current directory
fn mycloud-invalid {|@p|
  if (eq $p []) { set p = [ . ] }
  put (find $@p -name '.*' -o -name '*[<>:"|?*/\]*' | all)
}

fn onedrive-invalid {|@p|
  if (eq $p []) { set p = [ . ] }
  put (find $@p -name '*["*:<>?/\|]*' | all)
}

######################################################################

# Generate between 750 and 1000 words and copy them to the clipboard
fn words {
  var slipsum = "Normally, both your asses would be dead as fucking fried
  chicken, but you happen to pull this shit while I'm in a
  transitional period so I don't wanna kill you, I wanna help you. But
  I can't give you this case, it don't belong to me. Besides, I've
  already been through too much shit this morning over this case to
  hand it over to your dumb ass. Well, the way they make shows is,
  they make one show. That show's called a pilot. Then they show that
  show to the people who make shows, and on the strength of that one
  show they decide if they're going to make more shows. Some pilots
  get picked and become television programs. Some don't, become
  nothing. She starred in one of the ones that became nothing. The
  path of the righteous man is beset on all sides by the iniquities of
  the selfish and the tyranny of evil men. Blessed is he who, in the
  name of charity and good will, shepherds the weak through the valley
  of darkness, for he is truly his brother's keeper and the finder of
  lost children. And I will strike down upon thee with great vengeance
  and furious anger those who would attempt to poison and destroy My
  brothers. And you will know My name is the Lord when I lay My
  vengeance upon thee. Do you see any Teletubbies in here? Do you see
  a slender plastic tag clipped to my shirt with my name printed on
  it? Do you see a little Asian child with a blank expression on his
  face sitting outside on a mechanical helicopter that shakes when you
  put quarters in it? No? Well, that's what you see at a toy
  store. And you must think you're in a toy store, because you're here
  shopping for an infant named Jeb. Your bones don't break, mine
  do. That's clear. Your cells react to bacteria and viruses
  differently than mine. You don't get sick, I do. That's also
  clear. But for some reason, you and I react the exact same way to
  water. We swallow it too fast, we choke. We get some in our lungs,
  we drown. However unreal it may seem, we are connected, you and
  I. We're on the same curve, just on opposite ends. Now that we know
  who you are, I know who I am. I'm not a mistake! It all makes sense!
  In a comic, you know how you can tell who the arch-villain's going
  to be? He's the exact opposite of the hero. And most times they're
  friends, like you and me! I should've known way back when... You
  know why, David? Because of the kids. They called me Mr Glass. You
  think water moves fast? You should see ice. It moves like it has a
  mind. Like it knows it killed the world once and got a taste for
  murder. After the avalanche, it took us a week to climb out. Now, I
  don't know exactly when we turned on each other, but I know that
  seven of us survived the slide... and only five made it out. Now we
  took an oath, that I'm breaking now. We said we'd say it was the
  snow that killed the other two, but it wasn't. Nature is lethal but
  it doesn't hold a candle to man. Look, just because I don't be
  givin' no man a foot massage don't make it right for Marsellus to
  throw Antwone into a glass motherfuckin' house, fuckin' up the way
  the nigger talks. Motherfucker do that shit to me, he better
  paralyze my ass, 'cause I'll kill the motherfucker, know what I'm
  sayin'? Now that there is the Tec-9, a crappy spray gun from South
  Miami. This gun is advertised as the most popular gun in American
  crime. Do you believe that shit? It actually says that in the little
  book that comes with it: the most popular gun in American
  crime. Like they're actually proud of that shit. My money's in that
  office, right? If she start giving me some bullshit about it ain't
  there, and we got to go someplace else and get it, I'm gonna shoot
  you in the head then and there. Then I'm gonna shoot that bitch in
  the kneecaps, find out where my goddamn money is. She gonna tell me
  too. Hey, look at me when I'm talking to you, motherfucker. You
  listen: we go in there, and that nigga Winston or anybody else is in
  there, you the first motherfucker to get shot. You understand?"

  var lorem-options = [ lorem boccaccio faust fleurs strindberg spook poe strandberg bible walden slipsum ]

  var option = $lorem-options[(randint 0 (count $lorem-options))]

  if (eq $option slipsum) {
    echo $slipsum | lorem --words (randint 750 1000) --stdin
  } else {
    lorem --$option --words (randint 750 1000)
  }
}

fn words-copy {
  words | pbcopy
}

# Filter the command history through the fzf program. This is normally bound
# to Ctrl-R.
fn history {||
  var new-cmd = (
    edit:command-history &dedup &newest-first &cmd-only |
    to-terminated "\x00" |
    try {
      fzf --no-sort --read0 --layout=reverse --info=hidden --exact ^
        --query=$edit:current-command
    } catch {
      # If the user presses [Escape] to cancel the fzf operation it will exit
      # with a non-zero status. Ignore that we ran this function in that case.
      return
    }
  )
  set edit:current-command = $new-cmd
}

set edit:insert:binding[Ctrl-R] = {|| history >/dev/tty 2>&1 }

fn update-emacs {
  var app-dir = ~/Applications
  var build-tool-dir = $app-dir/build-emacs-for-macos
  var builds-dir = $build-tool-dir/builds
  cd $build-tool-dir
  echo (styled "==> Building Emacs" green)
  ./build-emacs-for-macos --rsvg feature/native-comp
  var build = [(/bin/ls -rt $builds-dir)][-1]
  echo (styled "==> Found new build: "$build green)
  echo (styled "==> Backing up current Emacs.app" green)
  cd $app-dir
  tar jcvf Emacs.app.(date +'%Y-%m-%d').tar.bz2 Emacs.app
  rm -rf Emacs.app
  echo (styled "==> Unpacking new Emacs.app" green)
  tar jxvf $builds-dir/$build
}

fn qst-request {|params|
  set params = [(keys $params | each {|k| put "--data-urlencode" $k"="$params[$k] })]
  curl -G -s $@params https://www.accurity.ch/qst/json.jsp | from-json
}

fn qst-data {|income &kanton=zh &rateCode=B &nrDependents=2 &churchTax=$true|
  var data = [
    &taxableIncome= $income
    &kanton= $kanton
    &rateCode= $rateCode
    &nrDependents= $nrDependents
    &churchTaxFlag= [&$true=Y &$false=N][$churchTax]
  ]
  qst-request $data
}

fn qst-rate {|income &kanton=zh &rateCode=B &nrDependents=2 &churchTax=$true|
  put (qst-data $income &kanton=$kanton &rateCode=$rateCode &nrDependents=$nrDependents &churchTax=$churchTax)[taxPercent]
}

fn qst-line {|min max rate|
  echo $min,$max,$rate
}

fn qst-table {|&kanton=zh &rateCode=B &nrDependents=2 &churchTax=$true|
  qst-line 0 800 (qst-rate 800 &kanton=$kanton &rateCode=$rateCode &nrDependents=$nrDependents &churchTax=$churchTax)
  range &step=50 850 16001 | each {|n|
    qst-line (- $n 49) $n (qst-rate $n &kanton=$kanton &rateCode=$rateCode &nrDependents=$nrDependents &churchTax=$churchTax)
    sleep 0.1
  }
  range &step=2000 18000 20001 | each {|n|
    qst-line (- $n 1999) $n (qst-rate $n &kanton=$kanton &rateCode=$rateCode &nrDependents=$nrDependents &churchTax=$churchTax)
    sleep 0.1
  }
  range &step=2000 25000 50001 | each {|n|
    qst-line (- $n 4999) $n (qst-rate $n &kanton=$kanton &rateCode=$rateCode &nrDependents=$nrDependents &churchTax=$churchTax)
    sleep 0.1
  }
  qst-line 50001 100000 (qst-rate 100000 &kanton=$kanton &rateCode=$rateCode &nrDependents=$nrDependents &churchTax=$churchTax)
  sleep 0.1
  qst-line 100000 "" (qst-rate 100001 &kanton=$kanton &rateCode=$rateCode &nrDependents=$nrDependents &churchTax=$churchTax)
}

fn capture {|f|
  var pout = (file:pipe)
  var perr = (file:pipe)
  var out err
  run-parallel {
    $f > $pout[w] 2> $perr[w]
    file:close $pout[w]
    file:close $perr[w]
  } {
    set out = (slurp < $pout[r])
    file:close $pout[r]
  } {
    set err = (slurp < $perr[r])
    file:close $perr[r]
  }
  put $out $err
}

# Convert POSIX env assignments to Elvish
fn read-posix-envvars {
  each {|l|
    var _ key val = (re:split &max=3 '[ =]' $l)
    set-env $key $val
  }
}

# Emulate the POSIX export command
fn export {|s|
  set-env (str:split &max=2 '=' $s)
}
edit:add-var export~ $export~

# Run the auto-mute-spotify script and convert its output into notifications
fn auto-mute-spotify {
  cd ~/bin/mute-spotify-ads-mac-osx
  sh NoAdsSpotify.sh | each { |l|
    echo $l
    if (re:match '^>>' $l) {
      terminal-notifier -title "NoAdsSpotify" -message $l
    }
  }
}
edit:add-var auto-mute-spotify~ $auto-mute-spotify~

# Generate sample outputs for starship remote_url prompt segment.
# I use this to generate the screenshot for uploading to
# https://github.com/starship/starship/discussions/1252#discussioncomment-838901
fn starship-remote-url-samples {
  var set-url = [ remote set-url origin ]
  var samples = [
    [ [ init ] "Repo without remote" ]
    [ [ remote add origin  https://github.com/zzamboni/dot-elvish.git ] "GitHub HTTPS remote" ]
    [ [ $@set-url git@github.com:zzamboni/dot-elvish.git ]     "GitHub SSH remote" ]
    [ [ $@set-url https://gitlab.com/zzamboni/dot-elvish.git ] "GitLab HTTPS remote" ]
    [ [ $@set-url https://bitbucket.org/zzamboni/dot-emacs ]   "BitBucket HTTPS remote" ]
    [ [ $@set-url codecommit::eu-west-1://repo-name ]          "AWS CodeCommit remote"]
    [ [ $@set-url ssh://git@git.k8s.lan:2222/ttys3/tekton-golang-demo.git ] "SSH remote with port number" ]
    [ [ $@set-url https://some-random-remote.com ]            "Some other remote" ]
  ]
  # Compute space filler to align messages
  var fill-length = 0
  each {|p|
    var str = "git "(str:join " " $p[0])
    if (> (count $str) $fill-length) {
      set fill-length = (count $str)
    }
  } $samples
  var padding = 1
  set fill-length = (+ $fill-length $padding)
  var filler = (str:join '' [(repeat $fill-length ' ')])

  var show~ = {|cmd msg|
    starship prompt
    if $cmd {
      var str = "git "(str:join " " $cmd)
      print (styled git green) $@cmd $filler[..(- $fill-length (count $str))]
    }
    if $msg {
      print (styled " # "$msg cyan)
    }
    echo ""
  }

  cd ~
  rm -rf testrepo
  mkdir testrepo
  cd testrepo
  echo ""
  each {|pair|
    show $@pair
    var output = (git (all $pair[0]) | slurp)
    if (!=s $output "") {
      print $output
    }
  } $samples
  starship prompt

  echo ""
  echo ""
  cd ..
  rm -rf testrepo
}

# Tangle/detangle Org files from the command line
#
fn detangle-file { |f|
  echo "### "$f
  emacs --batch --eval "(require 'org)" --eval '(progn (setq-default indent-tabs-mode nil) (org-babel-detangle "'$f'") (save-some-buffers t))'
}

fn tangle-file { |f2|
  echo "### "$f2
  emacs --batch -l org --eval '(progn (setq-default comment-start "# ") (org-babel-tangle-file "'$f2'"))'
}

use path

fn tangle-all-org-files {
  echo (styled "Tangling all org files with link comments..." blue)
  put *.elv | each {|f| var f2 = (basename $f .elv).org; if (path:is-regular $f2) { tangle-file $f2 } }
}

fn convert-org-files-to-v17 {
  echo (styled "Modifying org files to include link comments..." blue)
  sed -i.bak 's/:comments no/:comments link/' *.org
  tangle-all-org-files
  echo (styled "Upgrading scripts for Elvish v0.17..." blue)
  upgrade-scripts-for-0.17 -lambda -w **[type:regular].elv
  echo (styled "Untangling elv files back into the org files..." blue)
  put *.elv | each {|f| detangle-file $f }
}

fn finish-convert-org-files-to-v17 {
  echo (styled "Modifying org files to not include link comments..." blue)
  sed -i.bak 's/:comments link/:comments no/' *.org
  tangle-all-org-files
}
