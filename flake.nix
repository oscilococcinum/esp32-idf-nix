# https://specific.solutions.limited/projects/hanging-plotter/electronics
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    esp32-idf-src = {
      type = "github";
      owner = "espressif";
      repo = "esp-idf";
      rev  = "v4.1-dev";
      fetchSubmodules = true;
      flake = false;
#      sha256 = "0d1iqxz1jqz3rrk2c5dq33wp1v71d9190wv3bnigxlp5kcsj0j1w";
    };
    esp32-toolchain-src = {
      url = "https://dl.espressif.com/dl/xtensa-esp32-elf-gcc8_2_0-esp-2019r2-linux-amd64.tar.gz";
      sha256 = "1pzv1r9kzizh5gi3gsbs6jg8rs1yqnmf5rbifbivz34cplfprm76";
      flake = false;
    };
  };

  outputs = { nixpkgs, ... }@inputs: {

    packages = builtins.listToAttrs (map (system: {
        name = system;
        value = with import nixpkgs { inherit system; config.allowUnfree = true; }; rec {

          esp32-idf = pkgs.callPackage (import ./esp32-idf.nix) { src = inputs.esp32-idf-src;  pname = "esp-idf"; version = inputs.esp32-idf-src.rev; };

          esp32-toolchain = pkgs.callPackage (import ./esp32-toolchain.nix) { src = inputs.esp32-toolchain-src;  pname = "esp32-toolchain"; version = "2019r2"; };

        };
      })[ "x86_64-linux" ]);

    devShells= builtins.listToAttrs (map (system: {
        name = system;
        value = with import nixpkgs { inherit packages system; config.allowUnfree = true; }; rec {

          esp32-idf-devShell = pkgs.mkShell {
            buildInputs = [
              packages.${system}.esp-idf
              packages.${system}.esp32-toolchain
            ];
            shellHook = ''
              set -e
              
              export IDF_PATH=${esp-idf}
              
              export NIX_CFLAGS_LINK=-lncurses
              export PATH=$PATH:$IDF_PATH/tools
            '';
          };

          default = esp32-devShell;
        };
      })[ "x86_64-linux" ]);
  };
}