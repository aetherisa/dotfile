------------------------
-- hyprland miscellaneous
------------------------
local apps = require("apps")

hl.config({
    misc = {
		-- no default wallpaper
		disable_hyprland_logo = true;
		background_color = "#FFFFFF",

		-- reason why hyprland better than niri
		enable_swallow = false,
		swallow_regex = apps.terminal.class,
    },
})
