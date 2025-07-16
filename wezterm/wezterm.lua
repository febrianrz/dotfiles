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

-- Function to get appearance (dark/light)
local function get_appearance()
	if wezterm.gui then
		return wezterm.gui.get_appearance()
	end
	return "Dark"
end

local function scheme_for_appearance(appearance)
	if appearance:find("Dark") then
		return {
			foreground = "#ffffff",
			cursor_bg = "#ffffff",
			cursor_border = "#ffffff",
			cursor_fg = "#fff",
			selection_bg = "#444444",
			selection_fg = "#ffffff",
			split = "#666666",
		}
	else
		return {
			foreground = "#1a1a1a",
			background = "#f8f8f8",
			cursor_bg = "#1a1a1a",
			cursor_border = "#1a1a1a",
			cursor_fg = "#f8f8f8",
			selection_bg = "#d4d4d4",
			selection_fg = "#1a1a1a",
			split = "#666666",
		}
	end
end

local config = {
	audible_bell = "SystemBeep",
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
	colors = scheme_for_appearance(get_appearance()),
	window_padding = {
		left = 4,
		right = 4,
		top = 4,
		bottom = 1,
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
		{
			key = "L",
			mods = "CMD|SHIFT",
			action = wezterm.action.EmitEvent("toggle-colorscheme"),
		},
		{
			key = "p",
			mods = "CMD",
			action = wezterm.action.PaneSelect({
				mode = "SwapWithActive",
			}),
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
			opacity = 0.7,
		},
	},
	window_background_opacity = 0.2,
	macos_window_background_blur = 40,
	max_fps = 120,
	prefer_egl = true,
}

-- Event handler for toggling colorscheme
wezterm.on("toggle-colorscheme", function(window, pane)
	local overrides = window:get_config_overrides() or {}
	if not overrides.colors then
		-- Switch to light mode
		overrides.colors = scheme_for_appearance("Light")
		overrides.background = {}
		overrides.window_background_opacity = 1.0
		-- Set environment for light mode
		overrides.set_environment_variables = {
			TERM = "xterm-256color",
			COLORTERM = "truecolor",
			TERM_BACKGROUND = "light",
		}
	else
		local is_dark = overrides.colors.foreground == "#ffffff"
		if is_dark then
			-- Switch to light mode
			overrides.colors = scheme_for_appearance("Light")
			overrides.background = {}
			overrides.window_background_opacity = 1
			-- Set environment for light mode
			overrides.set_environment_variables = {
				TERM = "xterm-256color",
				COLORTERM = "truecolor",
				TERM_BACKGROUND = "light",
			}
		else
			-- Switch to dark mode
			overrides.colors = scheme_for_appearance("Dark")
			overrides.background = {
				{
					source = {
						File = "/Users/febrianreza/Pictures/pinguin.jpg",
					},
					hsb = {
						hue = 1.0,
						saturation = 1.0,
						brightness = 0.03,
					},
					opacity = 0.7,
				},
			}
			overrides.window_background_opacity = 0.2
			-- Set environment for dark mode
			overrides.set_environment_variables = {
				TERM = "xterm-256color",
				COLORTERM = "truecolor",
				TERM_BACKGROUND = "dark",
			}
		end
	end
	window:set_config_overrides(overrides)

	-- Send signal to shell to update colors and export variables
	local theme_mode = (overrides.set_environment_variables and overrides.set_environment_variables.TERM_BACKGROUND)
		or "dark"
	pane:send_text(
		"export TERM_BACKGROUND="
			.. theme_mode
			.. " && VERBOSE_THEME=1 ~/.config/toggle_theme.sh && switch_ls "
			.. theme_mode
			.. " && clear\n"
	)
end)

return config
