-------------------------------------------------
-- treesitter setup
-------------------------------------------------
return function()
	local augroup = vim.api.nvim_create_augroup(
		"core.native.treesitter", 
		{ clear = true }
	)
	
	-- auto enable highlighting
	vim.api.nvim_create_autocmd("FileType", {
		group = augroup,
		callback = function(env)
			local filetype = vim.bo[env.buf].filetype
			local lang = vim.treesitter.language.get_lang(filetype) or filetype
			if vim.treesitter.language.add(lang) then
				vim.treesitter.start(env.buf, lang)
			end
		end
	})
end
