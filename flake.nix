{
  description = "VMM reference";

  nixConfig.bash-prompt = "vmm-reference";
  nixConfig.bash-prompt-prefix = "[\\033[1;33m";
  nixConfig.bash-prompt-suffix = "\\033[0m \\w]$ ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-vscode-extensions,
    }:
    let
      system = "x86_64-linux";

      pkgs = nixpkgs.legacyPackages.${system};

      vmm-reference = pkgs.callPackage ./. { };

      extensions = nix-vscode-extensions.extensions.${system};

      vscode = pkgs.vscode-with-extensions.override {
        vscode = pkgs.vscodium;
        vscodeExtensions = [
          extensions.vscode-marketplace.bbenoist.nix
          extensions.vscode-marketplace.timonwong.shellcheck

          extensions.vscode-marketplace.rust-lang.rust-analyzer

          extensions.vscode-marketplace-release.github.copilot
          extensions.vscode-marketplace-release.github.copilot-chat
        ];
      };

      devshell = pkgs.mkShell rec {
        packages = with pkgs; [

          vscode
          nixfmt-rfc-style

          rustc
          cargo
          rustfmt
          clippy
        ];

        shellHook = ''
          export HOME=$(pwd)

          export LD_LIBRARY_PATH="${pkgs.mesa.drivers}/lib:${pkgs.libglvnd}/lib:$LD_LIBRARY_PATH"
          export LIBGL_DRIVERS_PATH="${pkgs.mesa.drivers}/lib/dri"
          export LIBVA_DRIVERS_PATH="${pkgs.mesa.drivers}/lib/dri"

          # export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig";
          export RUST_SRC_PATH="${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
          export RUST_BACKTRACE=1

          echo "        nixpkgs: ${nixpkgs}"
          echo
          echo "  RUST_SRC_PATH: $RUST_SRC_PATH"
          # echo "           glfw: ${pkgs.glfw}"
        '';
      };

    in
    {
      devShells.${system} = {
        default = devshell;
      };
      packages.${system} = {
        inherit vmm-reference;
        default = vmm-reference;
      };
    };
}
