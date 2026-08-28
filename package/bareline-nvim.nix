{
    fetchFromGitHub,
    vimUtils,
}:

let
    rev = "e44241991f1de4217031643ca1c19c17d525522d";
in
vimUtils.buildVimPlugin {
    pname = "bareline.nvim";
    version = "unstable-${builtins.substring 0 7 rev}";

    src = fetchFromGitHub {
        owner = "aetherisa";
        repo = "bareline.nvim";
        inherit rev;
        hash = "sha256-jn7DIdin/YuUCVCA65YUZbZhBklCIrICnx7RFzxn7nM=";
    };
}
