#!/usr/bin/env fish

function fail
    gum style --foreground 1 --bold "ERROR: $argv" >&2
    exit 1
end

function info
    gum style --foreground 6 --bold "========> $argv"
end

set -lx GUM_CHOOSE_HEADER_FOREGROUND 15
set -lx GUM_CHOOSE_CURSOR_FOREGROUND 15
set -lx GUM_CHOOSE_ITEM_FOREGROUND 15
set -lx GUM_CHOOSE_SELECTED_FOREGROUND 15

set -lx GUM_CONFIRM_PROMPT_FOREGROUND 15
set -lx GUM_CONFIRM_SELECTED_FOREGROUND 0
set -lx GUM_CONFIRM_SELECTED_BACKGROUND 15
set -lx GUM_CONFIRM_UNSELECTED_FOREGROUND 15
set -lx GUM_CONFIRM_UNSELECTED_BACKGROUND 0

info "Start Preparing Installation"

# =========================
# Health Check

argparse 'flake=' 'install-data=' -- $argv; or exit 2

set -q _flag_flake; or fail "missing --flake"
set -q _flag_install_data; or fail "missing --install-data"

set flake $_flag_flake
set install_data_file $_flag_install_data

test -e /etc/NIXOS; or \
    fail "this installer must be run from NixOS installation media"

test -x /run/current-system/sw/bin/nixos-install; or \
    fail "the current NixOS system is not an installation environment"

test -d /sys/firmware/efi/efivars; or \
    fail "boot the installation media in UEFI mode"

if test (id --user) -ne 0
    test -x /run/wrappers/bin/sudo; or \
        fail "the NixOS installation sudo wrapper is unavailable"
end

# =========================
# Initialization

test -r "$install_data_file"; or fail "cannot read install data: $install_data_file"
jq empty "$install_data_file"; or fail "invalid install data: $install_data_file"

set hosts (jq --raw-output 'keys[]' "$install_data_file"); or exit 1
test (count $hosts) -gt 0; or fail "the flake contains no installable hosts"

set host (
    printf '%s\n' $hosts |
		gum choose --header "Select a host to install"
); or exit 1
test -n "$host"; or exit 1

set disks (
    jq --raw-output --arg host "$host" '.[$host].disks[]' "$install_data_file"
); or exit 1
test (count $disks) -gt 0; or fail "host '$host' declares no Disko disks"

set device_rows (
    lsblk \
        --json \
        --bytes \
        --nodeps \
        --output PATH,SIZE,TRAN,RM,TYPE |
        jq --raw-output \
            '.blockdevices[]
			     | select(.type == "disk")
				 | [
				     .path,
				     "size=" + (((.size / 1073741824) * 10 | round) / 10 | tostring) + " GiB",
				     "transport=" + (.tran // "unknown"),
				     (if .rm then "removable" else "fixed" end)
				   ]
				 | @tsv'
); or exit 1
test (count $device_rows) -ge (count $disks); or \
    fail "host '$host' needs "(count $disks)" disks, but only "(count $device_rows)" are available"

set disko_args
set selected_devices
set selected_rows

for disk in $disks
    set available_rows

    for row in $device_rows
        set candidate (string split \t -- "$row")[1]
        contains -- "$candidate" $selected_devices; or \
            set --append available_rows "$row"
    end

    set choice (
        printf '%s\n' $available_rows |
            gum choose --header "Select device for Disko disk '$disk'"
    ); or exit 1
    test -n "$choice"; or exit 1

    set device (string split \t -- "$choice")[1]
    test -b "$device"; or fail "not a block device: $device"

    set --append disko_args --disk "$disk" "$device"
    set --append selected_devices "$device"
    set --append selected_rows "$choice"
end

set disk2device
for index in (seq (count $disks))
    set device_info (string replace --all \t " | " -- "$selected_rows[$index]")
    set --append disk2device \
        "  "$disks[$index]" -> "$device_info
end

info "Installation Ready"

gum style --foreground 1 --bold \
    "WARNING: continuing will erase every selected device"
gum style \
	--border double \
    --border-foreground 1 \
    --padding "1 2" \
    --bold \
    "Host: $host" \
    "Disks:" \
    $disk2device

gum confirm "Format the selected devices and install '$host'?"; or exit 0

# =========================
# Installation

info "Start Installation"

set install_args \
	--flake "$flake#$host" \
	--write-efi-boot-entries \
	$disko_args

if test (id --user) -eq 0
	disko-install $install_args
else
	/run/wrappers/bin/sudo disko-install $install_args
end; or fail "installation failed; the selected disks may be partially formatted"

info "Installation Complete. Installed OS Unmounted"
