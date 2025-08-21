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
          
          ./hardware-configuration.nix
          lanzaboote.nixosModules.lanzaboote
          nixos-hardware.nixosModules.common-cpu-intel
          ({ config, pkgs, lib, ... }: {
             
              boot = {
               plymouth = {
                enable = true;
                theme = "nixos-bgrt";
                themePackages = with pkgs; [
                 nixos-bgrt-plymouth
              ];
              };
              consoleLogLevel = 3;
              initrd.verbose = false;
              kernelParams = [
               "quiet"
               "splash"
               "boot.shell_on_fail"
               "udev.log_priority=3"
               "rd.systemd.show_status=auto"
               "psi=1"
              ];
              loader = {
                timeout = 0;
                systemd-boot.enable = lib.mkForce false;
                efi.canTouchEfiVariables = true;
              };
              kernelPackages = pkgs.linuxPackages_xanmod;
              initrd.systemd.enable = true;
              lanzaboote = {
               enable = true;
               pkiBundle = "/var/lib/sbctl";
              }; 
              };
              console = {
               earlySetup = true;
               font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
               packages = with pkgs; [ terminus_font ];
               keyMap = "us";
              };
              
              programs = {
              java = { enable = true; package = pkgs.temurin-bin; };
              appimage.binfmt = true;
              appimage.enable = true;
              
              nautilus-open-any-terminal = {
               enable = true;
               terminal = "ghostty";
              }; 
              firefox.enable = true;
              nix-ld.enable = true;
              direnv.nix-direnv.enable = true;
              direnv.loadInNixShell = true;
              direnv.enableZshIntegration = true;
              direnv.enable = true;
              vscode.package = pkgs.vscode.fhsWithPackages (ps: with ps; [ rustup zlib openssl.dev pkg-config ]);
              nano.enable = true;
              dconf = {
                   enable = true;
                    profiles = {
                    gdm.databases = [{
                    settings = with lib.gvariant;
                   { "org/gnome/desktop/interface" = {
                     color-scheme = "prefer-dark";
                     gtk-theme = "adw-gtk3-dark";
                     accent-color = "teal";
                      };
                     };
                    }];
                    user.databases = [{
                    settings = with lib.gvariant; 
                    { "org/gnome/desktop/interface" = {
                    color-scheme = "prefer-dark";
                    gtk-theme = "adw-gtk3-dark";
                    accent-color = "teal";
                  };
                 };
               }];
             };
              };
              zsh = {
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
              };
              networking = { 
                hostName = "nixos";
                networkmanager = {
                  enable = true;
                  wifi.backend = "iwd";
                  plugins = [];
                   };
                wireless.iwd.enable = true;
                firewall = { 
                  allowedTCPPorts = [ 57621 ];
                  allowedUDPPorts = [ 5353 ];
                  checkReversePath = "strict";
                }; 
                 nameservers = [ "1.1.1.1#cloudflare-dns.com" "9.9.9.9#dns.quad9.net" ];
              
              };
              time.timeZone = "Asia/Kolkata";
              i18n = { 
               defaultLocale = "en_US.UTF-8";
               extraLocaleSettings = {
               LC_ADDRESS = "en_US.UTF-8";
               LC_IDENTIFICATION = "en_US.UTF-8";
               LC_MEASUREMENT = "en_US.UTF-8";
               LC_MONETARY = "en_US.UTF-8";
               LC_NAME = "en_US.UTF-8";
               LC_NUMERIC = "en_US.UTF-8";
               LC_PAPER = "en_US.UTF-8";
               LC_TELEPHONE = "en_US.UTF-8";
               LC_TIME = "en_US.UTF-8";
              };
              inputMethod = {
                enable = true;
                type = "ibus";
                ibus.engines = with pkgs.ibus-engines; [ anthy ];
               };
              };
              services = {
                thermald.enable = true;
                fwupd.enable = true;
                flatpak.enable = true;
                udev.packages = with pkgs; [ gnome-settings-daemon ];
                switcherooControl.enable = true;
                displayManager.gdm = {
                  enable = true;
                  wayland = true;
                  };
                desktopManager.gnome = {
                  enable = true;
                  extraGSettingsOverrides = ''
                    [org.gnome.mutter]
                    experimental-features=['scale-monitor-framebuffer']
                   '';
                  };
                dbus = {
	                enable = true;
	                implementation = "broker";
                  };
                pulseaudio.enable = false;
                pipewire = {
                  enable = true;
                  alsa.enable = true;
                  alsa.support32Bit = true;
                  pulse.enable = true;
                  jack.enable = true;
                  };
                xserver.xkb = {
                  layout = "us";
                  variant = "";
                  };
                libinput.enable = true;
                xserver.videoDrivers = [
                 "modesetting"
                 "nvidia"
                ];
                resolved = {
                 enable = true;
                 dnsovertls = "true";
                 dnssec = "true";
                 domains = [ "~." ];
                 fallbackDns = [ "8.8.8.8" "1.0.0.1" ];
                };
                ananicy.enable = true;
                fstrim.enable = true;
                avahi.enable = false;
                openssh.enable = false;
                printing.enable = false;
                };
              security = {
                rtkit.enable = true;
                audit.enable = true;
                apparmor.enable = true;
                apparmor.enableCache = true;
                sudo.enable = false;
                doas.enable = true;
                doas.extraRules = [
                 {
                 groups = [ "wheel" ];
                 persist = true;
                 keepEnv = true;       
                 }
                ];
              
              };

              hardware = {
                graphics = {
                  enable = true;
                  };
                nvidia = {
                  open = true;
                  prime = {
                    offload = {
                      enable = true;
                      
                      enableOffloadCmd = true;
                    };
                  intelBusId = "PCI:0:2:0";
                  nvidiaBusId = "PCI:1:0:0";
                  };
                };
                };
               users = { 
                 defaultUserShell = pkgs.zsh;
                 users = { 
                 ved = {
                 isNormalUser = true;
                 description = "Vedanta Singh";
                 extraGroups = [ "networkmanager" "wheel" "video" "audio" "input" ];
                 uid = 1000;
                 home = "/home/ved";
                      
               };
                };
              };
              virtualisation.waydroid.enable = true;
              
              environment = {
              sessionVariables = { 
                NIXOS_OZONE_WL = "1";
                LIBVA_DRIVER_NAME = "iHD";
              };
              etc."resolv.conf".source = "/run/systemd/resolve/stub-resolv.conf";
              variables = {
               EDITOR = "nano";
               VISUAL = "nano";
               NIX_CFLAGS_COMPILE = "-fstack-protector-strong -D_FORTIFY_SOURCE=2";
               NIX_LDFLAGS = "-Wl,-z,relro,-z,now";
              };
              shellAliases = { sudo = "doas"; };
              shells = with pkgs; [ zsh ];
              gnome.excludePackages = with pkgs; [
                 epiphany 
                 evince 
                 geary 
                 gedit 
                 gnome-music
                 gnome-photos
                 gnome-terminal
                 simple-scan
                 gnome-tour
                 totem
                 gnome-maps
                 gnome-calculator
                 gnome-system-monitor
                 gnome-contacts
                 yelp
                 gnome-logs
                 gnome-connections
                 gnome-font-viewer
                 gnome-console
               ];
              systemPackages = with pkgs; [
                 btop
                 showtime
                 papers
                 sbctl
                 spotify
                 adw-gtk3
                 gnome-tweaks
                 git
                 lz4
                 azahar
                 ryubing
                 tpm2-tss 
                 wl-clipboard
                 ffmpegthumbnailer
                 ghostty
                 signal-desktop
                 bashInteractive
                 vscode.fhs 
                 apparmor-utils 
                 apparmor-profiles
                 gnomeExtensions.appindicator
                 gnomeExtensions.accent-directories
                 gnomeExtensions.overview-background
                 gnomeExtensions.gnome-40-ui-improvements
                 gnomeExtensions.adw-gtk3-colorizer
                 gnomeExtensions.pip-on-top
                 (pkgs.uutils-coreutils.override { prefix = ""; })
                 zsh
                 zsh-autosuggestions
                 zsh-syntax-highlighting
                 zsh-history-substring-search
                 grml-zsh-config
                 sbctl
                 cudaPackages.cudatoolkit
                 cudaPackages.cudnn
                 

              ];
              };
               
               powerManagement = {
                 enable = true;
                 powertop.enable = true;
                 cpuFreqGovernor = "schedutil";
               };
                systemd.tmpfiles.rules = [
                 ''f+ /run/gdm/.config/monitors.xml - gdm gdm - <monitors version="2"><configuration><layoutmode>logical</layoutmode><logicalmonitor><x>0</x><y>0</y><scale>1.5</scale><primary>yes</primary><monitor><monitorspec><connector>eDP-1</connector><vendor>AUO</vendor><product>0xd1ed</product><serial>0x00000000</serial></monitorspec><mode><width>1920</width><height>1080</height><rate>120.213</rate></mode></monitor></logicalmonitor></configuration></monitors>''
                ];
                  
               system.fsPackages = [ pkgs.bindfs ];
               fileSystems = let
               mkRoSymBind = path: {
               device = path;
               fsType = "fuse.bindfs";
               options = [ "ro" "resolve-symlinks" "x-gvfs-hide" ];
               };
               aggregatedIcons = pkgs.buildEnv {
               name = "system-icons";
               paths = with pkgs; [
               gnome-themes-extra
               adwaita-icon-theme-legacy
               morewaita-icon-theme
               ];
               pathsToLink = [ "/share/icons" ];
               };
               aggregatedFonts = pkgs.buildEnv {
               name = "system-fonts";
               paths = config.fonts.packages;
               pathsToLink = [ "/share/fonts" ];
               };
              in {
               "/usr/share/icons" = mkRoSymBind "${aggregatedIcons}/share/icons";
               "/usr/local/share/fonts" = mkRoSymBind "${aggregatedFonts}/share/fonts";
               };

              fonts = {
               fontDir.enable = true;
               packages = with pkgs; [
               noto-fonts
               noto-fonts-emoji
               noto-fonts-cjk-sans
               nerd-fonts.adwaita-mono
               adwaita-fonts
               ];
               fontconfig.useEmbeddedBitmaps = true;
              };
             
              zramSwap = {
              enable = true;
              algorithm = "lz4";
              memoryPercent = 100;
              };
  
              nixpkgs = { 
                config = {
                 allowUnfree = true;
                 cudaSupport = true;
               }; 
              };
              nix = { 
               settings = { 
                experimental-features = [ "nix-command" "flakes" ];
                auto-optimise-store = true;
                trusted-users = [ "root" "ved" ];
              };
              gc = {
               automatic = true;
               dates = "weekly";
               options = "--delete-older-than 30d";
              };
              };
              system.activationScripts.binbash = ''
              mkdir -p /bin
              ln -sf ${pkgs.bashInteractive}/bin/bash /bin/bash
              '';
              system.stateVersion = "25.11"; 
          })
        ];
      };
    };
  };
}
