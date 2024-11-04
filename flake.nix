{
  description = "vmm-reference";
  nixConfig.bash-prompt = "[\\033[1;33mvmm-reference\\033[0m \\w]$ ";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    flake-compat,
    nix-vscode-extensions,
  }: let
    systems = ["x86_64-linux"];
  in
    flake-utils.lib.eachSystem systems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      inherit (pkgs) vscode-with-extensions vscodium;
      extensions = nix-vscode-extensions.extensions.${system};
      vscode = vscode-with-extensions.override {
        vscode = vscodium;
        vscodeExtensions = [
          extensions.open-vsx-release.rust-lang.rust-analyzer
          extensions.vscode-marketplace.bbenoist.nix
        ];
      };
      vmm-reference = self.packages.${system}.vmm-reference;
    in {
      devShells = {
        default = pkgs.mkShell {
          packages = with pkgs; [cargo rustc vscode vmm-reference];
        };
      };
      packages = {
        vmm-reference = pkgs.callPackage ./. {};
        default = vmm-reference;
      };
    });
}
