{ pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      gnome-terminal = prev.symlinkJoin {
        name = "ptyxis-as-gnome-terminal";
        paths = [ prev.ptyxis ];
        postBuild = ''
          # Binary override
          mkdir -p $out/bin
          ln -sf ${prev.ptyxis}/bin/ptyxis $out/bin/gnome-terminal

          # Desktop entry override
          mkdir -p $out/share/applications
          cp ${prev.ptyxis}/share/applications/com.mitchellh.Ptyxis.desktop \
             $out/share/applications/org.gnome.Terminal.desktop

          # Fix the desktop entry name to say GNOME Terminal if you want to trick apps
          sed -i 's/^Name=.*/Name=GNOME Terminal (Ptyxis)/' \
            $out/share/applications/org.gnome.Terminal.desktop
        '';
      };
    })
  ];

  environment.systemPackages = [
    pkgs.gnome-terminal
  ];

  # Set GNOME’s default terminal to ptyxis
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.default-applications.terminal]
    exec='ptyxis'
    exec-arg=''
  '';
}
