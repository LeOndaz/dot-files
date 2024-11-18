# nix home on my new darwin :)

## installation

these instructions result in a standalone install of home-manager based on
flakes instead of the channels-based instructions in the official docs. this
method also assumes you're applying this repo on the first run, not generating
a home definition.

### install the nix cli with sane default config

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
  sh -s -- install
```

### apply home-manager for the first time

```sh
NIXPKGS_ALLOW_UNFREE=1 nix run \
  home-manager -- switch --impure --flake github:leondaz/dot-files
```

### to start working with dirty trees

run this once

```sh
git clone \
  git@github.com:LeOndaz/dot-files.git \
  dot-files
cat <<EOF >>~/.zshrc
alias home-switch='home-manager switch --flake "$PWD"/dot-files'
. "\$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
EOF
```

then make changes to your local clone of `dot-files` and run `home-switch` to 
apply them
