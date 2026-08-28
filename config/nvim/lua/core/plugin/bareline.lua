-------------------------------------------------
-- buffer indicators
-------------------------------------------------
return function()
	require("bareline").setup({
		buffer = {
			active = {
				char = "▔",
			},
			inactive = {
				char = "▔",
			},
		},
		indicator = {
			left = {
				text = "▔▔ ",
			},
			right = {
				text = " ▔▔",
			},
		},
	})
end
