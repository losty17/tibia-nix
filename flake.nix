{
  description = "A portable FHS environment for Tibia on NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      tibia-env = pkgs.buildFHSEnv {
        name = "tibia";
        targetPkgs = pkgs: with pkgs; [
          # SSL and Connection
          openssl cacert libidn2 rtmpdump libpsl curl
          
          # Graphics & Hardware
          libdrm libxshmfence libXxf86vm libGL libglvnd vulkan-loader mesa
          
          # Core Essentials
          zlib nss nspr brotli expat fontconfig freetype glib dbus libxcb 
          libxkbcommon systemd libxcrypt-legacy
          
          # XCB / Qt Fixes
          xcbutilcursor xcbutilwm xcbutilimage xcbutilkeysyms xcbutilrenderutil
          
          # X11 libraries
          libX11 libXrender libXcomposite libXcursor libXdamage libXext 
          libXfixes libXi libXrandr libXScrnSaver libXtst
          
          # UI and Audio
          gtk3 atk at-spi2-atk at-spi2-core cairo gdk-pixbuf pango alsa-lib libpulseaudio
        ];

        profile = ''
          export QT_QPA_PLATFORM=xcb
          export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
          export CURL_CA_BUNDLE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        '';

        # The script now takes an optional path argument
        runScript = pkgs.writeShellScript "tibia-launcher" ''
          # Use provided path ($1) or fallback to current directory (.)
          TARGET_DIR="''${1:-.}"
          
          # Absolute pathing for the binary
          TIBIA_BIN="$TARGET_DIR/Tibia"

          if [ -f "$TIBIA_BIN" ]; then
            echo "--- Launching Tibia from: $TARGET_DIR ---"
            cd "$TARGET_DIR"
            exec ./Tibia
          else
            echo "-----------------------------------------------------------"
            echo "Error: Tibia binary not found!"
            echo "Usage: nix run . -- /path/to/tibia/folder"
            echo "Or run this command inside your Tibia folder."
            echo "Current search path: $TARGET_DIR"
            echo "-----------------------------------------------------------"
            exit 1
          fi
        '';
      };
    in {
      packages.${system}.default = tibia-env;

      apps.${system}.default = {
        type = "app";
        program = "${tibia-env}/bin/tibia";
      };
    };
}
