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
PATH_TERM="$PATH_CONF/alacritty"
PATH_DUNST="$PATH_CONF/dunst"
PATH_OBOX="$PATH_CONF/openbox"
PATH_OBTS="$PATH_CONF/openbox-themes"
PATH_PBAR="$PATH_OBTS/themes/$THEME/polybar"
PATH_ROFI="$PATH_OBTS/themes/$THEME/rofi"
PATH_XFCE="$PATH_CONF/xfce4/terminal"

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
altforeground="`pastel color $foreground | pastel darken 0.50 | pastel format hex`"
accent="$color4"

## Wallpaper ---------------------------------
apply_wallpaper() {
	for head in {0..10}; do
		nitrogen --head=$head --save --set-zoom-fill "$wallpaper" &>/dev/null
	done
}

## Polybar -----------------------------------
apply_polybar() {
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

## Rofi --------------------------------------
apply_rofi() {
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

## Terminal ----------------------------------
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

	# xfce terminal : colors
	sed -i ${PATH_XFCE}/terminalrc \
		-e "s/ColorBackground=.*/ColorBackground=${background}/g" \
		-e "s/ColorForeground=.*/ColorForeground=${foreground}/g" \
		-e "s/ColorCursor=.*/ColorCursor=${foreground}/g" \
		-e "s/ColorPalette=.*/ColorPalette=${color0};${color1};${color2};${color3};${color4};${color5};${color6};${color7};${color8};${color9};${color10};${color11};${color12};${color13};${color14};${color15}/g"
}

## Dunst -------------------------------------
apply_dunst() {
	sed -i '/urgency_low/Q' ${PATH_DUNST}/dunstrc
	cat >> ${PATH_DUNST}/dunstrc <<- _EOF_
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

	# restart dunst
	pkill dunst && dunst &
}

## Openbox -----------------------------------
apply_openbox() {
	namespace="http://openbox.org/3.4/rc"
	obconfig="$PATH_OBOX/rc.xml"

	if [[ ! -d "$HOME/.themes/ob-random" ]]; then
		mkdir -p "$HOME/.themes" && cp -r /usr/share/archcraft/openbox/ob-random "$HOME/.themes"
	fi
	
	# Generate themerc file
	cat > "$HOME"/.themes/ob-random/openbox-3/themerc <<- EOF
		#-- Random OB Theme -----------------------------------------------
		padding.width: 10
		padding.height: 10
		window.client.padding.width: 0
		window.client.padding.height: 0
		window.handle.width: 5
		border.width: 0
		osd.border.width: 5
		menu.border.width: 10
		menu.overlap.x: -15
		menu.overlap.y: 10
		menu.separator.width: 1
		menu.separator.padding.width: 0
		menu.separator.padding.height: 2
		window.active.label.text.font: shadow=n
		window.inactive.label.text.font: shadow=n
		menu.items.font: shadow=n
		menu.title.text.font: shadow=n
		osd.label.text.font: shadow=n
		window.label.text.justify: Center
		menu.title.text.justify: Center
		
		#-- Border colors -------------------------------------------------
		window.active.border.color: ${background}
		window.inactive.border.color: ${background}
		window.active.client.color: ${background}
		window.inactive.client.color: ${background}
		window.active.title.separator.color: ${background}
		window.inactive.title.separator.color: ${background}
		
		#-- Active window -------------------------------------------------
		window.active.title.bg: Flat Solid
		window.active.title.bg.color: ${background}
		window.active.label.bg: Parentrelative
		window.active.label.text.color: ${foreground}
		window.active.handle.bg: Flat Solid
		window.active.handle.bg.color: ${background}
		window.active.grip.bg: Flat Solid
		window.active.grip.bg.color: ${background}
		window.active.button.unpressed.bg: Flat Solid
		window.active.button.unpressed.bg.color: ${background}
		window.active.button.unpressed.image.color: ${foreground}
		window.active.button.pressed.bg: Flat Solid
		window.active.button.pressed.bg.color: ${background}
		window.active.button.pressed.image.color: ${accent}
		window.active.button.disabled.bg: Flat Solid
		window.active.button.disabled.bg.color: ${background}
		window.active.button.disabled.image.color: ${altbackground}
		window.active.button.hover.bg: Flat Solid
		window.active.button.hover.bg.color: ${background}
		window.active.button.hover.image.color: ${color2}
		window.active.button.toggled.unpressed.bg: Flat Solid
		window.active.button.toggled.unpressed.bg.color: ${background}
		window.active.button.toggled.unpressed.image.color: ${foreground}
		window.active.button.toggled.pressed.bg: Flat Solid
		window.active.button.toggled.pressed.bg.color: ${background}
		window.active.button.toggled.pressed.image.color: ${accent}
		window.active.button.toggled.hover.bg: Flat Solid
		window.active.button.toggled.hover.bg.color: ${background}
		window.active.button.toggled.hover.image.color: ${color2}
		
		#-- Inactive windows -----------------------------------------------
		window.inactive.title.bg: Flat Solid
		window.inactive.title.bg.color: ${background}
		window.inactive.label.bg: Parentrelative
		window.inactive.label.text.color: ${altforeground}
		window.inactive.handle.bg: Flat Solid
		window.inactive.handle.bg.color: ${background}
		window.inactive.grip.bg: Flat Solid
		window.inactive.grip.bg.color: ${background}
		window.inactive.button.unpressed.bg: Flat Solid
		window.inactive.button.unpressed.bg.color: ${background}
		window.inactive.button.unpressed.image.color: ${altforeground}
		window.inactive.button.pressed.bg: Flat Solid
		window.inactive.button.pressed.bg.color: ${background}
		window.inactive.button.pressed.image.color: ${accent}
		window.inactive.button.disabled.bg: Flat Solid
		window.inactive.button.disabled.bg.color: ${background}
		window.inactive.button.disabled.image.color: ${altbackground}
		window.inactive.button.hover.bg: Flat Solid
		window.inactive.button.hover.bg.color: ${background}
		window.inactive.button.hover.image.color: ${color2}
		window.inactive.button.toggled.unpressed.bg: Flat Solid
		window.inactive.button.toggled.unpressed.bg.color: ${background}
		window.inactive.button.toggled.unpressed.image.color: ${altforeground}
		window.inactive.button.toggled.pressed.bg: Flat Solid
		window.inactive.button.toggled.pressed.bg.color: ${background}
		window.inactive.button.toggled.pressed.image.color: ${accent}
		window.inactive.button.toggled.hover.bg: Flat Solid
		window.inactive.button.toggled.hover.bg.color: ${background}
		window.inactive.button.toggled.hover.image.color: ${color2}
		
		#-- Close Button -------------------------------------------------
		window.active.button.close.pressed.image.color: ${color1}
		window.active.button.close.hover.image.color: ${color1}
		window.inactive.button.close.pressed.image.color: ${color1}
		window.inactive.button.close.hover.image.color: ${color1}
		
		#-- Menu ---------------------------------------------------------
		menu.title.bg: Flat Solid
		menu.title.bg.color: ${altbackground}
		menu.title.text.color: ${foreground}
		menu.items.bg: Flat Solid
		menu.items.bg.color: ${background}
		menu.items.text.color: ${foreground}
		menu.items.disabled.text.color: ${altforeground}
		menu.items.active.bg: Flat Solid
		menu.items.active.bg.color: ${accent}
		menu.items.active.text.color: ${background}
		menu.items.active.disabled.text.color: ${foreground}
		menu.separator.color: ${background}
		menu.border.color: ${background}
		
		#-- OSD Settings -------------------------------------------------
		osd.bg: Flat Solid
		osd.bg.color: ${background}
		osd.label.text.color: ${foreground}
		osd.border.color: ${altbackground}
		osd.active.label.bg: Flat Solid
		osd.active.label.bg.color: ${background}
		osd.active.label.text.color: ${accent}
		osd.inactive.label.bg: Flat Solid
		osd.inactive.label.bg.color: ${background}
		osd.inactive.label.text.color: ${foreground}
		osd.hilight.bg: Flat Solid
		osd.hilight.bg.color: ${accent}
		osd.unhilight.bg: Flat Solid
		osd.unhilight.bg.color: ${background}
	EOF

	# Change Theme
	xmlstarlet ed -L -N a="$namespace" -u '/a:openbox_config/a:theme/a:name' -v 'ob-random' "$obconfig"

	# Reload Openbox Config
	openbox --reconfigure
}

## Execute Script ---------------------------
apply_wallpaper
apply_polybar
apply_rofi
apply_terminal
apply_dunst
apply_openbox

# launch polybar / tint2
bash ${PATH_OBTS}/themes/launch-bar.sh
