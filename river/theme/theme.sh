#!/usr/bin/env bash

## Copyright (C) 2020-2023 Aditya Shakya <adi1090x@gmail.com>
##
## Script To Apply Themes

## Theme ------------------------------------
DIR="$HOME/.config/river"

## Directories ------------------------------
PATH_ALAC="$DIR/alacritty"
PATH_FOOT="$DIR/foot"
PATH_MAKO="$DIR/mako"
PATH_ROFI="$DIR/rofi"
PATH_WAYB="$DIR/waybar"
PATH_WOFI="$DIR/wofi"

## Source Theme File ------------------------
CURRENT_THEME="$DIR/theme/current.bash"
DEFAULT_THEME="$DIR/theme/default.bash"
PYWAL_THEME="$HOME/.cache/wal/colors.sh"

## Check if current file exist
if [[ ! -e "$CURRENT_THEME" ]]; then
	touch "$CURRENT_THEME"
fi

## Default Theme
source_default() {
	cat ${DEFAULT_THEME} > ${CURRENT_THEME}
	source ${CURRENT_THEME}
	altbackground="`pastel color $background | pastel lighten 0.05 | pastel format hex`"
	altforeground="`pastel color $foreground | pastel darken 0.30 | pastel format hex`"
	accent="$color4"
	notify-send -h string:x-canonical-private-synchronous:sys-notify-dtheme -u normal -i ${PATH_MAKO}/icons/palette.png "Applying Default Theme..."
}

## Random Theme
source_pywal() {
	# Set you wallpaper directory here.
	WALLDIR="`xdg-user-dir PICTURES`/wallpapers"

	# Check for wallpapers
	check_wallpaper() {
		if [[ -d "$WALLDIR" ]]; then
			WFILES="`ls --format=single-column $WALLDIR | wc -l`"
			if [[ "$WFILES" == 0 ]]; then
				notify-send -h string:x-canonical-private-synchronous:sys-notify-noimg -u low -i ${PATH_MAKO}/icons/picture.png "There are no wallpapers in : $WALLDIR"
				exit
			fi
		else
			mkdir -p "$WALLDIR"
			notify-send -h string:x-canonical-private-synchronous:sys-notify-noimg -u low -i ${PATH_MAKO}/icons/picture.png "Put some wallpapers in : $WALLDIR"
			exit
		fi
	}

	# Run `pywal` to generate colors
	generate_colors() {	
		check_wallpaper
		if [[ `which wal` ]]; then
			notify-send -t 50000 -h string:x-canonical-private-synchronous:sys-notify-runpywal -i ${PATH_MAKO}/icons/timer.png "Generating Colorscheme. Please wait..."
			wal -q -n -s -t -e -i "$WALLDIR"
			if [[ "$?" != 0 ]]; then
				notify-send -h string:x-canonical-private-synchronous:sys-notify-runpywal -u normal -i ${PATH_MAKO}/icons/palette.png "Failed to generate colorscheme."
				exit
			fi
		else
			notify-send -h string:x-canonical-private-synchronous:sys-notify-runpywal -u normal -i ${PATH_MAKO}/icons/palette.png "'pywal' is not installed."
			exit
		fi
	}

	generate_colors
	cat ${PYWAL_THEME} > ${CURRENT_THEME}
	source ${CURRENT_THEME}
	altbackground="`pastel color $background | pastel lighten 0.05 | pastel format hex`"
	altforeground="`pastel color $foreground | pastel darken 0.30 | pastel format hex`"
	accent="$color4"
}

## Wallpaper ---------------------------------
apply_wallpaper() {
	sed -i -e "s#WALLPAPER=.*#WALLPAPER='$wallpaper'#g" ${DIR}/scripts/wallpaper
	bash ${DIR}/scripts/wallpaper &
}

## Alacritty ---------------------------------
apply_alacritty() {
	# alacritty : colors
	cat > ${PATH_ALAC}/colors.yml <<- _EOF_
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

## Foot --------------------------------------
apply_foot() {
	# foot : colors
	cat > ${PATH_FOOT}/colors.ini <<- _EOF_
		## Colors configuration
		[colors]
		alpha=1.0
		foreground=${foreground:1}
		background=${background:1}

		## Normal/regular colors (color palette 0-7)
		regular0=${color0:1}  # black
		regular1=${color1:1}  # red
		regular2=${color2:1}  # green
		regular3=${color3:1}  # yellow
		regular4=${color4:1}  # blue
		regular5=${color5:1}  # magenta
		regular6=${color6:1}  # cyan
		regular7=${color7:1}  # white

		## Bright colors (color palette 8-15)
		bright0=${color8:1}   # bright black
		bright1=${color9:1}   # bright red
		bright2=${color10:1}   # bright green
		bright3=${color11:1}   # bright yellow
		bright4=${color12:1}   # bright blue
		bright5=${color13:1}   # bright magenta
		bright6=${color14:1}   # bright cyan
		bright7=${color15:1}   # bright white
	_EOF_
}

## Mako --------------------------------------
apply_mako() {
	# mako : config
	sed -i '/# Mako_Colors/Q' ${PATH_MAKO}/config
	cat >> ${PATH_MAKO}/config <<- _EOF_
		# Mako_Colors
		background-color=${background}
		text-color=${foreground}
		border-color=${altbackground}
		progress-color=over ${accent}

		[urgency=low]
		border-color=${altbackground}
		default-timeout=2000

		[urgency=normal]
		border-color=${altbackground}
		default-timeout=5000

		[urgency=high]
		border-color=${color1}
		text-color=${color1}
		default-timeout=0
	_EOF_

	pkill mako && bash ${DIR}/scripts/notifications &
}

## Rofi --------------------------------------
apply_rofi() {
	# rofi : colors
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

## Waybar ------------------------------------
apply_waybar() {
	# waybar : colors
	cat > ${PATH_WAYB}/colors.css <<- EOF
		/** ********** Colors ********** **/
		@define-color background     ${background};
		@define-color background-alt ${altbackground};
		@define-color foreground     ${foreground};
		@define-color selected       ${accent};
		@define-color black          ${color0};
		@define-color red            ${color1};
		@define-color green          ${color2};
		@define-color yellow         ${color3};
		@define-color blue           ${color4};
		@define-color magenta        ${color5};
		@define-color cyan           ${color6};
		@define-color white          ${color7};
	EOF

	pkill waybar && bash ${DIR}/scripts/statusbar &
}

## Wofi --------------------------------------
apply_wofi() {
	# wofi : colors	
	sed -i ${PATH_WOFI}/style.css ${PATH_WOFI}/power.css \
		-e "s/@define-color background .*/@define-color background     ${background};/g" \
		-e "s/@define-color background-alt .*/@define-color background-alt ${altbackground};/g" \
		-e "s/@define-color foreground .*/@define-color foreground     ${foreground};/g" \
		-e "s/@define-color selected .*/@define-color selected       ${accent};/g" \
		-e "s/@define-color black .*/@define-color black          ${color0};/g" \
		-e "s/@define-color red .*/@define-color red            ${color1};/g" \
		-e "s/@define-color green .*/@define-color green          ${color2};/g" \
		-e "s/@define-color yellow .*/@define-color yellow         ${color3};/g" \
		-e "s/@define-color blue .*/@define-color blue           ${color4};/g" \
		-e "s/@define-color magenta .*/@define-color magenta        ${color5};/g" \
		-e "s/@define-color cyan .*/@define-color cyan           ${color6};/g" \
		-e "s/@define-color white .*/@define-color white          ${color7};/g"
}

## River --------------------------------------
apply_river() {
	# river : theme
	sed -i ${DIR}/init \
		-e "s/background_color =.*/background_color = '0x${background:1}'/g" \
		-e "s/focused_border =.*/focused_border = '0x${accent:1}'/g" \
		-e "s/unfocused_border =.*/unfocused_border = '0x${altbackground:1}'/g" \
		-e "s/urgent_border =.*/urgent_border = '0x${color1:1}'/g"
	
	# reload river config
	riverctl border-color-focused 0x${accent:1}
	riverctl border-color-unfocused 0x${altbackground:1}
	riverctl border-color-urgent 0x${color1:1}
}

## Source Theme Accordingly -----------------
if [[ "$1" == '--default' ]]; then
	source_default
elif [[ "$1" == '--pywal' ]]; then
	source_pywal
else
	echo "Available Options: --default  --pywal"
	exit 1
fi

## Execute Script ---------------------------
apply_wallpaper
apply_alacritty
apply_foot
apply_mako
apply_rofi
apply_waybar
apply_wofi
apply_river
