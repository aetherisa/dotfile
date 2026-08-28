metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.home" metadata;
assert builtins.hasAttr "theme.colors" metadata;
assert builtins.hasAttr "persistence.enable" metadata;
assert builtins.hasAttr "persistence.userRoot" metadata;
assert builtins.hasAttr "user.modules.neovim" metadata;
{
    lib,
    localpkgs,
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
    userHome = metadata."user.home";
    colors = metadata."theme.colors";
    persist = {
        enable = metadata."persistence.enable";
        userRoot = metadata."persistence.userRoot";
    };

    finalConfig = colors {
        template = ../../template/neovim.mustache;
        extension = ".lua";
    };

    treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (
        grammars: with grammars; [
            bash
            c
            cpp
            css
            fish
            git_config
            git_rebase
            gitattributes
            gitcommit
            html
            javascript
            json
            lua
            markdown
            markdown_inline
            nix
            qmljs
            query
            rust
            toml
            typescript
            vim
            vimdoc
            yaml
        ]
    );

    neovimPackage = pkgs.neovim.override {
        configure = {
            customLuaRC = ''
                dofile(vim.fn.stdpath("config") .. "/init.lua")
            '';
            packages.dotfile.start = with pkgs.vimPlugins; [
                alpha-nvim
                blink-cmp
                blink-ripgrep-nvim
                fidget-nvim
                flash-nvim
                gitsigns-nvim
                indent-blankline-nvim
                nvim-autopairs
                nvim-colorizer-lua
                nvim-lspconfig
                nvim-web-devicons
                plenary-nvim
                telescope-fzf-native-nvim
                telescope-nvim
                treesitter
                localpkgs.bareline-nvim
                localpkgs.tiny-cmdline-nvim
            ];
        };
    };

    reloadTheme = pkgs.writeShellScript "reload-neovim-theme" ''
        ${pkgs.procps}/bin/pkill -USR1 -x nvim 2>/dev/null || true
    '';
in
{
    users.users.${userName}.packages = with pkgs; [
        clang-tools
        kdePackages.qtdeclarative
        neovide
        neovimPackage
        ripgrep
        rust-analyzer
    ];

    systemd.tmpfiles.rules = [
        "d ${userHome}/.config/nvim 0755 ${userName} users -"
        "d ${userHome}/.config/nvim/lua 0755 ${userName} users -"
        "d ${userHome}/.config/nvim/lua/core 0755 ${userName} users -"
        "d ${userHome}/.config/nvim/lua/core/native 0755 ${userName} users -"
        "L+ ${userHome}/.config/nvim/init.lua - - - - ${../../config/nvim/init.lua}"
        "L+ ${userHome}/.config/nvim/lua/core/keymap.lua - - - - ${../../config/nvim/lua/core/keymap.lua}"
        "L+ ${userHome}/.config/nvim/lua/core/native.lua - - - - ${../../config/nvim/lua/core/native.lua}"
        "L+ ${userHome}/.config/nvim/lua/core/option.lua - - - - ${../../config/nvim/lua/core/option.lua}"
        "L+ ${userHome}/.config/nvim/lua/core/plugin.lua - - - - ${../../config/nvim/lua/core/plugin.lua}"
        "L+ ${userHome}/.config/nvim/lua/core/plugin - - - - ${../../config/nvim/lua/core/plugin}"
        "L+ ${userHome}/.config/nvim/lua/core/native/diagnostic.lua - - - - ${../../config/nvim/lua/core/native/diagnostic.lua}"
        "L+ ${userHome}/.config/nvim/lua/core/native/lsp.lua - - - - ${../../config/nvim/lua/core/native/lsp.lua}"
        "L+ ${userHome}/.config/nvim/lua/core/native/signal.lua - - - - ${../../config/nvim/lua/core/native/signal.lua}"
        "L+ ${userHome}/.config/nvim/lua/core/native/statusline.lua - - - - ${../../config/nvim/lua/core/native/statusline.lua}"
        "L+ ${userHome}/.config/nvim/lua/core/native/theme.lua - - - - ${finalConfig}"
        "L+ ${userHome}/.config/nvim/lua/core/native/treesitter.lua - - - - ${../../config/nvim/lua/core/native/treesitter.lua}"
    ];

    systemd.user.services."theme-reload-neovim-${userName}" = {
        description = "Reload Neovim after a theme change";
        wantedBy = [ "theme-reload.target" ];
        unitConfig.ConditionUser = userName;
        serviceConfig = {
            Type = "oneshot";
            ExecStart = reloadTheme;
        };
    };

    environment.persistence = lib.mkIf persist.enable {
        ${persist.userRoot}.users.${userName}.directories = [
            ".local/share/nvim"
            ".local/state/nvim"
        ];
    };
}
