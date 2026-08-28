-------------------------------------------------
-- native features setup
-------------------------------------------------
local natives = {
	"lsp",
	"theme",
	"signal",
	"diagnostic",
	"statusline",
	"treesitter",
}

for _, name in ipairs(natives) do
	local ok, setup = pcall(require, "core.native." .. name)
	if not ok then
		vim.notify("failed to load " .. name .. "\n" .. setup, vim.log.levels.ERROR)
	else
		local ok, err = pcall(setup)
		if not ok then
			vim.notify("failed to setup " .. name .. "\n" .. err, vim.log.levels.ERROR)
		end
	end
end
