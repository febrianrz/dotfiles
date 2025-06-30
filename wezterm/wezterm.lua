local wezterm = require("wezterm")

local function file_exists(path)
	local f = io.open(path, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

local config = {
	audible_bell = "Disabled",
	check_for_updates = false,
	-- window_decorations = "RESIZE",
	hide_tab_bar_if_only_one_tab = true,
	line_height = 1.2,
	inactive_pane_hsb = {
		hue = 1.0,
		saturation = 1.0,
		brightness = 1.0,
	},
	pane_select_bg_color = "#444444",
	pane_select_fg_color = "#ffffff",
	pane_focus_follows_mouse = false,
	font_size = 16.0,
	launch_menu = {},
	colors = {
		cursor_bg = "#ffffff",
		cursor_border = "#ffffff",
		foreground = "#ffffff",
		split = "#666666",
	},
	window_padding = {
		left = 4,
		right = 4,
		top = 4,
		bottom = 4,
	},
	keys = {
		{
			key = "d",
			mods = "CMD",
			action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "d",
			mods = "CMD|SHIFT",
			action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
		},
		{
			key = "]",
			mods = "CMD",
			action = wezterm.action.ActivatePaneDirection("Next"),
		},
		{
			key = "[",
			mods = "CMD",
			action = wezterm.action.ActivatePaneDirection("Prev"),
		},
		{
			key = "h",
			mods = "CMD",
			action = wezterm.action.ActivatePaneDirection("Left"),
		},
		{
			key = "j",
			mods = "CMD",
			action = wezterm.action.ActivatePaneDirection("Down"),
		},
		{
			key = "k",
			mods = "CMD",
			action = wezterm.action.ActivatePaneDirection("Up"),
		},
		{
			key = "l",
			mods = "CMD",
			action = wezterm.action.ActivatePaneDirection("Right"),
		},
		{
			key = "=",
			mods = "CMD",
			action = wezterm.action.AdjustPaneSize({ "Right", 5 }),
		},
		{
			key = "-",
			mods = "CMD",
			action = wezterm.action.AdjustPaneSize({ "Left", 5 }),
		},
		{
			key = "=",
			mods = "CMD|SHIFT",
			action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
		},
		{
			key = "-",
			mods = "CMD|SHIFT",
			action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
		},
	},
	background = {
		{
			source = {
				File = "/Users/febrianreza/Pictures/pinguin.jpg",
			},
			hsb = {
				hue = 1.0,
				saturation = 1.0,
				brightness = 0.03,
			},
			opacity = 0.99,
		},
	},
	window_background_opacity = 0.3,
	max_fps = 120,
	prefer_egl = true,
}

return config
