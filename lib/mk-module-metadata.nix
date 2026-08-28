moduleNames:
builtins.listToAttrs (
    map (name: {
        name = "user.modules.${name}";
        value = true;
    }) moduleNames
)
