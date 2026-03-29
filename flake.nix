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
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              conan = prev.conan.overridePythonAttrs (old: {
                pythonRelaxDeps = (old.pythonRelaxDeps or [ ]) ++ [ "patch-ng" ];
              });
            })
          ];
        };

        staticOpenSsl = pkgs.openssl.overrideAttrs (old: {
          name = "${old.pname}-static-${old.version}";
          configureFlags = (old.configureFlags or [ ]) ++ [
            "no-shared"
            "no-dso"
          ];
        });

        staticSqlite = pkgs.runCommand "sqlite-static-${pkgs.sqlite.version}" { } ''
          mkdir -p $out/lib $out/include $out/lib/pkgconfig
          cp -r ${pkgs.sqlite.dev}/include/* $out/include/
          cp ${pkgs.sqlite.out}/lib/*.a $out/lib/ || true
          for pc in ${pkgs.sqlite.dev}/lib/pkgconfig/*.pc; do
            sed "s|${pkgs.sqlite.dev}|$out|g;s|${pkgs.sqlite.out}|$out|g" "$pc" > $out/lib/pkgconfig/$(basename "$pc")
          done
        '';

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
            cmake
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
                pkgs.sqlite
                pkgs.sqlite_orm
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
                staticSqlite
                pkgs.sqlite_orm
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
            sqlite
            conan
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
