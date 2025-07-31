{ buildFHSEnv
, writeShellScriptBin
, ... }:
let
  fhs = buildFHSEnv {
    name = "appimage-env";

    # Most of the packages were taken from the Steam chroot
    targetPkgs = pkgs: with pkgs; [
      gtk3
      bashInteractive
      zenity
      python2
      xorg.xrandr
      which
      perl
      xdg-utils
      iana-etc
      krb5
      gsettings-desktop-schemas
      hicolor-icon-theme # dont show a gtk warning about hicolor not being installed
    ];

    # list of libraries expected in an appimage environment:
    # https://github.com/AppImage/pkg2appimage/blob/master/excludelist
    multiPkgs = pkgs: with pkgs; [
      # extra
      fuse
      fuse3
      (writeShellScriptBin "sudo" "true") # suid wrappers messing with suff
      pulseaudio

      desktop-file-utils
      libXcomposite
      libXtst
      libXrandr
      libXext
      libX11
      libXfixes
      libGL

      gst_all_1.gstreamer
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-plugins-base
      libdrm
      xkeyboardconfig
      libpciaccess

      glib
      gtk2
      bzip2
      zlib
      gdk-pixbuf

      libXinerama
      libXdamage
      libXcursor
      libXrender
      libXScrnSaver
      libXxf86vm
      libXi
      libSM
      libICE
      GConf
      freetype
      (curl.override { gnutlsSupport = true; opensslSupport = false; })
      nspr
      nss
      fontconfig
      cairo
      pango
      expat
      dbus
      cups
      libcap
      SDL2
      libusb1
      udev
      dbus-glib
      atk
      at-spi2-atk
      libudev0-shim

      libXt
      libXmu
      libxcb
      xcbutil
      xcbutilwm
      xcbutilimage
      xcbutilkeysyms
      xcbutilrenderutil
      libGLU
      libuuid
      libogg
      libvorbis
      SDL
      SDL2_image
      glew110
      openssl
      libidn
      tbb
      wayland
      mesa
      libxkbcommon

      flac
      freeglut
      libjpeg
      libpng12
      libsamplerate
      libmikmod
      libtheora
      libtiff
      pixman
      speex
      SDL_image
      SDL_ttf
      SDL_mixer
      SDL2_ttf
      SDL2_mixer
      libappindicator-gtk2
      libcaca
      libcanberra
      libgcrypt
      libvpx
      librsvg
      xorg.libXft
      libvdpau
      alsa-lib

      harfbuzz
      e2fsprogs
      libgpg-error
      keyutils.lib
      libjack2
      fribidi
      p11-kit

      gmp

      # libraries not on the upstream include list, but nevertheless expected
      # by at least one appimage
      libtool.lib # for Synfigstudio
      libxshmfence # for apple-music-electron
      at-spi2-core
    ];

    runScript = ''

    PATH=$(echo "$PATH" | sed 's;/run/wrappers/bin:;;g')

    "$@"
    '';
  };
in writeShellScriptBin "appimage-wrap" ''
PATH=$PATH:${fhs}/bin
APPIMAGE="$1";shift
ENV_NAME="$(basename "$APPIMAGE")"
ENVDIR="/tmp/appimage-wrap/$ENV_NAME"
mkdir -p "$ENVDIR"
if [ -z "$(ls -A $ENVDIR)" ]; then
  echo "Mounting appimage"
  sudo mount "$APPIMAGE" "$ENVDIR" -o "offset=$(appimage-env "$APPIMAGE" --appimage-offset | head -n 1)"
fi
appimage-env "$ENVDIR/AppRun" "$@"
''
