{ pkgs, lib, ... }:

{
  # 1) Replace gnome-terminal everywhere with ptyxis
  nixpkgs.overlays = [
    (final: prev: {
      gnome-terminal = prev.symlinkJoin {
        name = "ptyxis-as-gnome-terminal";
        paths = [ prev.ptyxis ];
        postBuild = ''
          mkdir -p $out/bin

          # Full impersonation wrapper for `gnome-terminal`
          cat > $out/bin/gnome-terminal <<'EOF'
          #!/usr/bin/env bash
          export VTE_VERSION=7401
          case "$1" in
            --version)
              echo "GNOME Terminal 3.52.1 using VTE 0.74.1 +BourneAgainShell"; exit 0;;
            --help)
              cat <<HELP
Usage:
  gnome-terminal [OPTION...]
Options:
  --window                 Open a new window
  --tab                    Open a new tab
  --full-screen            Open full-screen
  --maximize               Maximize window
  --minimize               Minimize window
  --preferences            Show Preferences
  --profile=PROFILE-NAME   Open with a profile (accepted/ignored)
  --version                Show version
  --help                   Show help
HELP
              exit 0;;
            --preferences)
              exec gnome-control-center terminal;;
          esac
          # Accept/ignore --profile=... to avoid breaking callers
          args=()
          for a in "$@"; do
            case "$a" in --profile=*) ;; *) args+=("$a");; esac
          done
          exec ${prev.ptyxis}/bin/ptyxis "${args[@]}"
          EOF
          chmod +x $out/bin/gnome-terminal

          # Impersonate the "server" binary too
          cat > $out/bin/gnome-terminal-server <<'EOF'
          #!/usr/bin/env bash
          export VTE_VERSION=7401
          [ "$1" = "--version" ] && { echo "GNOME Terminal Server 3.52.1"; exit 0; }
          exec ${prev.ptyxis}/bin/ptyxis "$@"
          EOF
          chmod +x $out/bin/gnome-terminal-server

          # Desktop entry: keep GNOME id but point to our wrapper
          mkdir -p $out/share/applications
          cp ${prev.ptyxis}/share/applications/com.mitchellh.Ptyxis.desktop \
             $out/share/applications/org.gnome.Terminal.desktop
          sed -i 's/^Name=.*/Name=GNOME Terminal/' \
            $out/share/applications/org.gnome.Terminal.desktop
          sed -i 's/^Exec=.*/Exec=gnome-terminal/' \
            $out/share/applications/org.gnome.Terminal.desktop
          echo "# Actually Ptyxis 😏" >> $out/share/applications/org.gnome.Terminal.desktop
        '';
      };
    })
  ];

  # Make sure *our* gnome-terminal (the wrapper) is on PATH system-wide
  environment.systemPackages = [ pkgs.gnome-terminal ];
  environment.pathsToLink = [ "/bin" ];

  # 2) GNOME default terminal = our wrapper
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.default-applications.terminal]
    exec='gnome-terminal'
    exec-arg=''
  '';

  # 3) Flatpak: allow sandboxed apps to launch host "gnome-terminal" via flatpak-spawn
  #    This sets a global override so apps can: `flatpak-spawn --host gnome-terminal ...`
  services.flatpak.enable = true;
  system.activationScripts.flatpakTerminalOverride.text = ''
    if command -v flatpak >/dev/null 2>&1; then
      # Let all Flatpaks talk to the Flatpak portal (needed for --host)
      flatpak override --system --talk-name=org.freedesktop.Flatpak || true
      # Give access to host filesystem (so terminals open to host dirs cleanly)
      flatpak override --system --filesystem=host || true
      # Nudge apps that honor TERMINAL env
      flatpak override --system --env=TERMINAL=gnome-terminal --env=COLORTERM=truecolor || true
    fi
  '';

  # Optional: ensure a portal is present (GNOME/GTK)
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}
