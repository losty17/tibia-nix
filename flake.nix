{
  description = "A portable FHS environment for Tibia on NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # We define the environment here
      tibia-pkg = pkgs.buildFHSEnv {
        name = "tibia";
        targetPkgs = pkgs: with pkgs; [
          # SSL and Connection
          openssl cacert libidn2 rtmpdump libpsl curl
          # Graphics & Hardware
          libdrm libxshmfence libXxf86vm libGL libglvnd vulkan-loader mesa
          # Core Essentials
          zlib nss nspr brotli expat fontconfig freetype glib dbus libxcb libxkbcommon systemd libxcrypt-legacy
          # XCB / Qt Fixes
          xcbutilcursor xcbutilwm xcbutilimage xcbutilkeysyms xcbutilrenderutil
          # X11 libraries
          libX11 libXrender libXcomposite libXcursor libXdamage libXext libXfixes libXi libXrandr libXScrnSaver libXtst
          # UI and Audio
          gtk3 atk at-spi2-atk at-spi2-core cairo gdk-pixbuf pango alsa-lib libpulseaudio
        ];

        profile = ''
          export QT_QPA_PLATFORM=xcb
          export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
          export CURL_CA_BUNDLE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        '';

        # This script runs INSIDE the FHS environment when launched
        runScript = pkgs.writeShellScript "tibia-launcher" ''
          if [ -f "./Tibia" ]; then
            exec ./Tibia "$@"
          else
            echo "--------------------------------------------------------"
            echo "Error: Tibia binary not found in the current directory."
            echo "Please run this command from inside your Tibia folder."
            echo "--------------------------------------------------------"
            exit 1
          fi
        '';
      };
    in {
      # This allows running 'nix run'
      packages.${system}.default = tibia-pkg;

      # This makes it easy to use as a dev shell if needed
      devShells.${system}.default = tibia-pkg.env;
    };
}
