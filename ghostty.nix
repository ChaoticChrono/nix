{ pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      gnome-terminal = prev.symlinkJoin {
        name = "ghostty-as-gnome-terminal";
        paths = [ prev.ghostty ];
        postBuild = ''
          # Ensure bin dir exists
          mkdir -p $out/bin

          # Symlinks for compatibility
          ln -s $out/bin/ghostty $out/bin/xterm
          ln -s $out/bin/ghostty $out/bin/x-terminal-emulator
          ln -s $out/bin/ghostty $out/bin/gnome-terminal

          # Replace GNOME Terminal desktop entry with Ghostty
          mkdir -p $out/share/applications
          cp ${prev.ghostty}/share/applications/com.mitchellh.ghostty.desktop \
             $out/share/applications/gnome-terminal.desktop
          sed -i 's/^Name=.*/Name=Terminal/' \
             $out/share/applications/gnome-terminal.desktop
        '';
      };
    })
  ];

  environment.systemPackages = [
    pkgs.gnome-terminal
  ];

  # Set GNOME's default terminal handler to Ghostty
  systemd.user.services.set-gnome-terminal-default = {
    description = "Set GNOME default terminal to Ghostty";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.gsettings-desktop-schemas}/bin/gsettings set org.gnome.desktop.default-applications.terminal exec ghostty";
    };
  };
}
