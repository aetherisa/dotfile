#!/usr/bin/env fish

function fail
    gum style --foreground 1 --bold "error: $argv" >&2
    exit 1
end

function section
    gum style --foreground 6 --bold "$argv"
end

argparse 'flake=' 'install-data=' -- $argv; or exit 2

set -q _flag_flake; or fail "missing --flake"
set -q _flag_install_data; or fail "missing --install-data"

set flake $_flag_flake
set install_data_file $_flag_install_data

test -r "$install_data_file"; or fail "cannot read install data: $install_data_file"
jq empty "$install_data_file"; or fail "invalid install data: $install_data_file"

set hosts (jq --raw-output 'keys[]' "$install_data_file"); or exit 1
test (count $hosts) -gt 0; or fail "the flake contains no installable hosts"

set host (
    printf '%s\n' $hosts |
        gum choose --header "select a host to install"
); or exit 1
test -n "$host"; or exit 1

set disks (
    jq --raw-output --arg host "$host" '.[$host].disks[]' \
        "$install_data_file"
); or exit 1
test (count $disks) -gt 0; or fail "host '$host' declares no Disko disks"

set device_rows (
    lsblk --json --bytes --nodeps --output PATH,SIZE,MODEL,TYPE |
        jq --raw-output \
            '.blockdevices[]
             | select(.type == "disk")
             | [.path, ((.size / 1073741824) | floor | tostring) + " GiB", (.model // "unknown model")]
             | @tsv'
); or exit 1
test (count $device_rows) -ge (count $disks); or \
    fail "host '$host' needs "(count $disks)" disks, but only "(count $device_rows)" are available"

set disko_args
set selected_devices

for disk in $disks
    set available_rows

    for row in $device_rows
        set candidate (string split \t -- "$row")[1]
        contains -- "$candidate" $selected_devices; or \
            set --append available_rows "$row"
    end

    set choice (
        printf '%s\n' $available_rows |
            gum choose --header "select device for Disko disk '$disk'"
    ); or exit 1
    test -n "$choice"; or exit 1

    set device (string split \t -- "$choice")[1]
    test -b "$device"; or fail "not a block device: $device"

    set --append disko_args --disk "$disk" "$device"
    set --append selected_devices "$device"
end

set summary_lines
for index in (seq (count $disks))
    set --append summary_lines \
        "  "$disks[$index]" -> "$selected_devices[$index]
end

gum style \
    --border double \
    --border-foreground 3 \
    --padding "1 2" \
    --bold \
    "Host: $host" \
    "Disk mappings:" \
    $summary_lines

gum style --foreground 1 --bold \
    "WARNING: continuing will erase every selected device."
gum confirm "format the selected devices and install '$host'?"; or exit 0

sudo --validate; or fail "root privileges are required"

section "installing NixOS"
sudo disko-install \
    --flake "$flake#$host" \
    --write-efi-boot-entries \
    $disko_args; or \
    fail "installation failed; the selected disks may be partially formatted"

gum style \
    --foreground 2 \
    --bold \
    "installation complete" \
    "Disko has safely unmounted the installed system"
