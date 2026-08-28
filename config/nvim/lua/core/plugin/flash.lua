-------------------------------------------------
-- movement
-------------------------------------------------
return function()
	require("flash").setup({
		search = {
			mode = "search",
			incremental = false,
		},
		label = {
			style = "eol",
		},
		highlight = {
			backdrop = true,
			matches = true,
			groups = {
				match = "FlashMatch",
				current = "FlashCurrent",
				backdrop = "FlashBackdrop",
				label = "FlashLabel",
			},
		},
		modes = {
			search = { enabled = false },
			char = { enabled = false },
		},
	})

	vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end, {
			silent = true,
			desc = "Flash jump",
		}
	)

	vim.keymap.set({ "n", "x", "o" }, "S", function() require("flash").treesitter() end, {
			silent = true,
			desc = "Flash treesitter",
		}
	)
end
