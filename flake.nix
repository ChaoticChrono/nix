{
  description = "SecureBoot-enabled NixOS configuration";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
   
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, lanzaboote, nixos-hardware, ... }: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
          lanzaboote.nixosModules.lanzaboote
          nixos-hardware.nixosModules.common-cpu-intel
          ({ config, pkgs, lib, ... }: {
              
              programs.zsh = {
              enable = true;
              enableCompletion = true;
              syntaxHighlighting.enable = true;

              shellAliases = {
                ll = "ls -l";
                nix = "noglob nix" ;
                update = "sudo nixos-rebuild switch";
              };
               
              interactiveShellInit = ''
                # Load GRML config (provides key bindings, colors, etc.)
                source ${pkgs.grml-zsh-config}/etc/zsh/zshrc

                # Load autosuggestions
                source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

                # Load history-substring-search
                source ${pkgs.zsh-history-substring-search}/share/zsh-history-substring-search/zsh-history-substring-search.zsh

                # Optional: Set history-substring-search bindings
                bindkey '^[[A' history-substring-search-up
                bindkey '^[[B' history-substring-search-down

                # Custom prompt tweak
                zstyle ':prompt:grml:left:items:user' pre '%F{cyan}%B'
              '';

              promptInit = "";
            };

            environment.systemPackages = [
              pkgs.zsh
              pkgs.zsh-autosuggestions
              pkgs.zsh-syntax-highlighting
              pkgs.zsh-history-substring-search
              pkgs.grml-zsh-config
              pkgs.sbctl
            ]; 
            boot.loader.systemd-boot.enable = lib.mkForce false;

            boot.lanzaboote = {
              enable = true;
              pkiBundle = "/var/lib/sbctl";
            };
          })
        ];
      };
    };
  };
}
