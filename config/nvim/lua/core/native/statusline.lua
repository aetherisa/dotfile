-------------------------------------------------
-- status bar settings
-------------------------------------------------
return function()
	local augroup = vim.api.nvim_create_augroup(
		"core.native.statusline",
		{ clear = true }
	)

	-- remember whether a named buffer represents a new file.
	vim.api.nvim_create_autocmd("BufNewFile", {
		group = augroup,
		callback = function(event)
			vim.b[event.buf].is_new_file = true
		end,
	})

	-- once written successfully, it is no longer a new file.
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = augroup,
		callback = function(event)
			vim.b[event.buf].is_new_file = false
		end,
	})

	_G.dotfile = _G.dotfile or {}
	_G.dotfile.statusline = function()
		local file_highlight = ""

		if vim.bo.modified or vim.b.is_new_file then
			file_highlight = "%#Underlined#"
		end

		return table.concat({
			file_highlight,
			"%F",
			"%#StatusLine#",
			"%=",
			"%{toupper(&filetype)} %l/%L",
		})
	end

	vim.o.statusline = "%{%v:lua.dotfile.statusline()%}"
end
