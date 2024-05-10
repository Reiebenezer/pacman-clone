#!/bin/sh
echo -ne '\033c\033]0;Pacman-v2\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/pacman.x86_64" "$@"
