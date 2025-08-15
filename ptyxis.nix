{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ptyxis
  ];

  # Replace gnome-terminal with ptyxis
  environment.etc."alternatives/gnome-terminal".source = pkgs.writeShellScript "gnome-terminal-wrapper" ''
    #!${pkgs.bash}/bin/bash
    args=()
    for arg in "$@"; do
      args+=("$arg")
    done
    exec ${pkgs.ptyxis}/bin/ptyxis "\${args[@]}"
  '';

  # Override desktop entry
  environment.systemPackages = [
    (pkgs.runCommand "ptyxis-as-gnome-terminal" { buildInputs = [ pkgs.coreutils ]; } ''
      mkdir -p $out/share/applications
      cp ${pkgs.ptyxis}/share/applications/com.mitchellh.ptyxis.desktop \
         $out/share/applications/org.gnome.Terminal.desktop
    '')
  ];
}
