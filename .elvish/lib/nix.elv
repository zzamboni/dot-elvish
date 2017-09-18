# Set up environment for Nix

  # Set up secure multi-user builds: non-root users build through the
# Nix daemon.
if (or (not-eq $E:USER root) (not ?(test -w /nix/var/nix/db))) {
  E:NIX_REMOTE = daemon
}

E:NIX_USER_PROFILE_DIR = "/nix/var/nix/profiles/per-user/"$E:USER
E:NIX_PROFILES = "/nix/var/nix/profiles/default "$E:HOME"/.nix-profile"

# Set up the per-user profile.
mkdir -m 0755 -p $E:NIX_USER_PROFILE_DIR
if (not ?(test -O $E:NIX_USER_PROFILE_DIR)) {
  echo (edit:styled "WARNING: bad ownership on $NIX_USER_PROFILE_DIR" yellow) >&2
}

if ?(test -w $E:HOME) {
  if (not ?(test -L $E:HOME/.nix-profile)) {
    if (not-eq $E:USER root) {
      ln -s $E:NIX_USER_PROFILE_DIR/profile $E:HOME/.nix-profile
    } else {
      # Root installs in the system-wide profile by default.
      ln -s /nix/var/nix/profiles/default $E:HOME/.nix-profile
    }
  }

  # Subscribe the root user to the NixOS channel by default.
  if (and (eq $E:USER root) (not ?(test -e $E:HOME/.nix-channels))) {
    echo "https://nixos.org/channels/nixpkgs-unstable nixpkgs" > $E:HOME/.nix-channels
  }

  # Create the per-user garbage collector roots directory.
  NIX_USER_GCROOTS_DIR = "/nix/var/nix/gcroots/per-user/"$E:USER
  mkdir -m 0755 -p $NIX_USER_GCROOTS_DIR
  if (not ?(test -O $NIX_USER_GCROOTS_DIR)) {
    echo (edit:styled "WARNING: bad ownership on $NIX_USER_GCROOTS_DIR" yellow) >&2
  }

  # Set up a default Nix expression from which to install stuff.
  if (or (not ?(test -e $E:HOME/.nix-defexpr)) ?(test -L $E:HOME/.nix-defexpr)) {
    rm -f $E:HOME/.nix-defexpr
    mkdir -p $E:HOME/.nix-defexpr
    if (not-eq $E:USER root) {
      ln -s /nix/var/nix/profiles/per-user/root/channels $E:HOME/.nix-defexpr/channels_root
    }
  }
}

E:NIX_SSL_CERT_FILE = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt"
E:NIX_PATH = "/nix/var/nix/profiles/per-user/root/channels"
paths = [
  ~/.nix-profile/bin
  ~/.nix-profile/sbin
  ~/.nix-profile/lib/kde4/libexec
  /nix/var/nix/profiles/default/bin
  /nix/var/nix/profiles/default/sbin
  /nix/var/nix/profiles/default/lib/kde4/libexec
  $@paths
]

#echo (edit:styled "Nix environment ready" green)
