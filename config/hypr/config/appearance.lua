------------------------
-- hyprland appearance
------------------------
local theme = require("theme")

hl.config({
	general = {
		-- no border
		border_size = 3,
        col = {
            active_border = theme.base02,
            inactive_border = theme.base02,
            nogroup_border = theme.base02,
            nogroup_border_active = theme.base02,
        },

		-- same gaps between window and mointor edge
		gaps_in = 5,
		gaps_out = 10,
		float_gaps = 10,

		-- when no window found given a direction, do nothing
		no_focus_fallback = true,

		-- give master window more space
		layout = "master",

		-- more convenient than keyboard
		resize_on_border = true
	},

	-- scrolling layout
	scrolling = {
		-- keep a lone scratchpad window at a cinematic column size
		fullscreen_on_one_column = false,
		column_width = 0.667,
		focus_fit_method = 0,
		follow_focus = true,
	},

	decoration = {
		rounding = 0,

		-- helps concentration
		active_opacity = 0.9,
		inactive_opacity = 0.8,
		fullscreen_opacity = 1.0,

		blur = {
			enabled = true,
            popups = true,
		},

		shadow = {
			enabled = false,
            -- color = "0xff1a1a1a",
            -- range = 5,
		},
	},

	cursor = {
		-- always hide cursor on keyboard input
		-- even if switch focus between windows
		no_warps = true,
		hide_on_key_press = true,
	}
})
