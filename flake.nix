{
  inputs = {
    rust-overlay = {url = "github:oxalica/rust-overlay";};
    cargo2nix.url = "github:cargo2nix/cargo2nix/flake";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    nixpkgs,
    utils,
    rust-overlay,
    ...
  }:
    utils.lib.eachDefaultSystem (
      system: let
        #rustChannel = "1.49.0";
        #rustChannelSha256 = "KCh2UBGtdlBJ/4UOqZlxUtcyefv7MH1neoVNV4z0nWs=";
        pkgs = import nixpkgs {
          inherit system;
          overlays = [rust-overlay.overlays.default];
        };
        environment.systemPackages = [pkgs.rust-bin.stable.latest.default];
        rustPkgs = pkgs.rustBuilder.makePackageSet' {
          #inherit rustChannel rustChannelSha256;
          packageFun = import ./Cargo.nix;
        };
      in {
        defaultPackage = rustPkgs.workspace.rustlings {};

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            (rustPkgs.workspace.rustlings {})
            rustStable
          ];
        };
      }
    );
}
