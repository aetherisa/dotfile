metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "theme.colors" metadata;
assert builtins.hasAttr "user.modules.gum" metadata;
assert builtins.hasAttr "user.modules.fish" metadata;
{
	pkgs,
	...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    colors = metadata."theme.colors";
	finalConfig = colors {
		template = ../../template/gum.mustache;
	};
in
{
	users.users.${userName}.packages = [
		pkgs.gum
	];

	systemd.tmpfiles.rules = [
		"d ${userHome}/.config/fish/conf.d 0755 ${userName} users -"
		"L+ ${userHome}/.config/fish/conf.d/gum.fish - - - - ${finalConfig}"
	];
}
