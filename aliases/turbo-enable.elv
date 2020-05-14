#alias:new turbo-enable sudo kextutil -v /Applications/Turbo Boost Switcher.app/Contents/Resources/DisableTurboBoost.64bits.kext
fn turbo-enable [@_args]{ sudo kextutil -v '/Applications/Turbo Boost Switcher.app/Contents/Resources/DisableTurboBoost.64bits.kext' $@_args }
