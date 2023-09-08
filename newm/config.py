## Copyright (C) 2020-2023 Aditya Shakya <adi1090x@gmail.com>
##
## NEWM Config for Archcraft

## Import Modules ──────────────────────────────────────────────────────────
from __future__ import annotations
from typing import Callable, Any

import os
import pwd
import time
import logging
import random

from newm.layout import Layout

from pywm import (
    PYWM_MOD_LOGO,
    PYWM_MOD_ALT,

    PYWM_TRANSFORM_90,
    PYWM_TRANSFORM_180,
    PYWM_TRANSFORM_270,
    PYWM_TRANSFORM_FLIPPED,
    PYWM_TRANSFORM_FLIPPED_90,
    PYWM_TRANSFORM_FLIPPED_180,
    PYWM_TRANSFORM_FLIPPED_270,
)

logger = logging.getLogger(__name__)

## Startup ─────────────────────────────────────────────────────────────────
def on_startup():
    init_service = (
        "systemctl --user import-environment \
        DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
        "hash dbus-update-activation-environment 2>/dev/null && \
        dbus-update-activation-environment --systemd \
        DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
        "thunar --daemon",
        "nm-applet --indicator",
        "/usr/lib/xfce-polkit/xfce-polkit",
        "~/.config/newm/scripts/notifications",
        "~/.config/newm/scripts/gtkthemes",
        "mpd",
    )

    for service in init_service:
        service = f"{service} &"
        os.system(service)

## Reconfigure ─────────────────────────────────────────────────────────────
def on_reconfigure():
    os.system("notify-send -h string:x-canonical-private-synchronous:sys-notify -u low -i ~/.config/newm/mako/icons/desktop.png NEWM \"Configuration Reloaded\" &")
    gnome_schema = 'org.gnome.desktop.interface'
    gnome_peripheral = 'org.gnome.desktop.peripherals'
    wm_service_extra_config = (
        f"gsettings set {gnome_schema} gtk-theme 'Nordic'",
        f"gsettings set {gnome_schema} icon-theme 'Qogir-Dark'",
        f"gsettings set {gnome_schema} cursor-theme 'Qogirr-Dark'",
        f"gsettings set {gnome_schema} font-name 'Noto Sans 9'",
        f"gsettings set {gnome_peripheral}.keyboard repeat-interval 30",
        f"gsettings set {gnome_peripheral}.keyboard delay 500",
        f"gsettings set {gnome_peripheral}.mouse natural-scroll false",
        f"gsettings set {gnome_peripheral}.mouse speed 0.0",
        f"gsettings set {gnome_peripheral}.mouse accel-profile 'default'",
        f"gsettings set {gnome_peripheral}.touchpad natural-scroll false",
        f"gsettings set {gnome_peripheral}.touchpad speed 0.0",
        "gsettings set org.gnome.desktop.wm.preferences button-layout :",
    )

    for config in wm_service_extra_config:
        config = f"{config} &"
        os.system(config)

## Wallpaper ───────────────────────────────────────────────────────────────
background = {
    ##-- Apply selected wallpaper on each startup and config reload
    #'path': os.environ['HOME'] + '/.config/newm/wallpapers/wallpaper-1.jpg',

    ##-- Apply random wallpaper on each startup and config reload
    'path': os.environ["HOME"] + f"/.config/newm/wallpapers/wallpaper-{random.randrange(1, 6)}.jpg",

    'time_scale': 0.125,
    'anim': True,
}

## Output / Monitors ───────────────────────────────────────────────────────
outputs = [
	##-- Laptop Display
    { 'name': 'eDP-1', 'scale': 1.0, 'width': 1920, 'height': 1080,
      'mHz': 60, 'pos_x': 0, 'pos_y': 0 , 'anim': True },

	##-- External Monitor
    #{ 'name': 'HDMI-1', 'scale': 1.0, 'width': 1366, 'height': 768,
    #  'mHz': 60, 'pos_x': 0, 'pos_y': 0 , 'anim': True },
]

## General Settings ────────────────────────────────────────────────────────
corner_radius = 0		# Corner radius of workspace/desktop
anim_time = 0.30		# Overall animation time/duration
blend_time = 1.0		# Startup and Exit animation time
pywm = {
    'xkb_model': "",
    'xkb_layout': "",
    'xkb_variant': "",
    'xkb_options': "",
    'enable_xwayland': True,
    'xcursor_theme': 'Qogirr-Dark',
    'xcursor_size': 16,
    'tap_to_click': True,
    'natural_scroll': False,
    'focus_follows_mouse': True,
    'contstrain_popups_to_toplevel': True,
    'encourage_csd': False,
    'texture_shaders': 'basic',
    'renderer_mode': 'pywm',
}

## App Rules ───────────────────────────────────────────────────────────────
def app_rules(view):
    common_float = {"float": True}
    common_blur = {"blur": {"radius": 6, "passes": 4}}
    float_apps = ("io.calamares.calamares", "Yad", "yad", "nm-connection-editor", "pavucontrol", 
				  "xfce-polkit", "kvantummanager", "qt5ct", 
				  "feh", "Viewnior", "Gpicview", "Gimp", "MPlayer", 
				  "VirtualBox Manager", "qemu", "Qemu-system-x86_64" )  # applications that should open as floating
    #blur_apps = ("Alacritty", "kitty", "foot", "rofi", "waybar")  # applications that should have the blur effect
    blur_apps = ("Alacritty", "kitty")  # applications that should have the blur effect
    if view.app_id in float_apps:
        return common_float
    if view.app_id in blur_apps:
        return common_blur

    ##-- Open wlogout in fullscreen, with blur effect.
    if view.app_id == "wlogout":
        #return { "float": True, "float_size": (1920, 1080), "blur": {"radius": 6, "passes": 4} }
        return { "float": True, "float_size": (1920, 1080) }
    
    ##-- Open wofi in floating, with blur effect.
    if view.app_id == "wofi":
        #return { "float": True, "blur": {"radius": 6, "passes": 4} }
        return { "float": True }
    
    ##-- Open foot in floating, with blur effect.
    if view.app_id == "foot-float":
        #return { "float": True, "blur": {"radius": 6, "passes": 4} }
        return { "float": True }

    return None

## View ────────────────────────────────────────────────────────────────────
view = {
    'corner_radius': -5,			# Corner radius of View/Window/Container
    'padding': 8,					# Space arround View
    'fullscreen_padding': 0,
    'send_fullscreen': True,
    'accept_fullscreen': True,
    'floating_min_size': False,
    'debug_scaling': True,
    'border_ws_switch': 100,
    'rules': app_rules,
    'ssd': {						# Server side decorations
		'enabled': False,
		'color': '#FAE3B0FF',
		'width': 2,
    },
}

interpolation = {
    'size_adjustment': 0.5
}

## Focus ───────────────────────────────────────────────────────────────────
focus = {
    'enabled': True,
    'color': '#96CDFBFF',
    'distance': 4,
    'width': 2,
    'animate_on_change': False,
    'anim_time': 0.25,
}

## Panels ──────────────────────────────────────────────────────────────────
panels = {
    'bar': {
		'cmd': os.environ["HOME"] + "/.config/newm/scripts/statusbar",
		'visible_fullscreen': False,
		'visible_normal': True,
    },
    'lock': {
        'cmd': 'alacritty -e newm-panel-basic lock',
        'w': 0.5,
        'h': 0.5,
        'corner_radius': 60,
    },
    'launcher': {
        'cmd': 'alacritty -e newm-panel-basic launcher',
        'w': 0.4,
        'h': 0.4,
        'corner_radius': 20,
    },
}

## Power Saving ────────────────────────────────────────────────────────────
energy = {
    'idle_callback': lambda event: "idle",
    'idle_times': [120, 300, 600],
    'suspend_command': "systemctl suspend",
}

## Key Bindings ────────────────────────────────────────────────────────────
terminal = '~/.config/newm/scripts/terminal'
colorpicker = '~/.config/newm/scripts/colorpicker'
wlogout = '~/.config/newm/scripts/wlogout'
screenshot = '~/.config/newm/scripts/screenshot'
brightness = '~/.config/newm/scripts/brightness'
volume = '~/.config/newm/scripts/volume'
rofi_launcher = '~/.config/newm/scripts/rofi_launcher'
rofi_music = '~/.config/newm/scripts/rofi_music'
rofi_bluetooth = '~/.config/newm/scripts/rofi_bluetooth'
rofi_network = '~/.config/newm/scripts/rofi_network'
rofi_powermenu = '~/.config/newm/scripts/rofi_powermenu'
rofi_runner = '~/.config/newm/scripts/rofi_runner'
rofi_screenshot = '~/.config/newm/scripts/rofi_screenshot'
wofi_menu = '~/.config/newm/scripts/wofi_menu'
wofi_powermenu = '~/.config/newm/scripts/wofi_powermenu'

def key_bindings(layout: Layout) -> list[tuple[str, Callable[[], Any]]]:
    return [
		# -- Terminals
        ("L-Return", lambda: os.system(f"{terminal} &")),
        ("L-S-Return", lambda: os.system(f"{terminal} -f &")),
        ("L-A-Return", lambda: os.system(f"{terminal} -s &")),

		# -- Applications
        ("L-f", lambda: os.system("thunar &")),
        ("L-e", lambda: os.system("geany &")),
        ("L-w", lambda: os.system("firefox &")),

		# -- Rofi
        ("A-F1", lambda: os.system(f"{rofi_launcher} &")),
        ("L-d", lambda: os.system(f"{rofi_launcher} &")),
        ("L-m", lambda: os.system(f"{rofi_music} &")),
        ("L-b", lambda: os.system(f"{rofi_bluetooth} &")),
        ("L-n", lambda: os.system(f"{rofi_network} &")),
        ("L-x", lambda: os.system(f"{rofi_powermenu} &")),
        ("L-r", lambda: os.system(f"{rofi_runner} &")),
        ("L-s", lambda: os.system(f"{rofi_screenshot} &")),

		# -- Wofi
        #("L-d", lambda: os.system(f"{wofi_menu} &")),
        #("A-F1", lambda: os.system(f"{wofi_menu} &")),
        #("L-x", lambda: os.system(f"{wofi_powermenu} &")),

		# -- Misc
        #("L-n", lambda: os.system("nm-connection-editor &")),
        ("L-p", lambda: os.system(f"{colorpicker} &")),
        #("L-x", lambda: os.system(f"{wlogout} &")),

		# -- Focus
        ("L-Left", lambda: layout.move(-1, 0)),
        ("L-Down", lambda: layout.move(0, 1)),
        ("L-Up", lambda: layout.move(0, -1)),
        ("L-Right", lambda: layout.move(1, 0)),

        ("L-a", lambda: layout.move_in_stack(1)),
        ("L-space", lambda: layout.toggle_fullscreen()),
        ("L-S-space", lambda: layout.toggle_focused_view_floating()),

		# -- Scale
        ("L-equal", lambda: layout.basic_scale(1)),
        ("L-minus", lambda: layout.basic_scale(-1)),

		# -- Move
        ("L-S-Left", lambda: layout.move_focused_view(-1, 0)),
        ("L-S-Down", lambda: layout.move_focused_view(0, 1)),
        ("L-S-Up", lambda: layout.move_focused_view(0, -1)),
        ("L-S-Right", lambda: layout.move_focused_view(1, 0)),

		# -- Resize
        ("L-C-Left", lambda: layout.resize_focused_view(-1, 0)),
        ("L-C-Down", lambda: layout.resize_focused_view(0, 1)),
        ("L-C-Up", lambda: layout.resize_focused_view(0, -1)),
        ("L-C-Right", lambda: layout.resize_focused_view(1, 0)),

		# -- Newm Misc
        ("L-", lambda: layout.toggle_overview(only_active_workspace=True)),
        ("L-q", lambda: layout.close_focused_view()),
        ("L-c", lambda: layout.close_focused_view()),
        ("L-C", lambda: layout.update_config()),
        ("L-Q", lambda: layout.terminate()),  # Do not delete this.
        ("C-A-Delete", lambda: layout.terminate()),
        ("C-A-l", lambda: layout.ensure_locked(dim=True)),

		# -- Function Keys
        ("XF86MonBrightnessUp", lambda: os.system(f"{brightness} --inc &")),
        ("XF86MonBrightnessDown", lambda: os.system(f"{brightness} --dec &")),
        ("XF86AudioRaiseVolume", lambda: os.system(f"{volume} --inc &")),
        ("XF86AudioLowerVolume", lambda: os.system(f"{volume} --dec &")),
        ("XF86AudioMute", lambda: os.system(f"{volume} --toggle &")),
        ("XF86AudioMicMute", lambda: os.system(f"{volume} --toggle-mic &")),

        ("Print", lambda: os.system(f"{screenshot} --now &")),
        ("A-Print", lambda: os.system(f"{screenshot} --in5 &")),
        ("S-Print", lambda: os.system(f"{screenshot} --in10 &")),
        ("L-Print", lambda: os.system(f"{screenshot} --area &")),
    ]

## Gestures ────────────────────────────────────────────────────────────────
gesture_bindings = {
    'launcher': (None, "swipe-5"),
    'move_resize': ("L", "move-1", "swipe-2"),
    'swipe': (None, "swipe-3"),
    'swipe_to_zoom': (None, "swipe-4"),
}

gestures = {
    'lp_freq': 60.,
    'lp_inertia': 0.8,
    'two_finger_min_dist': 0.1,
    'validate_threshold': 0.02,

    'c': {
		'enabled': True,
		'scale_px': 800,
    },

    'dbus': {
		'enabled': True,
    },

    'pyevdev': {
		'enabled': False,
		'two_finger_min_dist': 0.1,
		'validate_threshold': 0.02,
    },
}

swipe = {
    'gesture_factor': 3,
    'grid_m': 1,
    'grid_ovr': 0.2,
    'lock_dist': 0.01,
}

swipe_zoom = {
    'gesture_factor': 3,
    'grid_m': 1,
    'grid_ovr': 0.2,
    'hyst': 0.2,
}

grid = {
    'min_dist': .05,
    'throw_ps': [2, 10],
    'time_scale': 0.3,
}

resize = {
    'grid_m': 3,
    'grid_ovr': 0.1,
    'hyst': 0.2,
}

move = {
    'grid_m': 3,
    'grid_ovr': 0.1,
}

move_resize = {
    'gesture_factor': 2
}

## EOF ─────────────────────────────────────────────────────────────────────
