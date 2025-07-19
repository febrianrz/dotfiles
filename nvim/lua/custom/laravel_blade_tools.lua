-- Enhanced Laravel Blade Tools
-- Component navigation, creation, and blade-specific utilities

local M = {}

-- Function to get Laravel project paths
local function get_laravel_paths()
  local root = vim.fn.getcwd()
  return {
    views = root .. '/resources/views',
    components = root .. '/resources/views/components',
    livewire = root .. '/app/Livewire',
    app_components = root .. '/app/View/Components',
  }
end

-- Function to extract component name from blade syntax
local function get_component_under_cursor()
  local line = vim.fn.getline('.')
  local col = vim.fn.col('.')
  
  -- Match <x-component-name> patterns
  local component = line:match('<x%-([%w%-%.]+)')
  if component then
    return component:gsub('%-', '_'):gsub('%.', '/')
  end
  
  -- Match @livewire('component-name') patterns
  local livewire = line:match("@livewire%('([%w%-%.]+)'%)")
  if livewire then
    return livewire:gsub('%-', '_'):gsub('%.', '/')
  end
  
  return nil
end

-- Function to find component file
local function find_component_file(component_name)
  local paths = get_laravel_paths()
  local possible_files = {
    -- Blade components
    paths.components .. '/' .. component_name .. '.blade.php',
    paths.views .. '/' .. component_name .. '.blade.php',
    
    -- PHP class components
    paths.app_components .. '/' .. component_name:gsub('_', '') .. '.php',
    
    -- Livewire components
    paths.livewire .. '/' .. component_name:gsub('_', '') .. '.php',
  }
  
  for _, file in ipairs(possible_files) do
    if vim.fn.filereadable(file) == 1 then
      return file
    end
  end
  
  return nil
end

-- Function to jump to component definition
function M.goto_component()
  local component = get_component_under_cursor()
  if not component then
    print("No component found under cursor")
    return
  end
  
  local file = find_component_file(component)
  if file then
    vim.cmd('edit ' .. file)
    print('Opened: ' .. file)
  else
    print('Component file not found: ' .. component)
    -- Offer to create the component
    local create = vim.fn.input('Create component? (y/N): ')
    if create:lower() == 'y' then
      M.create_component(component)
    end
  end
end

-- Function to create new blade component
function M.create_component(name)
  if not name then
    name = vim.fn.input('Component name: ')
  end
  
  if name == '' then
    return
  end
  
  local paths = get_laravel_paths()
  local component_file = paths.components .. '/' .. name .. '.blade.php'
  
  -- Create directory if it doesn't exist
  local dir = vim.fn.fnamemodify(component_file, ':h')
  vim.fn.mkdir(dir, 'p')
  
  -- Create component template
  local template = {
    '<div>',
    '    {{-- ' .. name .. ' component --}}',
    '    <p>Hello from ' .. name .. ' component!</p>',
    '</div>',
  }
  
  vim.fn.writefile(template, component_file)
  vim.cmd('edit ' .. component_file)
  print('Created component: ' .. component_file)
end

-- Function to find all blade components
function M.list_components()
  local paths = get_laravel_paths()
  local components = {}
  
  -- Scan components directory
  local handle = io.popen('find "' .. paths.components .. '" -name "*.blade.php" 2>/dev/null')
  if handle then
    for line in handle:lines() do
      local rel_path = line:gsub(paths.components .. '/', ''):gsub('%.blade%.php$', '')
      table.insert(components, rel_path)
    end
    handle:close()
  end
  
  return components
end

-- Function to open component picker with Telescope
function M.component_picker()
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
  
  local components = M.list_components()
  
  if #components == 0 then
    print("No blade components found")
    return
  end
  
  pickers.new({}, {
    prompt_title = 'Laravel Blade Components',
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
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          local paths = get_laravel_paths()
          local file = paths.components .. '/' .. selection.value .. '.blade.php'
          vim.cmd('edit ' .. file)
        end
      end)
      return true
    end,
  }):find()
end

-- Function to generate component usage snippet
function M.insert_component_tag()
  local components = M.list_components()
  
  if #components == 0 then
    print("No components found")
    return
  end
  
  -- Simple input for now, could be enhanced with completion
  local component = vim.fn.input('Component name: ')
  if component == '' then
    return
  end
  
  local tag = '<x-' .. component:gsub('/', '.'):gsub('_', '-') .. ' />'
  
  -- Insert at cursor
  local line = vim.fn.getline('.')
  local col = vim.fn.col('.') - 1
  local new_line = string.sub(line, 1, col) .. tag .. string.sub(line, col + 1)
  vim.fn.setline('.', new_line)
  
  -- Move cursor after the tag
  vim.fn.cursor(vim.fn.line('.'), col + string.len(tag) + 1)
end

-- Function to convert blade to livewire component
function M.blade_to_livewire()
  local current_file = vim.fn.expand('%:p')
  if not current_file:match('%.blade%.php$') then
    print("Not a blade file")
    return
  end
  
  local component_name = vim.fn.input('Livewire component name: ')
  if component_name == '' then
    return
  end
  
  -- Create livewire component via artisan
  local cmd = 'php artisan make:livewire ' .. component_name
  local result = vim.fn.system(cmd)
  print(result)
  
  -- Open the created component
  local paths = get_laravel_paths()
  local livewire_file = paths.livewire .. '/' .. component_name .. '.php'
  if vim.fn.filereadable(livewire_file) == 1 then
    vim.cmd('vsplit ' .. livewire_file)
  end
end

-- Function to show blade directives completion
function M.show_blade_directives()
  local directives = {
    '@if', '@endif', '@else', '@elseif',
    '@foreach', '@endforeach', '@for', '@endfor',
    '@while', '@endwhile', '@switch', '@endswitch',
    '@case', '@break', '@default',
    '@include', '@extends', '@section', '@endsection',
    '@yield', '@parent', '@show', '@stop',
    '@csrf', '@method', '@error', '@enderror',
    '@auth', '@endauth', '@guest', '@endguest',
    '@can', '@endcan', '@cannot', '@endcannot',
    '@livewire', '@livewireStyles', '@livewireScripts',
    '@vite', '@asset', '@route', '@url',
  }
  
  -- Show in a floating window
  local buf = vim.api.nvim_create_buf(false, true)
  local content = {'Blade Directives:', ''}
  for _, directive in ipairs(directives) do
    table.insert(content, '  ' .. directive)
  end
  
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = 30,
    height = math.min(#content + 2, 25),
    col = (vim.o.columns - 30) / 2,
    row = (vim.o.lines - 25) / 2,
    style = 'minimal',
    border = 'rounded',
    title = ' Blade Directives ',
    title_pos = 'center',
  })
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  
  -- Close with q or Escape
  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, silent = true })
  vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf, silent = true })
end

-- Setup function
function M.setup()
  -- Component navigation
  vim.keymap.set('n', '<leader>bc', M.goto_component, {
    desc = '[B]lade [C]omponent - Go to component under cursor'
  })
  
  -- Component picker
  vim.keymap.set('n', '<leader>bC', M.component_picker, {
    desc = '[B]lade [C]omponents - Browse all components'
  })
  
  -- Create new component
  vim.keymap.set('n', '<leader>bn', M.create_component, {
    desc = '[B]lade [N]ew - Create new component'
  })
  
  -- Insert component tag
  vim.keymap.set('n', '<leader>bi', M.insert_component_tag, {
    desc = '[B]lade [I]nsert - Insert component tag'
  })
  
  -- Convert blade to livewire
  vim.keymap.set('n', '<leader>bl', M.blade_to_livewire, {
    desc = '[B]lade [L]ivewire - Convert to livewire component'
  })
  
  -- Show blade directives
  vim.keymap.set('n', '<leader>bd', M.show_blade_directives, {
    desc = '[B]lade [D]irectives - Show blade directives'
  })
  
  -- Auto-detect blade files and set up specific keymaps
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'blade',
    callback = function()
      vim.keymap.set('n', 'gf', M.goto_component, { 
        buffer = true, 
        desc = 'Go to component under cursor' 
      })
    end,
  })
end

return M