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

-- Function to format workspace names in tab titles
local function format_tab_title(tab, tabs, panes, config, hover, max_width)
	local title = tab.tab_title
	if title and #title > 0 then
		return title
	end
	
	local pane = tab.active_pane
	local workspace = pane.domain_name == "local" and "" or pane.domain_name .. ":"
	
	return workspace .. (pane.title or "Shell")
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
	hide_tab_bar_if_only_one_tab = false,
	show_tab_index_in_tab_bar = true,
	tab_bar_at_bottom = false,
	use_fancy_tab_bar = true,
	tab_max_width = 32,
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
		-- Session Management
		{
			key = "s",
			mods = "CMD|SHIFT",
			action = wezterm.action.ShowLauncherArgs({ flags = "WORKSPACES" }),
		},
		{
			key = "c",
			mods = "CMD|SHIFT",
			action = wezterm.action.PromptInputLine({
				description = "Enter workspace name:",
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:perform_action(
							wezterm.action.SwitchToWorkspace({
								name = line,
							}),
							pane
						)
					end
				end),
			}),
		},
		{
			key = "n",
			mods = "CMD|SHIFT",
			action = wezterm.action.SwitchWorkspaceRelative(1),
		},
		{
			key = "p",
			mods = "CMD|SHIFT",
			action = wezterm.action.SwitchWorkspaceRelative(-1),
		},
		{
			key = "x",
			mods = "CMD|SHIFT",
			action = wezterm.action_callback(function(window, pane)
				local workspace = window:active_workspace()
				if workspace == "main" then
					window:toast_notification("WezTerm", "Cannot close 'main' workspace", nil, 2000)
				else
					window:perform_action(wezterm.action.SwitchToWorkspace({ name = "main" }), pane)
					wezterm.mux.get_workspace(workspace):spawn_tab({})
					-- Close the workspace by removing all its tabs
					local tabs = wezterm.mux.get_workspace(workspace):tabs()
					for _, tab in ipairs(tabs) do
						tab:close()
					end
				end
			end),
		},
		{
			key = "x",
			mods = "CMD|ALT|SHIFT",
			action = wezterm.action_callback(function(window, pane)
				local workspaces = wezterm.mux.get_workspace_names()
				local closed_count = 0
				
				for _, workspace_name in ipairs(workspaces) do
					if workspace_name ~= "main" then
						local workspace = wezterm.mux.get_workspace(workspace_name)
						if workspace then
							local tabs = workspace:tabs()
							for _, tab in ipairs(tabs) do
								tab:close()
							end
							closed_count = closed_count + 1
						end
					end
				end
				
				window:perform_action(wezterm.action.SwitchToWorkspace({ name = "main" }), pane)
				window:toast_notification("WezTerm", "Closed " .. closed_count .. " workspaces", nil, 2000)
			end),
		},
		-- Tab management for sessions
		{
			key = "t",
			mods = "CMD",
			action = wezterm.action.SpawnTab("CurrentPaneDomain"),
		},
		{
			key = "w",
			mods = "CMD",
			action = wezterm.action.CloseCurrentTab({ confirm = true }),
		},
		-- Quick workspace switching (Cmd+Alt+1-4)
		{
			key = "1",
			mods = "CMD|ALT",
			action = wezterm.action.SwitchToWorkspace({ name = "main" }),
		},
		{
			key = "2",
			mods = "CMD|ALT",
			action = wezterm.action.SwitchToWorkspace({ name = "dev" }),
		},
		{
			key = "3",
			mods = "CMD|ALT",
			action = wezterm.action.SwitchToWorkspace({ name = "test" }),
		},
		{
			key = "4",
			mods = "CMD|ALT",
			action = wezterm.action.SwitchToWorkspace({ name = "config" }),
		},
		-- Alternative navigation to avoid conflicts with Neovim
		{
			key = "h",
			mods = "CMD|CTRL",
			action = wezterm.action.ActivatePaneDirection("Left"),
		},
		{
			key = "j",
			mods = "CMD|CTRL",
			action = wezterm.action.ActivatePaneDirection("Down"),
		},
		{
			key = "k",
			mods = "CMD|CTRL",
			action = wezterm.action.ActivatePaneDirection("Up"),
		},
		{
			key = "l",
			mods = "CMD|CTRL",
			action = wezterm.action.ActivatePaneDirection("Right"),
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
	status_update_interval = 1000,
	default_workspace = "main",
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

-- Format tab titles to show workspace info
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	return format_tab_title(tab, tabs, panes, config, hover, max_width)
end)

-- Update status line to show current workspace
wezterm.on("update-right-status", function(window, pane)
	local workspace = window:active_workspace()
	local time = wezterm.strftime("%H:%M")
	
	window:set_right_status(wezterm.format({
		{ Foreground = { Color = "#666666" } },
		{ Text = workspace .. " | " .. time },
	}))
end)

-- Auto-create workspaces on startup
wezterm.on("gui-startup", function(cmd)
	local _, _, window = wezterm.mux.spawn_window({
		workspace = "main",
	})
	
	-- Create additional default workspaces
	wezterm.mux.spawn_window({ workspace = "dev" })
	wezterm.mux.spawn_window({ workspace = "test" })
	wezterm.mux.spawn_window({ workspace = "config" })
	
	-- Focus the main workspace
	window:gui_window():perform_action(wezterm.action.SwitchToWorkspace({ name = "main" }), window:active_pane())
end)

return config
