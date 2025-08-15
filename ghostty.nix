{ pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      gnome-terminal = prev.symlinkJoin {
        name = "ghostty-as-gnome-terminal";
        paths = [ prev.ghostty ];
        postBuild = ''
          # Make sure bin directory exists
          mkdir -p $out/bin

          # Symlinks so commands work like gnome-terminal
          ln -s $out/bin/ghostty $out/bin/xterm
          ln -s $out/bin/ghostty $out/bin/x-terminal-emulator
          ln -s $out/bin/ghostty $out/bin/gnome-terminal

          # Replace GNOME Terminal desktop entry with Ghostty
          mkdir -p $out/share/applications
          cp ${prev.ghostty}/share/applications/ghostty.desktop \
             $out/share/applications/gnome-terminal.desktop
          sed -i 's/^Name=.*/Name=Terminal/' \
             $out/share/applications/gnome-terminal.desktop
        '';
      };
    })
  ];

  # Install "gnome-terminal" (which is actually Ghostty now)
  environment.systemPackages = [ pkgs.gnome-terminal ];
}
