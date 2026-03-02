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
