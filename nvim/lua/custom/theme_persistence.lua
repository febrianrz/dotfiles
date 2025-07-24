-- Theme Persistence System
-- Saves and loads user's theme preferences

local M = {}

-- File path to store theme preferences
local theme_file = vim.fn.stdpath('data') .. '/theme_preference.json'

-- Default theme mappings for light/dark modes
local default_themes = {
  light = 'tokyonight-day',
  dark = 'tokyonight-night'
}

-- Get current background mode (light/dark)
local function get_background_mode()
  local term_bg = os.getenv('TERM_BACKGROUND')
  if term_bg == 'light' then
    return 'light'
  else
    return 'dark'
  end
end

-- Save theme preference to file
function M.save_theme(colorscheme)
  local mode = get_background_mode()
  
  -- Try to read existing preferences
  local preferences = {}
  local file = io.open(theme_file, 'r')
  if file then
    local content = file:read('*all')
    file:close()
    
    -- Parse JSON safely
    local ok, decoded = pcall(vim.fn.json_decode, content)
    if ok and type(decoded) == 'table' then
      preferences = decoded
    end
  end
  
  -- Update preference for current mode
  preferences[mode] = colorscheme
  
  -- Save to file
  local file_write = io.open(theme_file, 'w')
  if file_write then
    file_write:write(vim.fn.json_encode(preferences))
    file_write:close()
    print('Theme preference saved: ' .. colorscheme .. ' (' .. mode .. ' mode)')
  else
    print('Failed to save theme preference')
  end
end

-- Load theme preference from file
function M.load_theme()
  local mode = get_background_mode()
  
  -- Try to read preferences file
  local file = io.open(theme_file, 'r')
  if not file then
    -- File doesn't exist, return default theme
    return default_themes[mode]
  end
  
  local content = file:read('*all')
  file:close()
  
  -- Parse JSON safely
  local ok, preferences = pcall(vim.fn.json_decode, content)
  if not ok or type(preferences) ~= 'table' then
    -- Invalid file, return default
    return default_themes[mode]
  end
  
  -- Return saved preference or default
  return preferences[mode] or default_themes[mode]
end

-- Get all available colorschemes
function M.get_available_colorschemes()
  local colorschemes = {}
  
  -- Get built-in colorschemes
  local builtin = vim.fn.getcompletion('', 'color')
  for _, scheme in ipairs(builtin) do
    table.insert(colorschemes, scheme)
  end
  
  return colorschemes
end

-- Apply colorscheme and save preference
function M.set_colorscheme(colorscheme)
  local mode = get_background_mode()
  
  -- Set background mode
  vim.opt.background = mode
  
  -- Apply colorscheme
  local ok, err = pcall(vim.cmd.colorscheme, colorscheme)
  if ok then
    -- Save preference if successful
    M.save_theme(colorscheme)
    return true
  else
    print('Failed to set colorscheme: ' .. colorscheme .. ' - ' .. tostring(err))
    return false
  end
end

-- Enhanced switch theme function that respects user preferences
function M.switch_theme_enhanced()
  local preferred_theme = M.load_theme()
  local mode = get_background_mode()
  
  -- Set background mode
  vim.opt.background = mode
  
  -- Apply preferred theme
  pcall(vim.cmd.colorscheme, preferred_theme)
end

-- Override telescope colorscheme picker to save preferences
function M.setup_telescope_override()
  local telescope_builtin = require('telescope.builtin')
  local original_colorscheme = telescope_builtin.colorscheme
  
  -- Override the colorscheme picker
  telescope_builtin.colorscheme = function(opts)
    opts = opts or {}
    
    -- Add custom action to save theme when selected
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    
    opts.attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        if selection then
          -- Close telescope
          actions.close(prompt_bufnr)
          -- Set colorscheme and save preference
          M.set_colorscheme(selection.value)
        end
      end)
      return true
    end
    
    -- Call original colorscheme picker
    original_colorscheme(opts)
  end
end

return M