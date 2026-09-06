------------------------
-- hyprland global apps
------------------------
return {
	terminal = {
		command = "ghostty",
		class = "com.mitchellh.ghostty",
	},

	browser = {
		command = "zen-browser",
		class = "zen",
	},

	editor = {
		command = "neovide",
		class = "neovide",
	},

    shell = {
        command = {
            launcher = "qs ipc call launcher open",
            screenpick = {
                start = "qs ipc call picker start",
                stop = "qs ipc call picker stop",
            }
        }
    }
}
