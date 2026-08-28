-------------------------------------------------
-- command line
-------------------------------------------------
return function()
	require("vim._core.ui2").enable({})
	require("tiny-cmdline").setup({
		position = {
			x = "50%",
			y = "20%",
		},
		native_types = {},
		title = {
			enabled = true,
			pos = "center",
		},
	})
end
