# Tibia on NixOS

Running Tibia on NixOS is, usually, a lot of stress, with missing libraries, SSL errors, and driver conflicts everywhere. 

This repository provides a **Portable FHS (Filesystem Hierarchy Standard) Environment** that bundles every single dependency Tibia needs to run smoothly on NixOS.

## Quick Start

### 1. Prerequisite
Ensure you have **Nix Flakes** enabled on your system. 

### 2. Run from within your Tibia folder
If you already have Tibia downloaded and you are currently in that directory:
```bash
nix run github:losty17/tibia-nix
```

### 3. Run by specifying a path
If your Tibia installation is somewhere else (like a secondary drive or your Downloads folder):
```bash
nix run github:losty17/tibia-nix -- /path/to/your/Tibia-Folder
```


## How it works?

This Flake uses `buildFHSEnv` to create a "bubble" that mimics a traditional Linux distribution (like Ubuntu). Inside this bubble, we provide:

* **Graphics:** Full support for `Vulkan`, `OpenGL`, `Mesa`, and `LibGL`.
* **Connection:** Fixed `SSL_CERT_FILE` paths so the login server actually responds.
* **UI/Sound:** All necessary `X11`, `Qt`, `XCB`, and `Alsa/PulseAudio` libraries.
* **Compatibility:** Uses `libxcrypt-legacy` to handle Tibia's older authentication requirements.


## Manual Setup (Optional)

If you prefer to keep the files local and edit the `flake.nix` yourself:

1.  **Clone the repo:**
    ```bash
    git clone https://github.com/losty17/tibia-nix.git
    cd tibia-nix
    ```
2.  **Launch:**
    ```bash
    nix run . -- /your/tibia/path
    ```


## Updating

Since the we are running the official release of the `Tibia` binary, the internal CipSoft patcher works perfectly. Just run the command, let it patch, and restart if prompted.


**Disclaimer:** *This project is not affiliated with, maintained by, or endorsed by CipSoft GmbH. Tibia is a registered trademark of CipSoft GmbH.*
