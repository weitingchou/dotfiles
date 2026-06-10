-- WezTerm configuration — shared across macOS and Ubuntu desktop.
-- Synced to $HOME by install_dotfiles.sh, alongside .vimrc / .tmux.conf.
-- Mirrors the iTerm2 "Solarized Dark Patched" look used on macOS. Harmless on
-- machines where WezTerm isn't installed (the file is simply never read).

local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Solarized Dark, to match the macOS iTerm2 profile.
config.color_scheme = "Solarized Dark (base16)"

-- Font: prefer the same Source Code Pro Nerd Font used on macOS, but fall back
-- to WezTerm's bundled JetBrains Mono (which already carries Nerd Font glyphs)
-- so this works on Ubuntu without installing the font separately.
config.font = wezterm.font_with_fallback({
  "SauceCodePro Nerd Font",
  "JetBrains Mono",
})
config.font_size = 13.0

-- Window
config.window_padding = { left = 6, right = 6, top = 6, bottom = 6 }
config.scrollback_lines = 10000
config.enable_scroll_bar = false

-- Tabs: keep native tabs, but hide the bar when only one tab is open. tmux
-- (prefix C-a) handles multiplexing inside SSH sessions; native tabs/panes are
-- for local use. WezTerm's default leader does not collide with tmux's C-a.
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true

-- Don't prompt when closing a window/tab.
config.window_close_confirmation = "NeverPrompt"

return config
