#alias:new turbo-disable sudo kextunload -v /Applications/Turbo Boost Switcher.app/Contents/Resources/DisableTurboBoost.64bits.kext
fn turbo-disable [@_args]{ sudo kextunload -v '/Applications/Turbo Boost Switcher.app/Contents/Resources/DisableTurboBoost.64bits.kext' $@_args }
