------------------------
-- hyprland animations
------------------------
hl.config({
	animations = {
		enabled = true,
	},
})

hl.curve("linear", {
	type = "bezier",
	points = {
		{ 0, 0 },
		{ 1, 1 }
	}
})

hl.curve("overshoot", { 
	type = "bezier",
	points = { 
		{0.5, 0.9},
		{0.1, 1.1} 
	} 
})

hl.animation({
	leaf = "windows",
	enabled = true,
	speed = 3.5,
	bezier = "overshoot",
	style = "slide"
})

hl.animation({
	leaf = "workspaces",
	enabled = true,
	speed = 2.0,
	bezier = "linear",
	style = "fade"
})

hl.animation({
	leaf = "specialWorkspace",
	enabled = true,
	speed = 3.5,
	bezier = "overshoot",
	style = "slidevert"
})
