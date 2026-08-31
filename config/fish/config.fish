# ===============================
# Environment Variables
# ===============================
# Basics
set -gx EDITOR "nvim"
set -gx VISUAL "$EDITOR"
set -gx PAGER "less -R"
set -gx MANROFFOPT -c

# ===============================
# Fish Variables
# ===============================
# Enable Vi mode
set -g fish_key_bindings fish_vi_key_bindings

# Disable
set -g fish_greeting ""

# ===============================
# Prompt
# ===============================
# By starship
if status is-interactive
	starship init fish | source
end

# ===============================
# CLIs
# ===============================
# Fzf
if status is-interactive
	fzf --fish | source
end

# Zoxide
if status is-interactive
	zoxide init --cmd cd fish | source
end

# ===============================
# Alias
# ===============================
# Detailed tree-like list
alias ll="eza --long --tree --level=1 \
	--git --icons --color=always \
	--all --smart-group --time-style='iso' \
	--group-directories-first --created \
	--changed --sort=name"

# Simple list
alias l="eza --icons --color=always \
	--group-directories-first \
	--sort=name --all"

# Similar to cdi
alias nvimi='nvim $(fzf)'

# ===============================
# Functions
# ===============================
# Proxy controller
# usage:
#   on -> turn on proxy
#   off -> turn off proxy
#   toggle -> toggle on/off
function proxyctl
	test $(count $argv) -ne 1; and return 1

	switch $argv[1]
		case "on"
			set -gx http_proxy "http://127.0.0.1:7890"
			set -gx https_proxy "http://127.0.0.1:7890"
			set -gx all_proxy "socks5://127.0.0.1:7891"
		case "off"
			set -e http_proxy
			set -e https_proxy
			set -e all_proxy
		case "toggle"
			if set -qg http_proxy
				proxyctl off
			else
				proxyctl on
			end
		case "*"
			echo -n "$(set_color --bold red)Error:$(set_color normal)"
			echo -n " unknown paramater "
			echo "$(set_color --underline)$argv[1]$(set_color normal)"
	end

	return 0
end

# Signal handler
# Reload fish config on USR1
function __reload_fish_config --on-signal USR1
	source $XDG_CONFIG_HOME/fish/config.fish
end

# ===============================
# Others
# ===============================
