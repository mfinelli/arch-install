# -*- coding: utf-8 -*-

import re
from xkeysnail.transform import *

# define timeout for multipurpose_modmap
define_timeout(1)

# keybindings for firefox/chrome
define_keymap(re.compile("Firefox|Google-chrome", re.IGNORECASE), {
    K("Super-c"): K("C-c"),
    K("Super-v"): K("C-v"),
    K("Super-a"): K("C-a"),
    K("Super-f"): K("C-f"),
    K("Super-z"): K("C-z"),
    K("Super-t"): K("C-t"),
}, "Browsers")

# keybindings for terminals
define_keymap(re.compile("Alacritty|Xfce4-terminal", re.IGNORECASE), {
    K("Super-c"): K("Shift-C-c"),
    K("Super-v"): K("Shift-C-v"),
    K("Super-n"): K("Shift-C-n"),
}, "Terminals")

# keybindings for libreoffice
define_keymap(re.compile("libreoffice", re.IGNORECASE), {
    K("Super-c"): K("C-c"),
    K("Super-v"): K("C-v"),
    K("Super-f"): K("C-f"),
    K("Super-z"): K("C-z"),
    K("Super-f"): K("C-f"),
}, "Libre Office")
