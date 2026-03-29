{
  description = "C++ Hello World Playground";

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

        # Nix does not offer a statically linked openssl dependency and we need that for pistache
        # when building a statically linked binary
        staticOpenSsl = pkgs.openssl.overrideAttrs (old: {
          name = "${old.pname}-static-${old.version}";
          configureFlags = (old.configureFlags or [ ]) ++ [
            "no-shared"
            "no-dso"
          ];
        });

        pistache = pkgs.stdenv.mkDerivation {
          pname = "pistache";
          version = "unstable";
          src = pkgs.fetchFromGitHub {
            owner = "pistacheio";
            repo = "pistache";
            rev = "8a1ac9059617d2e3c782f4b0afcdf9f55bb91a0a";
            hash = "sha256-gBMFelqy4yFgrI8TB7i3YqUWV9KjLS3MYL/R6U00U/M=";
          };
          nativeBuildInputs = with pkgs; [
            meson
            ninja
            pkg-config
          ];
          buildInputs = with pkgs; [
            openssl
            rapidjson
          ];
          mesonFlags = [ "-Ddefault_library=both" ];
        };

        webserverBase = {
          pname = "pistache-webserver";
          version = "1.0.0";
          src = pkgs.lib.cleanSource ./.;
          nativeBuildInputs = with pkgs; [
            meson
            ninja
            pkg-config
          ];
        };

      in
      {
        packages = rec {
          default = pkgs.stdenv.mkDerivation (
            webserverBase
            // {
              buildInputs = [
                pistache
                pkgs.openssl
                pkgs.rapidjson
              ];
            }
          );

          static = pkgs.stdenv.mkDerivation (
            webserverBase
            // {
              buildInputs = [
                pistache
                pkgs.glibc.static
                pkgs.rapidjson
                staticOpenSsl
              ];
              CFLAGS = "-static -static-libgcc -static-libstdc++ -pthread";
              CXXFLAGS = "-static -static-libgcc -static-libstdc++ -pthread";
              LDFLAGS = "-static -static-libgcc -static-libstdc++ -pthread";
            }
          );
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.default ];

          packages = with pkgs; [
            bashInteractive
            bash-completion
          ];

          nativeBuildInputs = with pkgs; [
            gcc15
            just
            clang-tools
          ];

          shellHook = ''
            export SHELL=${pkgs.bashInteractive}/bin/bash
          '';
        };
      }
    );
}
