{
  description = "C++ Hello World - Static Build";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        static = nixpkgs.legacyPackages.${system};
        staticGcc = static.pkgsStatic.gcc;
        staticGccBin = "${staticGcc}/bin";
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "hello-world";
          version = "1.0.0";
          src = ./.;
          nativeBuildInputs = [ pkgs.gcc ];
          buildPhase = ''
            g++ -std=c++17 -Wall -Wextra -I include -o main ./src/*.cpp
          '';
          installPhase = ''
            mkdir -p $out/bin
            cp main $out/bin/
          '';
        };

        packages.static = pkgs.stdenv.mkDerivation {
          pname = "hello-world-static";
          version = "1.0.0";
          src = ./.;
          nativeBuildInputs = [
            pkgs.gcc
            pkgs.glibc.static
          ];
          buildPhase = ''
            g++ -static -I include ./src/*.cpp -o main
          '';
          installPhase = ''
            mkdir -p $out/bin
            cp main $out/bin/
          '';
        };

        devShells.default = pkgs.mkShell {
          packages = [
            staticGcc
            static.pkgsStatic.glibc
            static.pkgsStatic.gcc15
            pkgs.just
            pkgs.glibc # Add regular glibc for dynamic binaries
          ];
          shellHook = ''
            export PATH="${staticGccBin}:$PATH"
            unset NIX_CFLAGS_COMPILE
            export LD_LIBRARY_PATH="/lib64:/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"
          '';
        };
      }
    );
}
