{
    fetchFromGitHub,
    vimUtils,
}:

let
    rev = "e247d9ee4c980734f8f8bf616d31e0ab7c27485d";
in
vimUtils.buildVimPlugin {
    pname = "tiny-cmdline.nvim";
    version = "unstable-${builtins.substring 0 7 rev}";

    src = fetchFromGitHub {
        owner = "rachartier";
        repo = "tiny-cmdline.nvim";
        inherit rev;
        hash = "sha256-DEfoqGFoGdybgZyO+Jqxz4gYkrgoek4cQYulLEsvnU8=";
    };
}
