#alias:new turbo-status kextstat | grep com.rugarciap.DisableTurboBoost
fn turbo-status [@_args]{ if ?(kextstat | grep com.rugarciap.DisableTurboBoost $@_args > /dev/null) { echo (styled "Disabled (kext loaded)" green) } else { echo (styled "Enabled (kext not loaded)" red) } }
