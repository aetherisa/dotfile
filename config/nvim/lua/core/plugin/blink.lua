-------------------------------------------------
-- completion setting
-------------------------------------------------
return function()
	require("blink.cmp").setup({
		completion = {
			-- no default select/auto insert
			list = {
				selection = {
					preselect = false,
					auto_insert = false,
				}
			},

			-- better menu outlook
			menu = {
				winblend = vim.o.winblend,
				winhighlight = "CursorLine:BlinkCmpMenuSelection",
				scrolloff = 4,

				draw = {
					treesitter = { "lsp" },
					columns = {
						{ "kind_icon", "label", "source_name", gap = 1 },
					},
					components = {
						source_name = {
							text = function(ctx) return "[" .. ctx.source_name .. "]" end
						}
					}
				}
			},

			-- better than auto_insert
			ghost_text = {
				enabled = true,
			},
		},

		-- use my own keymap
		keymap = {
			preset = "none",
			["<Tab>"] = { "select_next", "fallback" },
			["<S-Tab>"] = { "select_prev", "fallback" },
			["<Enter>"] = { "accept", "fallback" },
			["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
			["<S-k>"] = { "show_documentation", "hide_documentation", "fallback" },
		},

		-- builtin signature is ok
		signature = {
			enabled = true,
			trigger = {
				show_on_keyword = true,
				show_on_insert = true,
			},
			window = {
				show_documentation = false,
				winblend = vim.o.winblend,
				treesitter_highlighting = true,
				winhighlight = ""
			}
		},

		-- default cmd's keymap sucks
		cmdline = {
			completion = { 
				list = { 
					selection = { 
						preselect = false,
						auto_insert = false 
					} 
				},
				menu = {
					auto_show = true,
				} 
			},
			keymap = { 
				preset = "inherit",
				["<Tab>"] = { "show", "select_next" },
			},
		},

		-- improve source
		sources = {
			default = { 
				"lsp", 
				"buffer", 
				"path",
				"ripgrep",
			},
			providers = {
				lsp = {
					score_offset = 10,
				},
				path = {
					score_offset = 9,
					opts = {
						show_hidden_files_by_default = true
					}
				},
				buffer = {
					score_offset = 8,
				},
				ripgrep = {
					module = "blink-ripgrep",
					name = "Ripgrep",
					score_offset = 7,
					opts = {},
				},
			}
		}
	})
end
