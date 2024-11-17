{
  pkgs,
  config,
  lib,
  system,
  ...
}:
{
  home.homeDirectory = "/Users/leondaz";
  home.stateVersion = "24.11";
  home.username = "leondaz";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    # lsps
    nixd
    alejandra

    # Development Tools
    autoconf
    automake
    aws-sdk-cpp
    boost
    cmake
    eigen
    gcc
    git
    git-lfs
    gradle
    llvm
    neovim
    nodejs
    openssl
    protobuf

    terraform
    yarn
    zlib
    kubectl

    # Libraries
    cairo
    # gdal
    # glib
    gmp
    harfbuzz
    hdf5
    icu
    libarchive
    libevent
    libffi
    libgit2
    libpng
    libssh
    libxml2
    libyaml
    openssl
    sqlite
    xz
    zstd

    # Utilities
    bat
    brotli
    bzip2
    curl
    fzf
    gh
    htop
    httpie
    jq
    lz4
    p7zip
    tree
    unzip
    wget
    xclip
    zip

    # rt
    bun

    # Media Libraries
    ffmpeg-full

    # Programming Languages
    ruby
    go
    luajit
    luarocks
  ];

  programs.java = {
    enable = true;
    package = pkgs.jdk21;
  };
}
