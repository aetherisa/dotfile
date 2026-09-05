------------------------
-- hyprland binds
------------------------
local apps = require("apps")
local mod = "SUPER"

----------------------
-- Application

-- MOD + Return -> launch terminal
hl.bind(mod .. "+ Return", hl.dsp.exec_cmd(apps.terminal.command))

-- Mod + S -> start screen pick
hl.bind(mod .. "+ S", hl.dsp.exec_cmd(apps.shell.command.screenpick.start))

-- Mod + A -> stop screen pick
hl.bind(mod .. "+ A", hl.dsp.exec_cmd(apps.shell.command.screenpick.stop))

----------------------
-- Workspace

-- MOD + W -> special workspace
hl.bind(mod .. "+ W", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. "+ SHIFT + W", hl.dsp.window.move({ workspace = "special:magic" }))

-- MOD + [0, 10] -> switch workspace
for i = 1, 10 do
	local key = i % 10
	hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- MOD + [SHIFT] + Tab -> switch prev/next workspace
hl.bind(mod .. " + Tab", hl.dsp.focus({ workspace = "+1" }))
hl.bind(mod .. " + SHIFT + Tab",  hl.dsp.focus({ workspace = "-1" }))

----------------------
-- Window

-- MOD + Arrows -> focus window
hl.bind(mod .. " + Left", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + Right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + Up", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + Down", hl.dsp.focus({ direction = "down" }))

-- MOD + SHIFT + Arrows -> move window
hl.bind(mod .. " + SHIFT + Left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + Right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + Up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + Down", hl.dsp.window.move({ direction = "down" }))

-- MOD + LMB -> move window
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })

-- MOD + F -> fullscreen
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- MOD + Q -> close window
hl.bind(mod .. " + Q", hl.dsp.window.close())

----------------------
-- Miscellaneous

-- MOD + SHIFT + Q -> exit hyprland
hl.bind(mod .. " + SHIFT + Q", hl.dsp.exit())

-- XF86 Audio/Brightness -> Audio/Brightness control
local vbopts = {
	locked = true,
	repeating = true,
}

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), vbopts)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), vbopts)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), vbopts)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), vbopts)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), vbopts)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), vbopts)
