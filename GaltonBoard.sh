#!/bin/sh
echo -ne '\033c\033]0;GaltonBoard\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/GaltonBoard.x86_64" "$@"
