#!/usr/bin/env bash

## Copyright (C) 2020-2023 Aditya Shakya <adi1090x@gmail.com>
##
## Apply Random Theme With Pywal

## Theme ------------------------------------
TDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
THEME="${TDIR##*/}"

# Set you wallpaper directory here.
WALLDIR="`xdg-user-dir PICTURES`/wallpapers"
WALFILE="$HOME/.cache/wal/colors.sh"

## Directories ------------------------------
PATH_CONF="$HOME/.config"
PATH_GEANY="$PATH_CONF/geany"
PATH_BSPWM="$PATH_CONF/bspwm"
PATH_TERM="$PATH_BSPWM/alacritty"
PATH_PBAR="$PATH_BSPWM/themes/$THEME/polybar"
PATH_ROFI="$PATH_BSPWM/themes/$THEME/rofi"

## Pywal ------------------------------------
check_wallpaper() {
	if [[ -d "$WALLDIR" ]]; then
		WFILES="`ls --format=single-column $WALLDIR | wc -l`"
		if [[ "$WFILES" == 0 ]]; then
			dunstify -u normal -h string:x-dunst-stack-tag:noimage -i /usr/share/archcraft/icons/dunst/picture.png "There are no wallpapers in : $WALLDIR"
			exit
		fi
	else
		mkdir -p "$WALLDIR"
		dunstify -u normal -h string:x-dunst-stack-tag:noimage -i /usr/share/archcraft/icons/dunst/picture.png "Put some wallpapers in : $WALLDIR"
		exit
	fi
}

generate_colors() {	
	check_wallpaper
	if [[ `which wal` ]]; then
		dunstify -t 50000 -h string:x-dunst-stack-tag:runpywal -i /usr/share/archcraft/icons/dunst/hourglass.png "Generating Colorscheme. Please wait..."
		wal -q -n -s -t -e -i "$WALLDIR"
		if [[ "$?" != 0 ]]; then
			dunstify -u normal -h string:x-dunst-stack-tag:runpywal -i /usr/share/archcraft/icons/dunst/palette.png "Failed to generate colorscheme."
			exit
		fi
	else
		dunstify -u normal -h string:x-dunst-stack-tag:runpywal -i /usr/share/archcraft/icons/dunst/palette.png "'pywal' is not installed."
		exit
	fi
}

generate_colors
source "$WALFILE"
altbackground="`pastel color $background | pastel lighten 0.05 | pastel format hex`"
altforeground="`pastel color $foreground | pastel darken 0.15 | pastel format hex`"
accent="$color4"

## Wallpaper ---------------------------------
apply_wallpaper() {
	feh --bg-fill "$wallpaper"
}

## Polybar -----------------------------------
apply_polybar() {
	# rewrite colors file
	cat > ${PATH_PBAR}/colors.ini <<- EOF
		[color]
		
		BACKGROUND = ${background}
		FOREGROUND = ${foreground}
		ALTBACKGROUND = ${altbackground}
		ALTFOREGROUND = ${altforeground}
		ACCENT = ${accent}
		
		BLACK = ${color0}
		RED = ${color1}
		GREEN = ${color2}
		YELLOW = ${color3}
		BLUE = ${color4}
		MAGENTA = ${color5}
		CYAN = ${color6}
		WHITE = ${color7}
		ALTBLACK = ${color8}
		ALTRED = ${color9}
		ALTGREEN = ${color10}
		ALTYELLOW = ${color11}
		ALTBLUE = ${color12}
		ALTMAGENTA = ${color13}
		ALTCYAN = ${color14}
		ALTWHITE = ${color15}
	EOF
}

# Rofi --------------------------------------
apply_rofi() {
	# rewrite colors file
	cat > ${PATH_ROFI}/shared/colors.rasi <<- EOF
		* {
		    background:     ${background};
		    background-alt: ${altbackground};
		    foreground:     ${foreground};
		    selected:       ${accent};
		    active:         ${color2};
		    urgent:         ${color1};
		}
	EOF
}

# Terminal ----------------------------------
apply_terminal() {
	# alacritty : colors
	cat > ${PATH_TERM}/colors.yml <<- _EOF_
		## Colors configuration
		colors:
		  # Default colors
		  primary:
		    background: '${background}'
		    foreground: '${foreground}'

		  # Normal colors
		  normal:
		    black:   '${color0}'
		    red:     '${color1}'
		    green:   '${color2}'
		    yellow:  '${color3}'
		    blue:    '${color4}'
		    magenta: '${color5}'
		    cyan:    '${color6}'
		    white:   '${color7}'

		  # Bright colors
		  bright:
		    black:   '${color8}'
		    red:     '${color9}'
		    green:   '${color10}'
		    yellow:  '${color11}'
		    blue:    '${color12}'
		    magenta: '${color13}'
		    cyan:    '${color14}'
		    white:   '${color15}'
	_EOF_
}

# Dunst -------------------------------------
apply_dunst() {
	# modify colors
	sed -i '/urgency_low/Q' ${PATH_BSPWM}/dunstrc
	cat >> ${PATH_BSPWM}/dunstrc <<- _EOF_
		[urgency_low]
		timeout = 2
		background = "${background}"
		foreground = "${foreground}"
		frame_color = "${altbackground}"

		[urgency_normal]
		timeout = 5
		background = "${background}"
		foreground = "${foreground}"
		frame_color = "${altbackground}"

		[urgency_critical]
		timeout = 0
		background = "${background}"
		foreground = "${color1}"
		frame_color = "${color1}"
	_EOF_
}

# BSPWM -------------------------------------
apply_bspwm() {
	# modify bspwmrc
	sed -i ${PATH_BSPWM}/bspwmrc \
		-e "s/BSPWM_FBC=.*/BSPWM_FBC='$accent'/g" \
		-e "s/BSPWM_NBC=.*/BSPWM_NBC='$background'/g" \
		-e "s/BSPWM_ABC=.*/BSPWM_ABC='$color5'/g" \
		-e "s/BSPWM_PFC=.*/BSPWM_PFC='$color2'/g"

	# reload bspwm
	bspc wm -r
}

## Execute Script ---------------------------
apply_wallpaper
apply_polybar
apply_rofi
apply_terminal
apply_dunst
apply_bspwm
