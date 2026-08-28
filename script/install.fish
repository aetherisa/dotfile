#!/usr/bin/env fish

argparse \
	'flake=' \
	'host-users=' \
	-- $argv
or exit 2

set flake $_flag_flake
set host_users_file $_flag_host_users

set users (
jq --raw-output \
	--arg host "zen" \
	'.[$host][]' \
	"$host_users_file"
)

echo "flake: $flake"
echo "host_users_file: $host_users_file"
echo "users: $users"
