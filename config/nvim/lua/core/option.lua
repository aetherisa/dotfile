-------------------------------------------------
-- option settings
-------------------------------------------------
local tui = {
	-- viewport
	--   roughly stay in center
	--   wrap lines but never split a word
	scrolloff = 8,
	wrap = true,
	linebreak = true,
	breakindent = true,

	-- line number
	number = true,

	-- indentation
	--   turn 1 tab into 4 spaces
	tabstop = 4,
	shiftwidth = 4,
	softtabstop = 4,
	expandtab = true,

	-- search
	ignorecase = true,
	smartcase = true,

	-- splits
	splitbelow = true,
	splitright = true,

	-- files and recovery
	--   persistent undo/swap only
	autoread = true,
	backup = false,
	writebackup = false,
	swapfile = true,
	undofile = true,
	confirm = false,

	-- editing
	virtualedit = "block",
	jumpoptions = "view",

	-- colors and floating window
	termguicolors = true,
	pumheight = 20,
	pumblend = 20,
	winblend = 20,
	winborder = "bold",

	-- interface
	mousemodel = "extend",
	cmdheight = 0,
	laststatus = 3,

	-- status column
	signcolumn = "yes",
	numberwidth = 4,
	statuscolumn = "%s%-3.6l",

	-- clipboard
	--   use system clipboard directly
	clipboard = "unnamedplus",

	-- seperators
	fillchars = "eob: ,horiz:═,horizup:╩,horizdown:╦,vert:║,vertleft:╣,vertright:╠,verthoriz:╬"
}

local gui_opt = {
	guifont = "CaskaydiaCove Nerd Font:h12"
}

local gui_g = {
	neovide_padding_top = 40,
	neovide_padding_bottom = 10,
	neovide_padding_left = 20,
	neovide_padding_right = 20,
	neovide_floating_shadow = false,
}

-- apply tui
for opt, val in pairs(tui) do
	vim.o[opt] = val
end

-- apply gui
if vim.g.neovide then
	for option, value in pairs(gui_opt) do
		vim.o[option] = value
	end

	for opt, val in pairs(gui_g) do
		vim.g[opt] = val
	end
end
