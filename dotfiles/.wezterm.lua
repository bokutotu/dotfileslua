local wezterm = require 'wezterm'
local mux = wezterm.mux
local config = wezterm.config_builder()

wezterm.on('gui-startup', function(cmd)
  local _, _, window = mux.spawn_window(cmd or {})
  window:gui_window():toggle_fullscreen()
end)

config.color_scheme = 'Builtin Light'
config.enable_tab_bar = false
config.window_decorations = 'RESIZE'
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
config.font_size = 14.0

return config
