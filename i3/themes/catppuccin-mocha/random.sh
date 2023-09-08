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
PATH_I3WM="$PATH_CONF/i3"
PATH_TERM="$PATH_I3WM/alacritty"
PATH_PBAR="$PATH_I3WM/themes/$THEME/polybar"
PATH_ROFI="$PATH_I3WM/themes/$THEME/rofi"

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
altbackground="`pastel color $background | pastel lighten 0.06 | pastel format hex`"
altforeground="`pastel color $foreground | pastel darken 0.50 | pastel format hex`"
accent="$color4"

## Wallpaper ---------------------------------
apply_wallpaper() {
	sed -i -e "s#WALLPAPER=.*#WALLPAPER='$wallpaper'#g" ${PATH_I3WM}/themes/wallpaper.sh
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
	sed -i '/urgency_low/Q' ${PATH_I3WM}/dunstrc
	cat >> ${PATH_I3WM}/dunstrc <<- _EOF_
		[urgency_low]
		timeout = 2
		background = "${background}"
		foreground = "${foreground}"
		frame_color = "${accent}"

		[urgency_normal]
		timeout = 5
		background = "${background}"
		foreground = "${foreground}"
		frame_color = "${accent}"

		[urgency_critical]
		timeout = 0
		background = "${background}"
		foreground = "${color1}"
		frame_color = "${color1}"
	_EOF_
}

# I3WM -------------------------------------
apply_i3wm() {
	# modify i3theme file
	sed -i ${PATH_I3WM}/config.d/01_theme.conf \
		-e "s/set \$i3_cl_col_bg.*/set \$i3_cl_col_bg $background/g" \
		-e "s/set \$i3_cl_col_fg.*/set \$i3_cl_col_fg $foreground/g" \
		-e "s/set \$i3_cl_col_in.*/set \$i3_cl_col_in $color2/g" \
		-e "s/set \$i3_cl_col_afoc.*/set \$i3_cl_col_afoc $accent/g" \
		-e "s/set \$i3_cl_col_ifoc.*/set \$i3_cl_col_ifoc $color4/g" \
		-e "s/set \$i3_cl_col_ufoc.*/set \$i3_cl_col_ufoc $altbackground/g" \
		-e "s/set \$i3_cl_col_urgt.*/set \$i3_cl_col_urgt $color5/g" \
		-e "s/set \$i3_cl_col_phol.*/set \$i3_cl_col_phol $background/g"

	# modify i3bar file
	sed -i ${PATH_I3WM}/i3status/statusbar.conf \
		-e "s/set \$i3_bar_bg.*/set \$i3_bar_bg $background/g" \
		-e "s/set \$i3_bar_fg.*/set \$i3_bar_fg $foreground/g" \
		-e "s/set \$i3_bar_sep.*/set \$i3_bar_sep $altbackground/g" \
		-e "s/set \$i3_bar_foc.*/set \$i3_bar_foc $accent/g" \
		-e "s/set \$i3_bar_act.*/set \$i3_bar_act $color4/g" \
		-e "s/set \$i3_bar_ina.*/set \$i3_bar_ina $altbackground/g" \
		-e "s/set \$i3_bar_urg.*/set \$i3_bar_urg $color5/g" \
		-e "s/set \$i3_bar_mod.*/set \$i3_bar_mod $color2/g"

	# modify i3status file
	sed -i ${PATH_I3WM}/i3status/config \
		-e "s/color_good =.*/color_good = \"$color2\"/g" \
		-e "s/color_degraded =.*/color_degraded = \"$color3\"/g" \
		-e "s/color_bad =.*/color_bad = \"$color1\"/g" \
		-e "s/color_separator =.*/color_separator = \"$altbackground\"/g"
	
	# restart i3wm
	i3-msg restart
}

## Execute Script ---------------------------
apply_wallpaper
apply_polybar
apply_rofi
apply_terminal
apply_dunst
apply_i3wm
