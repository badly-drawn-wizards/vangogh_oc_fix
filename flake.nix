{
  inputs = {
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
  };

  outputs = { nixpkgs, utils, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        inherit (pkgs) lib;
      in
      {
        devShell = pkgs.mkShell {
          NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
            pkgs.gcc-unwrapped.lib
            pkgs.elfutils
          ];
          NIX_LD = lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
          buildInputs = with pkgs; (linux.nativeBuildInputs ++ [
          ]);
        };
      }
    );
}
