#!/bin/sh
echo -ne '\033c\033]0;Space Craft 22\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/space_craft_22.x86_64" "$@"
