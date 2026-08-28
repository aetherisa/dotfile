-------------------------------------------------
-- dashboard
-------------------------------------------------
return function()
	local augroup = vim.api.nvim_create_augroup(
		"core.plugin.alpha",
		{ clear = true }
	)

	require("alpha").setup({
		layout = {
			{
				type = "padding",
				val = math.floor(vim.o.lines / 4),
			},
			{
				type = "text",
				val = {
					" _. __|_|_  _ ._o _",
					"(_|(/_|_| |(/_| |_>",
				},
				opts = {
					position = "center",
				},
			},
		},
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "AlphaReady",
		group = augroup,
		callback = function(event)
			local laststatus = vim.o.laststatus
			local showtabline = vim.o.showtabline

			vim.o.laststatus = 0
			vim.o.showtabline = 0

			vim.api.nvim_create_autocmd("BufUnload", {
				group = augroup,
				buffer = event.buf,
				callback = function()
					vim.o.laststatus = laststatus
					vim.o.showtabline = showtabline
				end,
			})
		end,
	})
end
