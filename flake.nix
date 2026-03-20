{
  description = "Portable FHS environment and manager for Tibia";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      
      # Shared install path
      installDir = "$HOME/.local/share/tibia-nix";

      # 1. The main game environment
      tibia-env = pkgs.buildFHSEnv {
        name = "tibia";
        targetPkgs = pkgs: with pkgs; [
          curl gnutar gzip openssl cacert libidn2 rtmpdump libpsl
          libdrm libxshmfence libXxf86vm libGL libglvnd vulkan-loader mesa
          zlib nss nspr brotli expat fontconfig freetype glib dbus libxcb
          libxkbcommon systemd libxcrypt-legacy xcbutilcursor xcbutilwm
          xcbutilimage xcbutilkeysyms xcbutilrenderutil libX11 libXrender
          libXcomposite libXcursor libXdamage libXext libXfixes libXi
          libXrandr libXScrnSaver libXtst gtk3 atk at-spi2-atk at-spi2-core
          cairo gdk-pixbuf pango alsa-lib libpulseaudio
        ];

        profile = ''
          export QT_QPA_PLATFORM=xcb
          export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
          export CURL_CA_BUNDLE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
        '';

        runScript = pkgs.writeShellScript "tibia-launcher" ''
          if [ ! -f "${installDir}/Tibia" ]; then
            echo "--- Tibia not found! Downloading... ---"
            mkdir -p "${installDir}"
            cd "${installDir}"
            curl -L "https://static.tibia.com/download/tibia.tar.gz" | tar -xz --strip-components=1
          fi
          cd "${installDir}"
          exec ./Tibia "$@"
        '';
      };

      # 2. The cleanup script
      clean-script = pkgs.writeShellScriptBin "tibia-clean" ''
        echo "This will delete the Tibia binary and assets in ${installDir}"
        read -p "Are you sure? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          rm -rf "${installDir}"
          echo "Cleanup complete."
        else
          echo "Cleanup cancelled."
        fi
      '';

    in {
      # For 'nix build'
      packages.${system}.default = tibia-env;

      # For 'nix run'
      apps.${system} = {
        # Default: nix run .
        default = {
          type = "app";
          program = "${tibia-env}/bin/tibia";
        };
        # Cleanup: nix run .#clean
        clean = {
          type = "app";
          program = "${clean-script}/bin/tibia-clean";
        };
      };
    };
}
