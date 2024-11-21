{
  description = "Home Manager configuration with essential packages for M4 Pro Mini";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
  } @ inputs: let
    # System configuration for aarch64-darwin (Apple Silicon)
    system = "aarch64-darwin";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    stdenv = pkgs.stdenv;
    lib = pkgs.lib;
    dockerImages = stdenv.mkDerivation {
      name = "docker verify & pull";
      buildInputs = [
        pkgs.docker
      ];

      preBuild = ''
        images=(
          "postgis/postgis"
          "postgis/postgis:17-3.5-alpine"
          "mysql:9"
          "redis:7-alpine"
          "nginx:1-alpine"
          "alpine:3.20"
          "mongo:8-noble"
          "alpine/jmeter"
          "rabbitmq:4-alpine"
          "node:23-alpine"
          "node:22-alpine"
          "node:20-alpine"
          "python:3.13-alpine"
          "python:3.12-alpine"
          "python:3.10-alpine"
          "amazonlinux:latest"
          )

          existing_images=()

          # Check if each image exists
          for image in "''${images[@]}"; do
              if docker manifest inspect "$image" > /dev/null 2>&1; then
                  echo "Image $image exists, scheduled for installing"
                  existing_images+=("$image")
              else
                  echo "Image $image does NOT exist or is not accessible"
              fi
          done

          # Pull each image that was confirmed to exist
          echo "Starting to pull images..."
          for image in "''${existing_images[@]}"; do
              docker pull "$image"
          done
      '';

      postInstall = ''
        python3.12 -m pip3 install virtualenv;
        python3.12 -m pip3 install django;
        python3.10 -m pip3 install virtualenv;
        docker pull container-registry.oracle.com/database/free/23.5.0.0-arm64
      '';
    };
    # for installing .dmg urls
    RemoteInstall = {
      name,
      url,
      appDir,
    }:
      stdenv.mkDerivation {
        name = name;
        buildInputs = [
          "curl"
          "unzip"
        ];

        preBuild = ''
          images=(
            "postgis/postgis"
            "postgis/postgis:17-3.5-alpine"
            "mysql:9"
            "redis:7-alpine"
            "nginx:1-alpine"
            "alpine:3.20"
            "mongo:8-noble"
            "alpine/jmeter"
            "rabbitmq:4-alpine"
            "node:23-alpine"
            "node:22-alpine"
            "node:20-alpine"
            "python:3.13-alpine"
            "python:3.12-alpine"
            "python:3.10-alpine"
            "amazonlinux:latest"
            container-registry.oracle.com/database/free/23.5.0.0-arm64
            )

            existing_images=()

            # Check if each image exists
            for image in "''${images[@]}"; do
                if docker manifest inspect "$image" > /dev/null 2>&1; then
                    echo "Image $image exists, scheduled for installing"
                    existing_images+=("$image")
                else
                    echo "Image $image does NOT exist or is not accessible"
                fi
            done

            # Pull each image that was confirmed to exist
            echo "Starting to pull images..."
            for image in "''${existing_images[@]}"; do
                docker pull "$image"
            done
        '';
      };
  in {
    defaultPackage.aarch64-darwin = dockerImages;

    nixosConfigurations = {
      "system" = {
        system = "aarch64-darwin";
        networking = {
          wireless.clients = {
            ADSL = {
              ssid = "abcxyz0";
              psk = "SomePassword123";
            };
            Home4G = {
              ssid = "LeOndaz";
              psk = "SomePassword123";
            };
          };
        };
      };
    };

    homeConfigurations.leondaz = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [./users/leondaz/leondaz.nix];
      extraSpecialArgs = {inherit inputs;};
    };
  };
}
