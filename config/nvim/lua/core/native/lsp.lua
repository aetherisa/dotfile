-------------------------------------------------
-- native LSP client settings
-------------------------------------------------
return function()
	local augroup = vim.api.nvim_create_augroup(
		"core.native.lsp",
		{ clear = true }
	)

	-- per-server behavior owned by this configuration
	local servers = {
		rust_analyzer = {
			inlay_hints = true,
			format_on_save = true,
		},

		clangd = {
			inlay_hints = true,
			format_on_save = false,
		},
	}

	-- activate the server definitions supplied by nvim-lspconfig
	vim.lsp.enable(vim.tbl_keys(servers))

	-- configure features that become available after attachment
	vim.api.nvim_create_autocmd("LspAttach", {
		group = augroup,
		callback = function(event)
			local client = vim.lsp.get_client_by_id(event.data.client_id)

			if not client then
				return
			end

			local preferences = servers[client.name] or {}

			if preferences.inlay_hints and 
				client:supports_method(
					vim.lsp.protocol.Methods.textDocument_inlayHint) then
				vim.lsp.inlay_hint.enable(true, {
					bufnr = event.buf,
				})
			end

			local opts = {
				buffer = event.buf,
				silent = true,
			}

			vim.keymap.set("n", "<Leader>ld", vim.lsp.buf.definition, opts)
			vim.keymap.set("n", "<Leader>lc", vim.lsp.buf.code_action, opts)
			vim.keymap.set("n", "<Leader>ln", vim.lsp.buf.rename, opts)
			vim.keymap.set("n", "K", function()
				vim.lsp.buf.hover({
					max_width = math.floor(vim.o.columns * 0.6),
					max_height = math.floor(vim.o.lines * 0.6),
				})
			end, opts)
		end,
	})

	-- format with the selected server before writing.
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = augroup,
		callback = function(event)
			for _, client in ipairs(vim.lsp.get_clients({ bufnr = event.buf })) do
				local preferences = servers[client.name] or {}

				if preferences.format_on_save and 
					client:supports_method(
						vim.lsp.protocol.Methods.textDocument_formatting
					) 
				then
					vim.lsp.buf.format({
						bufnr = event.buf,
						id = client.id,
						timeout_ms = 1000,
					})

					-- only one server should format a buffer.
					return
				end
			end
		end,
	})
end
