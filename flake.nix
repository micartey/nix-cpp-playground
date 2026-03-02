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
        # The static stdenv already contains the static-ready compiler
        staticStdenv = pkgs.pkgsStatic.stdenv;
      in
      {
        devShells.default = pkgs.mkShell.override { stdenv = staticStdenv; } {
          packages = with pkgs.pkgsStatic; [
            cmake
            gdb
          ];
        };
      }
    );
}
