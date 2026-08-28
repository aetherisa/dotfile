-------------------------------------------------
-- fuzzy finder
-------------------------------------------------
return function()
	local layout = {
		layout_strategy = "bottom_pane",
		layout_config = {
			height = 0.6,
			preview_cutoff = 80,
			prompt_position = "bottom",
		},
		border = true,
		borderchars = { "═", " ", " ", " ", " ", " ", " ", " " },
		winblend = vim.o.winblend,
	}

	require("telescope").setup({
		defaults = {
			file_ignore_patterns = {
				"^.git/",
				"^target/",
			},

			prompt_prefix = " ",
			selection_caret = " ",
			multi_icon = " ",

			mappings = {
				i = {
					["<Esc>"] = "close",
				},
			},
		},

		pickers = {
			builtin = layout,
			live_grep = layout,
			buffers = layout,
			oldfiles = layout,
			grep_string = layout,
			help_tags = layout,
			find_files = vim.tbl_deep_extend("force", layout, {
				hidden = true,
			}),
		},

		extensions = {
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mode = "smart_case",
			},
		},
	})

	require("telescope").load_extension("fzf")

	local builtin = require("telescope.builtin")
	local keymap_options = { silent = true }

	vim.keymap.set("n", "<Leader>tt", builtin.builtin, keymap_options)
	vim.keymap.set("n", "<Leader>tf", builtin.find_files, keymap_options)
	vim.keymap.set("n", "<Leader>to", builtin.oldfiles, keymap_options)
	vim.keymap.set("n", "<Leader>tg", builtin.live_grep, keymap_options)
end
