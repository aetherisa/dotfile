-------------------------------------------------
-- diagnostic settings
-------------------------------------------------
return function()
	local augroup = vim.api.nvim_create_augroup(
		"core.native.diagnostic",
		{ clear = true }
	)

	-- options
	vim.diagnostic.config({
		underline = true,
		virtual_text = {
			current_line = true
		},
		virtual_lines = false,
		update_in_insert = false,
		severity_sort = true,
		signs = {
			severity = {
				vim.diagnostic.severity.ERROR,
				vim.diagnostic.severity.WARN
			},
			text = {
				[vim.diagnostic.severity.ERROR] = "󰅗 ",
				[vim.diagnostic.severity.WARN] = "󰀧 ",
			},
		},
	})

	-- keymaps
	vim.api.nvim_create_autocmd("LspAttach", {
		group = augroup,
		callback = function(env)
			local keymap_opt = {
				silent = true,
				buffer = env.buf
			}

			vim.keymap.set("n", "<S-Down>", 
				function() 
					vim.diagnostic.jump({ count = 1 }) 
				end, keymap_opt)

			vim.keymap.set("n", "<S-Up>",
				function() 
					vim.diagnostic.jump({ count = -1 }) 
				end, keymap_opt)

			vim.keymap.set("n", "<C-k>", vim.diagnostic.open_float, keymap_opt)
		end
	})
end
