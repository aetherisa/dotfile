metadata:
assert builtins.hasAttr "user.name" metadata;
assert builtins.hasAttr "user.modules.base" metadata;
assert builtins.hasAttr "user.modules.net-devel" metadata;
{
    pkgs,
    ...
}:
let
    userName = metadata."user.name";
in
{
    users.users.${userName}.packages = with pkgs; [
        dnsutils
        iperf3
        mtr
        netcat-openbsd
        nmap
        socat
        tcpdump
        traceroute
        whois
    ];
}
