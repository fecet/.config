#!/usr/bin/env bash

## Copyright (C) 2020-2023 Aditya Shakya <adi1090x@gmail.com>
##
## Apply wallpaper on i3 startup

WALLPAPER="$HOME/.config/i3/themes/default/wallpaper"

hsetroot -root -cover "$WALLPAPER"
