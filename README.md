### Run

```shell
sh <(curl -L https://nixos.org/nix/install) --daemon
```

```shell
mkdir -p ~/.config/nix
echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```

### Install home manager

```shell
nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

### Restart your terminal, then continue

```shell
mkdir -p ~/.config/nixpkgs
nano ~/.config/nixpkgs/home.nix
```
```shell
home-manager switch --flake .#leondaz
```