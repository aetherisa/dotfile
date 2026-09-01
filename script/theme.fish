#!/usr/bin/env fish

function fail
    gum style --foreground 1 --bold "ERROR: $argv" >&2
    exit 1
end

function info
    gum style --foreground 6 --bold "=======> $argv"
end

info "Start Preparing Theme Switch"

# =========================
# Health Check

argparse 'theme-data=' -- $argv; or exit 2

set -q _flag_theme_data; or fail "missing --theme-data"
test (count $argv) -eq 1; or fail "expected exactly one theme name"

set theme_data_file $_flag_theme_data
set theme_name $argv[1]

test -r "$theme_data_file"; or fail "cannot read theme data: $theme_data_file"
jq empty "$theme_data_file"; or fail "invalid theme data: $theme_data_file"

jq --exit-status --arg theme "$theme_name" \
    '.themes | index($theme) != null' "$theme_data_file" >/dev/null; or \
    fail "theme '$theme_name' is not declared"

set theme_root (jq --raw-output '.root' "$theme_data_file"); or \
    fail "cannot determine the theme root"

test -d "$theme_root/$theme_name"; or \
    fail "theme '$theme_name' has not been generated"

# =========================
# Switch

info "Switch Theme to '$theme_name'"

set next_active "$theme_root/.active.next"

ln --symbolic --force --no-target-directory \
    "$theme_name" "$next_active"; or fail "failed to prepare the active theme link"

mv --force --no-target-directory \
    "$next_active" "$theme_root/active"; or fail "failed to activate theme '$theme_name'"

# =========================
# Reload

info "Reload Themes"

systemctl --user start theme-reload.target; or \
    fail "failed to reload themed applications"

info "Theme Switch Complete"
