------------------------
-- hyprland rules
------------------------
local apps = require("apps")

----------------------
-- Window rules

----------------------
-- Workspace rules

-- use a horizontal scrolling layout inside the scratchpad
hl.workspace_rule({
	workspace = "special:magic",
	layout = "scrolling",
	gaps_out = {
		top = 120,
		right = 10,
		bottom = 120,
		left = 10,
	},
})

-- launch initial terminal on workspace 1 & special
hl.workspace_rule({
	workspace = "1",
	on_created_empty = apps.terminal.command
})

hl.workspace_rule({
	workspace = "special:magic",
	on_created_empty = apps.terminal.command
})

-- launch browser on workspace 2
hl.workspace_rule({
	workspace = "2",
	on_created_empty = apps.browser.command
})
