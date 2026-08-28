-------------------------------------------------
-- notifications
-------------------------------------------------
return function()
	require("fidget").setup({
		notification = {
			override_vim_notify = true,
		},
	})
end
