# NixOS dotfiles

## Preview

[View the desktop recording](./preview.mp4)

## About

This is my personal NixOS configuration. It provides a multi-host,
multi-user framework built around metadata-driven system and user modules. 
It tracks NixOS unstable and does not use Home Manager.
The repository currently contains specific configuration for the `zen` host
and `aetheris` user.

The configuration includes:

- Hyprland with a Lua-based configuration
- Quickshell wallpaper, status bar, popups, notifications, screen picker,
  and application launcher
- Fish, Ghostty, Neovim, MPV, Zen Browser, Zathura, and other user tools
- Local YAML color schemes shared across supported applications
- Disko disk configuration and impermanence
- NVIDIA PRIME offload alongside the AMD integrated GPU

## Common commands

Rebuild and activate the current host:

```sh
nix run .#rebuild
```

Build the configuration for the next boot without switching immediately:

```sh
nix run .#rebuild -- boot
```

Switch the active color scheme:

```sh
nix run .#theme -- everforest
```

Format the Nix files:

```sh
nix fmt
```

## Installation

From NixOS installation media:

```sh
nix run .#install
```

The installer asks for a host and maps its Disko disks to physical devices.
It displays the selected devices and asks for confirmation before formatting
them.

## Layout

- `host/` contains one directory for each host and its machine-specific NixOS
  configuration.
- `user/` contains user definitions that select user modules and themes.
- `module/sys/` contains system modules.
- `module/user/` contains user-level modules without Home Manager.
- `config/` contains application configuration deployed by those modules.
- `theme/` contains the local YAML color schemes.
- `template/` contains Mustache templates used to generate themed files.
- `package/` contains local package definitions and overrides.
- `lib/` contains the module and theme generation helpers.
- `script/` contains the install, rebuild, and theme-switching commands.
