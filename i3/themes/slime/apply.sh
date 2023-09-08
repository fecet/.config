#!/usr/bin/env bash

## Copyright (C) 2020-2023 Aditya Shakya <adi1090x@gmail.com>
##
## Script To Apply Themes

## Theme ------------------------------------
IDIR="$HOME/.config/i3"
TDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
THEME="${TDIR##*/}"

source "$IDIR"/themes/"$THEME"/theme.bash
altbackground="`pastel color $background | pastel darken $dark_value | pastel format hex`"
altforeground="`pastel color $foreground | pastel lighten $light_value | pastel format hex`"

## Directories ------------------------------
PATH_CONF="$HOME/.config"
PATH_GEANY="$PATH_CONF/geany"
PATH_I3WM="$PATH_CONF/i3"
PATH_TERM="$PATH_I3WM/alacritty"
PATH_PBAR="$PATH_I3WM/themes/$THEME/polybar"
PATH_ROFI="$PATH_I3WM/themes/$THEME/rofi"

## Wallpaper ---------------------------------
apply_wallpaper() {
	sed -i -e "s#WALLPAPER=.*#WALLPAPER='$wallpaper'#g" ${PATH_I3WM}/themes/wallpaper.sh
}

## Polybar -----------------------------------
apply_polybar() {
	# modify polybar launch script
	sed -i -e "s/STYLE=.*/STYLE=\"$THEME\"/g" ${PATH_I3WM}/themes/polybar.sh

	# apply default theme fonts
	sed -i -e "s/font-0 = .*/font-0 = \"$polybar_font\"/g" ${PATH_PBAR}/config.ini

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
	# modify rofi scripts
	sed -i -e "s/STYLE=.*/STYLE=\"$THEME\"/g" \
		${PATH_I3WM}/scripts/rofi_askpass \
		${PATH_I3WM}/scripts/rofi_asroot \
		${PATH_I3WM}/scripts/rofi_bluetooth \
		${PATH_I3WM}/scripts/rofi_launcher \
		${PATH_I3WM}/scripts/rofi_music \
		${PATH_I3WM}/scripts/rofi_powermenu \
		${PATH_I3WM}/scripts/rofi_runner \
		${PATH_I3WM}/scripts/rofi_screenshot \
		${PATH_I3WM}/scripts/rofi_themes \
		${PATH_I3WM}/scripts/rofi_windows
	
	# apply default theme fonts
	sed -i -e "s/font:.*/font: \"$rofi_font\";/g" ${PATH_ROFI}/shared/fonts.rasi

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

	# modify icon theme
	if [[ -f "$PATH_CONF"/rofi/config.rasi ]]; then
		sed -i -e "s/icon-theme:.*/icon-theme: \"$rofi_icon\";/g" ${PATH_CONF}/rofi/config.rasi
	fi
}

# Network Menu ------------------------------
apply_netmenu() {
	if [[ -f "$PATH_I3WM"/themes/networkmenu_config.ini ]]; then
		sed -i -e "s#dmenu_command = .*#dmenu_command = rofi -dmenu -theme $PATH_ROFI/networkmenu.rasi#g" ${PATH_I3WM}/themes/networkmenu_config.ini
	fi
}

# Terminal ----------------------------------
apply_terminal() {
	# alacritty : fonts
	sed -i ${PATH_TERM}/fonts.yml \
		-e "s/family: .*/family: \"$terminal_font_name\"/g" \
		-e "s/size: .*/size: $terminal_font_size/g"

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

# Geany -------------------------------------
apply_geany() {
	sed -i ${PATH_GEANY}/geany.conf \
		-e "s/color_scheme=.*/color_scheme=$geany_colors/g" \
		-e "s/editor_font=.*/editor_font=$geany_font/g"
}

# Appearance --------------------------------
apply_appearance() {
	XFILE="$PATH_I3WM/xsettingsd"
	GTK2FILE="$HOME/.gtkrc-2.0"
	GTK3FILE="$PATH_CONF/gtk-3.0/settings.ini"

	# apply gtk theme, icons, cursor & fonts
	if [[ `pidof xsettingsd` ]]; then
		sed -i -e "s|Net/ThemeName .*|Net/ThemeName \"$gtk_theme\"|g" ${XFILE}
		sed -i -e "s|Net/IconThemeName .*|Net/IconThemeName \"$icon_theme\"|g" ${XFILE}
		sed -i -e "s|Gtk/CursorThemeName .*|Gtk/CursorThemeName \"$cursor_theme\"|g" ${XFILE}
	else
		sed -i -e "s/gtk-font-name=.*/gtk-font-name=\"$gtk_font\"/g" ${GTK2FILE}
		sed -i -e "s/gtk-theme-name=.*/gtk-theme-name=\"$gtk_theme\"/g" ${GTK2FILE}
		sed -i -e "s/gtk-icon-theme-name=.*/gtk-icon-theme-name=\"$icon_theme\"/g" ${GTK2FILE}
		sed -i -e "s/gtk-cursor-theme-name=.*/gtk-cursor-theme-name=\"$cursor_theme\"/g" ${GTK2FILE}
		
		sed -i -e "s/gtk-font-name=.*/gtk-font-name=$gtk_font/g" ${GTK3FILE}
		sed -i -e "s/gtk-theme-name=.*/gtk-theme-name=$gtk_theme/g" ${GTK3FILE}
		sed -i -e "s/gtk-icon-theme-name=.*/gtk-icon-theme-name=$icon_theme/g" ${GTK3FILE}
		sed -i -e "s/gtk-cursor-theme-name=.*/gtk-cursor-theme-name=$cursor_theme/g" ${GTK3FILE}
	fi
	
	# inherit cursor theme
	if [[ -f "$HOME"/.icons/default/index.theme ]]; then
		sed -i -e "s/Inherits=.*/Inherits=$cursor_theme/g" "$HOME"/.icons/default/index.theme
	fi	
}

# Dunst -------------------------------------
apply_dunst() {
	# modify dunst config
	sed -i ${PATH_I3WM}/dunstrc \
		-e "s/width = .*/width = $dunst_width/g" \
		-e "s/height = .*/height = $dunst_height/g" \
		-e "s/offset = .*/offset = $dunst_offset/g" \
		-e "s/origin = .*/origin = $dunst_origin/g" \
		-e "s/font = .*/font = $dunst_font/g" \
		-e "s/frame_width = .*/frame_width = $dunst_border/g" \
		-e "s/separator_height = .*/separator_height = $dunst_separator/g" \
		-e "s/line_height = .*/line_height = $dunst_separator/g"

	# modify colors
	sed -i '/urgency_low/Q' ${PATH_I3WM}/dunstrc
	cat >> ${PATH_I3WM}/dunstrc <<- _EOF_
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

# Compositor --------------------------------
apply_compositor() {
	picom_cfg="$PATH_I3WM/picom.conf"

	# modify picom config
	sed -i "$picom_cfg" \
		-e "s/backend = .*/backend = \"$picom_backend\";/g" \
		-e "s/corner-radius = .*/corner-radius = $picom_corner;/g" \
		-e "s/shadow-radius = .*/shadow-radius = $picom_shadow_r;/g" \
		-e "s/shadow-opacity = .*/shadow-opacity = $picom_shadow_o;/g" \
		-e "s/shadow-offset-x = .*/shadow-offset-x = $picom_shadow_x;/g" \
		-e "s/shadow-offset-y = .*/shadow-offset-y = $picom_shadow_y;/g" \
		-e "s/method = .*/method = \"$picom_blur_method\";/g" \
		-e "s/strength = .*/strength = $picom_blur_strength;/g"
}

# I3WM -------------------------------------
apply_i3wm() {
	# modify i3theme file
	sed -i ${PATH_I3WM}/config.d/01_theme.conf \
		-e "s/set \$i3_fonts.*/set \$i3_fonts $i3wm_fonts/g" \
		\
		-e "s/set \$i3_border_size.*/set \$i3_border_size $i3wm_border_size/g" \
		-e "s/set \$i3_border_style.*/set \$i3_border_style $i3wm_border_style/g" \
		\
		-e "s/set \$i3_gaps_inner.*/set \$i3_gaps_inner $i3wm_gaps_inner/g" \
		-e "s/set \$i3_gaps_outer.*/set \$i3_gaps_outer $i3wm_gaps_outer/g" \
		-e "s/set \$i3_gaps_smart.*/set \$i3_gaps_smart $i3wm_gaps_smart/g" \
		\
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
		-e "s/set \$i3_bar_fonts.*/set \$i3_bar_fonts $i3wm_fonts/g" \
		\
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

# Create Theme File -------------------------
create_file() {
	theme_file="$PATH_I3WM/themes/.current"
	if [[ ! -f "$theme_file" ]]; then
		touch ${theme_file}
	fi
	echo "$THEME" > ${theme_file}
}

# Notify User -------------------------------
notify_user() {
	dunstify -u normal -h string:x-dunst-stack-tag:applytheme -i /usr/share/archcraft/icons/dunst/themes.png "Applying Style : $THEME"
}

## Execute Script ---------------------------
notify_user
create_file
apply_wallpaper
apply_polybar
apply_rofi
apply_netmenu
apply_terminal
apply_geany
apply_appearance
apply_dunst
apply_compositor
apply_i3wm
