{ pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      gnome-terminal = prev.symlinkJoin {
        name = "ghostty-as-gnome-terminal";
        paths = [ prev.ghostty ];
        postBuild = ''
          # Symlinks for compatibility
          ln -s $out/bin/ghostty $out/bin/xterm
          ln -s $out/bin/ghostty $out/bin/x-terminal-emulator
          ln -s $out/bin/ghostty $out/bin/gnome-terminal

          # Masquerade as GNOME Terminal desktop entry
          mkdir -p $out/share/applications
          cp ${prev.ghostty}/share/applications/ghostty.desktop \
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
}
