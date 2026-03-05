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

        staticOpenSsl = pkgs.openssl.overrideAttrs (old: rec {
          name = "${old.pname}-static-${old.version}";
          configureFlags = (old.configureFlags or [ ]) ++ [
            "no-shared"
            "no-dso"
          ];
        });

        pistache = pkgs.stdenv.mkDerivation {
          name = "pistache";
          src = pkgs.fetchFromGitHub {
            owner = "pistacheio";
            repo = "pistache";
            rev = "8a1ac9059617d2e3c782f4b0afcdf9f55bb91a0a";
            hash = "sha256-gBMFelqy4yFgrI8TB7i3YqUWV9KjLS3MYL/R6U00U/M=";
          };

          nativeBuildInputs = [
            pkgs.meson
            pkgs.ninja
            pkgs.pkg-config
          ];

          buildInputs = [
            pkgs.openssl
            pkgs.rapidjson
          ];

          configurePhase = ''
            meson setup build . --buildtype=release --prefix=$out -Ddefault_library=both
          '';
          buildPhase = ''
            ninja -C build
          '';
          installPhase = ''
            ninja -C build install
          '';
        };
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "main";
          version = "1.0.0";
          src = pkgs.lib.cleanSource ./.;
          nativeBuildInputs = [
            pkgs.gcc
            pkgs.meson
            pkgs.ninja
            pkgs.pkg-config
          ];

          buildInputs = [
            pistache
            pkgs.openssl
            pkgs.rapidjson
          ];

          configurePhase = ''
            meson setup build . --buildtype=release --prefix=$out
          '';

          buildPhase = ''
            ninja -C build
          '';

          installPhase = ''
            ninja -C build install
          '';
        };

        packages.static = pkgs.stdenv.mkDerivation {
          pname = "pistache-webserver-static";
          version = "1.0.0";
          src = pkgs.lib.cleanSource ./.;

          nativeBuildInputs = [
            pkgs.gcc
            pkgs.meson
            pkgs.ninja
            pkgs.pkg-config
          ];

          buildInputs = [
            pkgs.glibc.static
            pkgs.rapidjson
            staticOpenSsl
            pistache
          ];

          configurePhase = ''
            export CFLAGS="-static -static-libgcc -static-libstdc++ -pthread"
            export CXXFLAGS="-static -static-libgcc -static-libstdc++ -pthread"
            export LDFLAGS="-static -static-libgcc -static-libstdc++ -pthread"
            meson setup build . --buildtype=release --prefix=$out
          '';

          buildPhase = ''
            ninja -C build
          '';

          installPhase = ''
            ninja -C build install
          '';
        };

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.glibc.static
            pkgs.gcc15
            pkgs.just
            pkgs.glibc
            pkgs.openssl
            pkgs.rapidjson
            pkgs.pkg-config
            pkgs.meson
            pkgs.ninja
            pkgs.clang-tools
            pkgs.gcc

            pistache
            staticOpenSsl
          ];
          shellHook = ''
            export PATH="${pkgs.gcc}/bin:${pkgs.clang-tools}/bin:$PATH"
            export CPATH="${pistache}/include:${staticOpenSsl}/include:$CPATH"
            export CXXFLAGS="-I${pistache}/include -I${staticOpenSsl}/include $CXXFLAGS"
            export LIBRARY_PATH="${pistache}/lib:${staticOpenSsl}/lib:$LIBRARY_PATH"
            export PKG_CONFIG_PATH="${pistache}/lib/pkgconfig:${pistache}/lib64/pkgconfig:${staticOpenSsl}/lib/pkgconfig:${staticOpenSsl}/lib64/pkgconfig:${pkgs.rapidjson}/lib/pkgconfig:${pkgs.rapidjson}/lib64/pkgconfig:$PKG_CONFIG_PATH"
            unset NIX_CFLAGS_COMPILE

            export LD_LIBRARY_PATH="/lib64:/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"
          '';
        };
      }
    );
}
