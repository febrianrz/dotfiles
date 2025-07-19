-- Laravel Livewire Tools
-- Livewire component creation, navigation, and utilities

local M = {}

-- Function to get Livewire component paths
local function get_livewire_paths()
  local root = vim.fn.getcwd()
  return {
    components = root .. '/app/Livewire',
    views = root .. '/resources/views/livewire',
    tests = root .. '/tests/Feature/Livewire',
  }
end

-- Function to convert component name to different formats
local function format_component_name(name)
  local formats = {}
  
  -- Class name (PascalCase)
  formats.class = name:gsub('(%l)(%w*)', function(first, rest)
    return first:upper() .. rest
  end):gsub('[%-_](%l)', function(char)
    return char:upper()
  end)
  
  -- View name (kebab-case)
  formats.view = name:lower():gsub('_', '-'):gsub('([a-z])([A-Z])', '%1-%2'):lower()
  
  -- File path (with directories)
  formats.path = name:gsub('%.', '/'):gsub('([A-Z])', function(char)
    return '-' .. char:lower()
  end):gsub('^%-', '')
  
  return formats
end

-- Function to create Livewire component
function M.create_livewire_component()
  local component_name = vim.fn.input('Livewire component name: ')
  if component_name == '' then
    return
  end
  
  -- Create component via artisan
  local cmd = 'php artisan make:livewire ' .. component_name
  local result = vim.fn.system(cmd)
  print(result)
  
  -- Open the created files
  vim.defer_fn(function()
    local paths = get_livewire_paths()
    local formats = format_component_name(component_name)
    
    -- Open PHP component
    local php_file = paths.components .. '/' .. component_name .. '.php'
    if vim.fn.filereadable(php_file) == 1 then
      vim.cmd('edit ' .. php_file)
    end
    
    -- Open Blade view in split
    local blade_file = paths.views .. '/' .. formats.view .. '.blade.php'
    if vim.fn.filereadable(blade_file) == 1 then
      vim.cmd('vsplit ' .. blade_file)
    end
  end, 1000)
end

-- Function to find Livewire component files
function M.find_livewire_components()
  local paths = get_livewire_paths()
  local components = {}
  
  -- Scan Livewire directory
  local handle = io.popen('find "' .. paths.components .. '" -name "*.php" 2>/dev/null')
  if handle then
    for line in handle:lines() do
      local rel_path = line:gsub(paths.components .. '/', ''):gsub('%.php$', '')
      table.insert(components, rel_path)
    end
    handle:close()
  end
  
  return components
end

-- Function to open Livewire component picker
function M.livewire_component_picker()
  local has_telescope, telescope = pcall(require, 'telescope')
  if not has_telescope then
    print("Telescope not found")
    return
  end
  
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local previewers = require('telescope.previewers')
  
  local components = M.find_livewire_components()
  
  if #components == 0 then
    print("No Livewire components found")
    return
  end
  
  pickers.new({}, {
    prompt_title = 'Livewire Components',
    layout_strategy = 'horizontal',
    layout_config = {
      horizontal = {
        prompt_position = 'top',
        preview_width = 0.6,
        results_width = 0.4,
      },
      width = 0.95,
      height = 0.85,
    },
    finder = finders.new_table({
      results = components,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry,
          ordinal = entry,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = 'Component Preview',
      get_buffer_by_name = function(_, entry)
        return entry.value
      end,
      define_preview = function(self, entry, status)
        local paths = get_livewire_paths()
        local component_file = paths.components .. '/' .. entry.value .. '.php'
        
        if vim.fn.filereadable(component_file) == 1 then
          local lines = vim.fn.readfile(component_file)
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
          vim.api.nvim_buf_set_option(self.state.bufnr, 'filetype', 'php')
        else
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {'Component file not found'})
        end
      end,
    }),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          local paths = get_livewire_paths()
          local component_file = paths.components .. '/' .. selection.value .. '.php'
          vim.cmd('edit ' .. component_file)
        end
      end)
      
      -- Open blade view
      map('i', '<C-v>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          actions.close(prompt_bufnr)
          local paths = get_livewire_paths()
          local formats = format_component_name(selection.value)
          local blade_file = paths.views .. '/' .. formats.view .. '.blade.php'
          
          if vim.fn.filereadable(blade_file) == 1 then
            vim.cmd('edit ' .. blade_file)
          else
            print('Blade view not found: ' .. blade_file)
          end
        end
      end)
      
      -- Open both component and view
      map('i', '<C-b>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          actions.close(prompt_bufnr)
          local paths = get_livewire_paths()
          local formats = format_component_name(selection.value)
          
          -- Open PHP component
          local component_file = paths.components .. '/' .. selection.value .. '.php'
          vim.cmd('edit ' .. component_file)
          
          -- Open Blade view in split
          local blade_file = paths.views .. '/' .. formats.view .. '.blade.php'
          if vim.fn.filereadable(blade_file) == 1 then
            vim.cmd('vsplit ' .. blade_file)
          end
        end
      end)
      
      return true
    end,
  }):find()
end

-- Function to toggle between Livewire component and view
function M.toggle_livewire_files()
  local current_file = vim.fn.expand('%:p')
  local paths = get_livewire_paths()
  
  if current_file:match('/app/Livewire/') then
    -- Currently in PHP component, switch to blade view
    local component_name = current_file:gsub(paths.components .. '/', ''):gsub('%.php$', '')
    local formats = format_component_name(component_name)
    local blade_file = paths.views .. '/' .. formats.view .. '.blade.php'
    
    if vim.fn.filereadable(blade_file) == 1 then
      vim.cmd('edit ' .. blade_file)
    else
      print('Blade view not found: ' .. blade_file)
    end
  elseif current_file:match('/resources/views/livewire/') then
    -- Currently in blade view, switch to PHP component
    local view_name = current_file:gsub(paths.views .. '/', ''):gsub('%.blade%.php$', '')
    local component_name = view_name:gsub('%-', '_'):gsub('/', '.')
    
    -- Try different component name formats
    local possible_files = {
      paths.components .. '/' .. component_name:gsub('%.', '/') .. '.php',
      paths.components .. '/' .. view_name:gsub('%-', ''):gsub('/', '') .. '.php',
    }
    
    for _, file in ipairs(possible_files) do
      if vim.fn.filereadable(file) == 1 then
        vim.cmd('edit ' .. file)
        return
      end
    end
    
    print('Livewire component not found for view: ' .. view_name)
  else
    print('Not in a Livewire file')
  end
end

-- Function to generate Livewire method skeleton
function M.insert_livewire_method()
  local method_name = vim.fn.input('Method name: ')
  if method_name == '' then
    return
  end
  
  local method_skeleton = {
    '',
    '    public function ' .. method_name .. '()',
    '    {',
    '        // Method implementation',
    '    }',
  }
  
  -- Insert at current cursor position
  local current_line = vim.fn.line('.')
  vim.fn.append(current_line, method_skeleton)
  
  -- Move cursor to method body
  vim.fn.cursor(current_line + 3, 8)
end

-- Function to generate Livewire property with validation
function M.insert_livewire_property()
  local property_name = vim.fn.input('Property name: ')
  if property_name == '' then
    return
  end
  
  local validation_rules = vim.fn.input('Validation rules (optional): ')
  
  local property_lines = {
    '',
    '    public $' .. property_name .. ';',
  }
  
  if validation_rules ~= '' then
    table.insert(property_lines, '')
    table.insert(property_lines, '    protected $rules = [')
    table.insert(property_lines, "        '" .. property_name .. "' => '" .. validation_rules .. "',")
    table.insert(property_lines, '    ];')
  end
  
  -- Insert at current cursor position
  local current_line = vim.fn.line('.')
  vim.fn.append(current_line, property_lines)
end

-- Function to run Livewire tests
function M.run_livewire_tests()
  local current_file = vim.fn.expand('%:t:r') -- Get filename without extension
  
  -- Run specific component test if available
  local test_command = 'php artisan test --filter=' .. current_file
  
  vim.cmd('!' .. test_command)
end

-- Setup function
function M.setup()
  -- Create Livewire component
  vim.keymap.set('n', '<leader>wc', M.create_livewire_component, {
    desc = '[W]ire [C]omponent - Create new Livewire component'
  })
  
  -- Livewire component picker
  vim.keymap.set('n', '<leader>wl', M.livewire_component_picker, {
    desc = '[W]ire [L]ist - Browse Livewire components'
  })
  
  -- Toggle between component and view
  vim.keymap.set('n', '<leader>wt', M.toggle_livewire_files, {
    desc = '[W]ire [T]oggle - Toggle between component and view'
  })
  
  -- Insert Livewire method
  vim.keymap.set('n', '<leader>wm', M.insert_livewire_method, {
    desc = '[W]ire [M]ethod - Insert method skeleton'
  })
  
  -- Insert Livewire property
  vim.keymap.set('n', '<leader>wp', M.insert_livewire_property, {
    desc = '[W]ire [P]roperty - Insert property with validation'
  })
  
  -- Run Livewire tests
  vim.keymap.set('n', '<leader>wT', M.run_livewire_tests, {
    desc = '[W]ire [T]est - Run component tests'
  })
  
  -- Livewire specific autocmds
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'php',
    callback = function()
      local current_file = vim.fn.expand('%:p')
      if current_file:match('/app/Livewire/') then
        -- Set up Livewire-specific keymaps in component files
        vim.keymap.set('n', 'gv', M.toggle_livewire_files, { 
          buffer = true, 
          desc = 'Go to Livewire view' 
        })
      end
    end,
  })
  
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'blade',
    callback = function()
      local current_file = vim.fn.expand('%:p')
      if current_file:match('/resources/views/livewire/') then
        -- Set up Livewire-specific keymaps in view files
        vim.keymap.set('n', 'gc', M.toggle_livewire_files, { 
          buffer = true, 
          desc = 'Go to Livewire component' 
        })
      end
    end,
  })
end

return M