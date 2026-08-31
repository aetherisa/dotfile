#!/usr/bin/env fish

function fail
    gum style --foreground 1 --bold "ERROR: $argv" >&2
    exit 1
end

function info
    gum style --foreground 6 --bold "=======> $argv"
end

info "Start Preparing OS Rebuilding"

# =========================
# Health Check

argparse 'flake=' 'rebuild-data=' -- $argv; or exit 2

set -q _flag_flake; or fail "missing --flake"
set -q _flag_rebuild_data; or fail "missing --rebuild-data"

set flake $_flag_flake
set rebuild_data_file $_flag_rebuild_data
set rebuild_action switch

if test (count $argv) -gt 0
    switch $argv[1]
        case switch boot
            set rebuild_action $argv[1]
            set --erase argv[1]
        case '*'
            fail "invalid rebuild action '$argv[1]'; expected 'switch' or 'boot'"
    end
end

test -r "$rebuild_data_file"; or fail "cannot read rebuild data: $rebuild_data_file"

read --line host </etc/hostname; or fail "cannot determine the current host name"

jq --exit-status --arg host "$host" \
    'index($host) != null' "$rebuild_data_file" >/dev/null; or fail "host '$host' has no nixosConfiguration"

set nixos_rebuild (command --search nixos-rebuild)

test -x /run/wrappers/bin/sudo; or fail "the NixOS sudo wrapper is unavailable"

# =========================
# Rebuild

info "Start Rebuilding OS ($rebuild_action)"

/run/wrappers/bin/sudo "$nixos_rebuild" "$rebuild_action" \
    --flake "$flake#$host" \
    $argv; or fail "failed to rebuild '$host'"

# =========================
# Reload

if test "$rebuild_action" = switch
    info "Start Reload Themes"

    systemctl --user daemon-reload; or fail "failed to reload user systemd units"

    systemctl --user start theme-reload.target; or fail "failed to reload themed applications"
end

info "OS Rebuilding Complete"
