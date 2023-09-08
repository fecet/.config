# ------------------------------------------------------------------------------
# Copyright (C) 2020-2023 Aditya Shakya <adi1090x@gmail.com>
#
# Bouquet Theme
# ------------------------------------------------------------------------------

# Colors
background='#191D27'
foreground='#767D8A'
color0='#27292D'
color1='#ec7875'
color2='#61c766'
color3='#fdd835'
color4='#42a5f5'
color5='#ba68c8'
color6='#4dd0e1'
color7='#d8d8d8'
color8='#3B3D41'
color9='#fb8784'
color10='#70d675'
color11='#ffe744'
color12='#51b4ff'
color13='#c979d7'
color14='#5cdff0'
color15='#fdf6e3'

accent='#FFCC66'
light_value='0.05'
dark_value='0.20'

# Wallpaper
wdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
wallpaper="$wdir/wallpaper"

# Polybar
polybar_font='Iosevka Nerd Font:size=10;3'

# Rofi
rofi_font='Iosevka 10'
rofi_icon='Luna'

# Terminal
terminal_font_name='JetBrainsMono Nerd Font'
terminal_font_size='10'

# Geany
geany_colors='bouquet.conf'
geany_font='JetBrains Mono 10'

# Appearance
gtk_font='Noto Sans 9'
gtk_theme='Juno-mirage'
icon_theme='Luna-Dark'
cursor_theme='Future-Dark'

# Dunst
dunst_width='300'
dunst_height='80'
dunst_offset='20x56'
dunst_origin='bottom-right'
dunst_font='JetBrains Mono 10'
dunst_border='2'
dunst_separator='2'

# Picom
picom_backend='glx'
picom_corner='0'
picom_shadow_r='14'
picom_shadow_o='0.30'
picom_shadow_x='-12'
picom_shadow_y='-12'
picom_blur_method='none'
picom_blur_strength='0'

# Bspwm
bspwm_fbc="$accent"
bspwm_nbc="$background"
bspwm_abc="$color5"
bspwm_pfc="$color2"
bspwm_border='2'
bspwm_gap='10'
bspwm_sratio='0.50'
