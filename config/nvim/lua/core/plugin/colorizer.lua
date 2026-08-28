-------------------------------------------------
-- color preview
-------------------------------------------------
return function()
	require("colorizer").setup({
		filetypes = {
			"css",
			"scss",
			"sass",
			"less",
			"html",
		},

		user_commands = true,

		options = {
			parsers = {
				-- enable css color syntax
				css = true,

				-- ordinary color names are too noisy
				names = {
					enable = false,
				},

				-- do not interpret bare hashes or identifiers as colors
				hex = {
					no_hash = false,
				},
			},

			display = {
				mode = "virtualtext",
				virtualtext = {
					char = "■",
					position = "after",
				},
			},
		},
	})
end
