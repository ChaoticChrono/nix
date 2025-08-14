# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, osConfig, modulesPath, ... }: {
imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];
boot = {
    plymouth = {
      enable = true;
      theme = "nixos-bgrt";
      themePackages = with pkgs; [
        nixos-bgrt-plymouth
      ];
    };
    # Enable "Silent boot"
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
      "psi=1"
      "slab_nomerge"
      "init_on_alloc=1"
      "init_on_free=1"
      "page_alloc.shuffle=1"
      "randomize_kstack_offset=on"
      "pti=on"
      "vsyscall=none"
    ];
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;
   
  };
  # Console font size
  console = {
  earlySetup = true;
  font = "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
  packages = with pkgs; [ terminus_font ];
  keyMap = "us";
  };

  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];
  #Auto Update
  system.autoUpgrade.enable  = true;
  system.autoUpgrade.allowReboot  = true;
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;  
  
  # Use Lqx kernel
  boot.kernelPackages = pkgs.linuxPackages_lqx;
  
  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;
  networking.wireless.iwd.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
  networking.firewall.allowedTCPPorts = [ 57621 ];
  networking.firewall.allowedUDPPorts = [ 5353 ];
  networking.firewall.checkReversePath = "strict"; # anti-spoofing
  networking.nameservers = [ "1.1.1.1#cloudflare-dns.com" "9.9.9.9#dns.quad9.net" ];
  networking.networkmanager.plugins = [];
  
  services.resolved = {
  enable = true;
  dnsovertls = "true";
  dnssec = "true";
  domains = [ "~." ];
  fallbackDns = [ "8.8.8.8" "1.0.0.1" ];
  };
  
  environment.etc."resolv.conf".source = "/run/systemd/resolve/stub-resolv.conf";
  # Set your time zone.
  time.timeZone = "Asia/Kolkata";
  #GDM
    systemd.tmpfiles.rules = [
    ''f+ /run/gdm/.config/monitors.xml - gdm gdm - <monitors version="2"><configuration><layoutmode>logical</layoutmode><logicalmonitor><x>0</x><y>0</y><scale>1.5</scale><primary>yes</primary><monitor><monitorspec><connector>eDP-1</connector><vendor>AUO</vendor><product>0xd1ed</product><serial>0x00000000</serial></monitorspec><mode><width>1920</width><height>1080</height><rate>120.213</rate></mode></monitor></logicalmonitor></configuration></monitors>''
  ];
  services.udev.packages = with pkgs; [ gnome-settings-daemon ];
  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
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

  ### NixOS power management
    powerManagement = {
        enable = true;
        powertop.enable = true;
        cpuFreqGovernor = "schedutil"; #power, performance, ondemand
    };
  
  # Thermald
  services.thermald.enable = true;
  #Fwupdmgr
  services.fwupd.enable = true;
  # Flatpak
  services.flatpak.enable = true;
  # Wayland environment
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # Editor
  programs.nano.enable = true;
  environment.variables = {
  EDITOR = "nano";
  VISUAL = "nano";
  }; 
  #Apparmor
  security.apparmor.enable = true;
  security.apparmor.enableCache = true;
  
  # Doas as sudo replacement
  security.sudo.enable = false;
  security.doas.enable = true;
  security.doas.extraRules = [
  {
    groups = [ "wheel" ];
    persist = true;       # Remembers authentication for a period
    keepEnv = true;       # Keeps environment variables
  }
  ];
  environment.shellAliases = { sudo = "doas"; };
  #Switcheroo
  services.switcherooControl.enable = true;
  
  # Disabling needless services
  services.avahi.enable = false;
  services.openssh.enable = false;
 
  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = with pkgs; [
      epiphany # web browser
      evince # document viewer
      geary # email reader
      gedit # text editor
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
   services = {
     displayManager.gdm = {
       wayland = true;
     };
     desktopManager.gnome = {
       extraGSettingsOverrides = ''
         [org.gnome.mutter]
         experimental-features=['scale-monitor-framebuffer']
         '';
     };
   };
  programs.dconf = {
      enable = true;
      profiles.user.databases = [{
        settings = with lib.gvariant; {     
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            gtk-theme = "adw-gtk3-dark";
            accent-color = "teal";
          };
         };
      }];
    };
   programs.dconf.profiles.gdm.databases = [{
        settings = with lib.gvariant;
    { "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            gtk-theme = "adw-gtk3-dark";
            accent-color = "teal";
          };
     };
  }];
  # Enable Dbus-broker
   services.dbus = {
	enable = true;
	implementation = "broker";
   };
  #Font setup
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
        #libsForQt5.breeze-qt5  # for plasma
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
  };
  fonts.fontconfig.useEmbeddedBitmaps = true;
  
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  programs.nautilus-open-any-terminal = {
  enable = true;
  terminal = "ghostty";
  };
  # Disable CUPS to print documents.
  services.printing.enable = false;
  hardware.sane.enable = false;
  
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
   
   # Enable Zram
    zramSwap = {
    enable = true;
    algorithm = "lz4";
    memoryPercent = 100;
  };
  
  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ved = {
    isNormalUser = true;
    description = "Vedanta Singh";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    
    ];
  };
  # Filesystem hardening
  security.audit.enable = true;
  boot.kernel.sysctl = {
  "fs.protected_fifos" = 2;
  "fs.protected_regular" = 2;
  };
  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  # Extra nix options
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 30d";
  };  
  
# List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     wget 
     btop
     showtime
     papers
     ghostty
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
     
     # Apparmor 
     apparmor-utils 
     apparmor-profiles
     
     # Gnome extensions
     gnomeExtensions.appindicator
     gnomeExtensions.accent-directories
     gnomeExtensions.overview-background
     gnomeExtensions.gnome-40-ui-improvements
     gnomeExtensions.adw-gtk3-colorizer
     gnomeExtensions.pip-on-top
     
     # Rust core utils
     (pkgs.uutils-coreutils.override { prefix = ""; })
 ];
 
  # GNOME workaround to override hardcoded terminal
  system.activationScripts.createGnomeTerminalSymlink.text = ''
    ln -sf ${pkgs.ghostty}/bin/ghostty /usr/bin/gnome-terminal
  '';
  environment.binAliases = {
  gnome-terminal = "${pkgs.ghostty}/bin/ghostty";
  };

  
  nix.settings.trusted-users = [ "root" "ved" ];
  
  # Memory & Compiler Hardening
  environment.variables = {
  NIX_CFLAGS_COMPILE = "-fstack-protector-strong -D_FORTIFY_SOURCE=2";
  NIX_LDFLAGS = "-Wl,-z,relro,-z,now";
  };

  #Waydroid
  virtualisation.waydroid.enable = true;
  # Nvidia support
  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [
    "modesetting"
    "nvidia"
  ];
  
  hardware.nvidia.open = true;
  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
    
  };
  nixpkgs.config.cudaSupport = true;
  # Appimage support
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
  
  # Enable Java 
  programs.java = { enable = true; package = pkgs.temurin-bin; };
  
  system.stateVersion = "25.11"; # Did you read the comment?
  
  i18n.inputMethod = {
  enable = true;
  type = "ibus";
  ibus.engines = with pkgs.ibus-engines; [ anthy ];
  };
  hardware.graphics = {
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };
  environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

}
