{ config, pkgs, lib, ... }:

{
  environment.systemPackages = [
    (pkgs.symlinkJoin {
      name = "ghostty-with-links";
      paths = [ pkgs.ghostty ];
      postBuild = ''
        # Symlinks for common terminal calls
        ln -s $out/bin/ghostty $out/bin/xterm
        ln -s $out/bin/ghostty $out/bin/x-terminal-emulator
        ln -s $out/bin/ghostty $out/bin/gnome-terminal

        # Stealth mode: replace gnome-terminal.desktop with Ghostty's
        mkdir -p $out/share/applications
        cp ${pkgs.ghostty}/share/applications/ghostty.desktop \
           $out/share/applications/gnome-terminal.desktop

        # Change visible app name to "Terminal"
        sed -i 's/^Name=.*/Name=Terminal/' \
          $out/share/applications/gnome-terminal.desktop
      '';
    })
  ];

  # Prevent GNOME Terminal from being installed
  environment.uninstallPackages = [ pkgs.gnome-terminal ];

  # Hide GNOME Terminal from the app menu if it's installed by deps
  system.activationScripts.hide-gnome-terminal.text = ''
    mkdir -p /run/current-system/sw/share/applications
    if [ -f /run/current-system/sw/share/applications/org.gnome.Terminal.desktop ]; then
      sed -i 's/^NoDisplay=.*/NoDisplay=true/' \
        /run/current-system/sw/share/applications/org.gnome.Terminal.desktop
      grep -q '^NoDisplay=' /run/current-system/sw/share/applications/org.gnome.Terminal.desktop \
        || echo 'NoDisplay=true' >> /run/current-system/sw/share/applications/org.gnome.Terminal.desktop
    fi
  '';

  # Custom Nautilus "Open in Terminal" script
  environment.etc."xdg/nautilus/scripts/Open in Terminal".text = ''
    #!/bin/sh
    TARGET_DIR="$1"
    if [ -z "$TARGET_DIR" ]; then
      TARGET_DIR="$(pwd)"
    fi
    ghostty --working-directory "$TARGET_DIR" &
  '';
}
