# Set up single-user Nix (no daemon)

if (not-eq $E:HOME "") {
  NIX_LINK = ~/.nix-profile
  if (not ?(test -L $NIX_LINK)) {
    echo (edit:styled "creating "$NIX_LINK green) >&2
    _NIX_DEF_LINK = /nix/var/nix/profiles/default
    ln -s $_NIX_DEF_LINK $NIX_LINK
  }
  paths = [
    $NIX_LINK"/bin"
    $NIX_LINK"/sbin"
    $@paths
  ]
  # Subscribe the user to the Nixpkgs channel by default.
  if (not ?(test -e ~/.nix-channels)) {
    echo "https://nixos.org/channels/nixpkgs-unstable nixpkgs" > ~/.nix-channels
  }
  # Append ~/.nix-defexpr/channels/nixpkgs to $NIX_PATH so that
  # <nixpkgs> paths work when the user has fetched the Nixpkgs
  # channel.
  if (not-eq $E:NIX_PATH "") {
    E:NIX_PATH = $E:NIX_PATH":nixpkgs="$E:HOME"/.nix-defexpr/channels/nixpkgs"
  } else {
    E:NIX_PATH = "nixpkgs="$E:HOME"/.nix-defexpr/channels/nixpkgs"
  }

  # Set $NIX_SSL_CERT_FILE so that Nixpkgs applications like curl work.
  if ?(test -e  /etc/ssl/certs/ca-certificates.crt ) { # NixOS, Ubuntu, Debian, Gentoo, Arch
    E:NIX_SSL_CERT_FILE = /etc/ssl/certs/ca-certificates.crt
  } elif ?(test -e  /etc/ssl/ca-bundle.pem ) { # openSUSE Tumbleweed
    E:NIX_SSL_CERT_FILE = /etc/ssl/ca-bundle.pem
  } elif ?(test -e  /etc/ssl/certs/ca-bundle.crt ) { # Old NixOS
    E:NIX_SSL_CERT_FILE = /etc/ssl/certs/ca-bundle.crt
  } elif ?(test -e  /etc/pki/tls/certs/ca-bundle.crt ) { # Fedora, CentOS
    E:NIX_SSL_CERT_FILE = /etc/pki/tls/certs/ca-bundle.crt
  } elif ?(test -e  $NIX_LINK"/etc/ssl/certs/ca-bundle.crt" ) { # fall back to cacert in Nix profile
    E:NIX_SSL_CERT_FILE = $NIX_LINK"/etc/ssl/certs/ca-bundle.crt"
  } elif ?(test -e  $NIX_LINK"/etc/ca-bundle.crt" ) { # old cacert in Nix profile
    E:NIX_SSL_CERT_FILE = $NIX_LINK"/etc/ca-bundle.crt"
  }
}
