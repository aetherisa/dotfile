------------------------
-- hyprland rules
------------------------
local apps = require("apps")

----------------------
-- Window rules

-- swallowed editor windows should only fade, without sliding or zooming
hl.window_rule({
	name = "fade-editor",
	match = {
		class = apps.editor.class,
	},
	animation = "popin 100%",
})

-- GTK portal file choosers can negotiate a monitor-height transient window
-- under fractional scaling. Give them a predictable dialog-sized geometry.
hl.window_rule({
	name = "gtk-file-chooser",
	match = {
		class = "xdg-desktop-portal-gtk",
	},
	float = true,
	size = {
		"monitor_w*0.7",
		"monitor_h*0.75",
	},
	center = true,
})

-- fullscreen browser
hl.window_rule({
    name = "maximized-browser",
    match = {
        class = apps.browser.class,
    },
    fullscreen = true,
})

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

-- launch initial terminal on special workspace
hl.workspace_rule({
	workspace = "special:magic",
	on_created_empty = apps.terminal.command
})

-- launch browser on workspace 2
hl.workspace_rule({
	workspace = "2",
	on_created_empty = apps.browser.command
})
