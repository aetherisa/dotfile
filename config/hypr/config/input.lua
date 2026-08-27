------------------------
-- hyprland input
------------------------
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

		-- detach mouse focus from keyboard
		-- click window to switch keyboard focus
		follow_mouse = 2,

        touchpad = {
			-- scroll up -> scroll down
			-- scroll down -> scroll up
            natural_scroll = true,
        },
    },
})
