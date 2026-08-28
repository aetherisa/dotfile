-------------------------------------------------
-- plugins setup
-- plugins are installed by nix
-------------------------------------------------
local plugins = {
	--------------------------------
	-- plugins does not need setup:

	-- "nvim-lspconfig"
	-- "plenary.nvim"
	-- "nvim-web-devicons"
	-- "blink-ripgrep.nvim"
	-- "telescope-fzf-native.nvim"

	--------------------------------
	-- plugins need setup:

	"alpha",
	"autopairs",
	"blink",
	"cmdline",
	"colorizer",
	"flash",
	"gitsigns",
	"indent",
	"telescope",
	"fidget",
	"bareline",
}

for _, name in ipairs(plugins) do
	local ok, setup = pcall(require, "core.plugin." .. name)
	if not ok then
		vim.notify("failed to load " .. name .. "\n" .. setup, vim.log.levels.ERROR)
	else
		local ok, err = pcall(setup)
		if not ok then
			vim.notify("failed to setup " .. name .. "\n" .. err, vim.log.levels.ERROR)
		end
	end
end
