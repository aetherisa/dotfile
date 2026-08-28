-------------------------------------------------
-- signal handlers
-------------------------------------------------
return function()
	-- restart only on no buffer is un-saved
	local function restart()
		local modified = {}

		for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(buffer)
				and vim.bo[buffer].modified
			then
				local name = vim.api.nvim_buf_get_name(buffer)
				if name == "" then
					name = "[No Name " .. buffer .. "]"
				end

				table.insert(modified, name)
			end
		end

		if #modified > 0 then
			vim.notify(
				"configuration reload aborted; unsaved buffer exists",
				vim.log.levels.ERROR
			)
			return
		end

		local ok, err = pcall(vim.cmd.restart)
		if not ok then
			vim.notify(
				"failed to restart neovim\n" .. err,
				vim.log.levels.ERROR
			)
		end
	end

	-- restart neovim on USR1
	local signal = vim.uv.new_signal()
	vim.uv.signal_start(
		signal,
		"sigusr1",
		vim.schedule_wrap(function()
			-- keep the handle reachable for as long as its callback is active.
			if not signal:is_closing() then
				restart()
			end
		end)
	)
end
