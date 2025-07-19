-- Simple Laravel Routes Browser
-- Inspired by git changes - clean, fast, effective

local M = {}

-- Find Laravel project root by looking for artisan file
local function find_laravel_root()
  local current_dir = vim.fn.expand('%:p:h')
  if current_dir == '' then
    current_dir = vim.fn.getcwd()
  end
  
  local function search_up(dir)
    local artisan_path = dir .. '/artisan'
    if vim.fn.filereadable(artisan_path) == 1 then
      return dir
    end
    
    local parent = vim.fn.fnamemodify(dir, ':h')
    if parent == dir then
      return nil
    end
    return search_up(parent)
  end
  
  return search_up(current_dir)
end

-- Get routes from artisan command
local function get_routes()
  local laravel_root = find_laravel_root()
  if not laravel_root then
    return nil, "Laravel project not found (no artisan file)"
  end
  
  local cmd = string.format('cd "%s" && php artisan route:list --compact 2>/dev/null', laravel_root)
  local handle = io.popen(cmd)
  if not handle then
    return nil, "Failed to execute artisan command"
  end
  
  local routes = {}
  local content = handle:read('*all')
  handle:close()
  
  if content == '' then
    return nil, "No output from artisan route:list"
  end
  
  -- Parse each line
  for line in content:gmatch('[^\r\n]+') do
    if line and line:match('%S') then
      -- Skip headers and separators
      if not line:match('^[+%-|%s]*$') and not line:match('^%s*Method%s') then
        -- Parse format: METHOD URI [NAME] ACTION
        local parts = {}
        for part in line:gmatch('%S+') do
          table.insert(parts, part)
        end
        
        if #parts >= 2 then
          local method = parts[1]
          local uri = parts[2]
          local action = parts[#parts] -- Last part is usually action
          local name = #parts > 3 and parts[3] or ''
          
          -- Clean up name if it looks like action
          if name and (name:match('Controller') or name:match('Closure') or name:match('@')) then
            name = ''
            action = parts[3] or action
          end
          
          table.insert(routes, {
            method = method,
            uri = uri,
            name = name,
            action = action,
            display = string.format('%s %s', method, uri),
            full_display = string.format('[%s] %s -> %s', method, uri, action)
          })
        end
      end
    end
  end
  
  return routes, nil
end

-- Parse controller and method from action
local function parse_controller_action(action)
  if not action or action:match('Closure') then
    return nil, nil
  end
  
  -- Handle App\Http\Controllers\UserController@index
  local controller, method = action:match('([^@]+)@([^@]+)')
  if controller and method then
    return controller, method
  end
  
  -- Handle App\Http\Controllers\UserController::class
  controller = action:match('([^:]+)::class')
  if controller then
    return controller, nil
  end
  
  return nil, nil
end

-- Find controller file
local function find_controller_file(controller_name, laravel_root)
  if not controller_name or not laravel_root then
    return nil
  end
  
  local file_path = controller_name:gsub('App\\Http\\Controllers\\', ''):gsub('\\', '/')
  local possible_files = {
    laravel_root .. '/app/Http/Controllers/' .. file_path .. '.php',
    laravel_root .. '/app/Controllers/' .. file_path .. '.php',
  }
  
  for _, file in ipairs(possible_files) do
    if vim.fn.filereadable(file) == 1 then
      return file
    end
  end
  
  return nil
end

-- Open controller method
local function open_controller_method(route)
  local laravel_root = find_laravel_root()
  if not laravel_root then
    print('Laravel project not found')
    return
  end
  
  local controller, method = parse_controller_action(route.action)
  if not controller then
    print('No controller found for route: ' .. route.uri)
    return
  end
  
  local file = find_controller_file(controller, laravel_root)
  if not file then
    print('Controller file not found: ' .. controller)
    return
  end
  
  vim.cmd('edit ' .. file)
  
  if method then
    vim.cmd('normal! gg')
    local search_pattern = 'function\\s\\+' .. method .. '\\s*('
    if vim.fn.search(search_pattern) > 0 then
      vim.cmd('normal! zz')
      print('Found method: ' .. method)
    else
      print('Method not found: ' .. method)
    end
  end
end

-- Main route picker function
function M.route_picker()
  local routes, error_msg = get_routes()
  if not routes then
    print('Error: ' .. (error_msg or 'Unknown error'))
    return
  end
  
  if #routes == 0 then
    print('No routes found')
    return
  end
  
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local previewers = require('telescope.previewers')
  
  pickers.new({}, {
    prompt_title = 'Laravel Routes (' .. #routes .. ' found)',
    layout_strategy = 'horizontal',
    layout_config = {
      horizontal = {
        prompt_position = 'top',
        preview_width = 0.7,
        results_width = 0.3,
      },
      width = 0.95,
      height = 0.85,
    },
    finder = finders.new_table({
      results = routes,
      entry_maker = function(route)
        -- Compact display for narrow left panel
        local method_short = route.method:sub(1, 4)
        local uri_display = route.uri
        if #uri_display > 25 then
          uri_display = uri_display:sub(1, 22) .. '...'
        end
        
        return {
          value = route,
          display = string.format('%s %s', method_short, uri_display),
          ordinal = route.method .. ' ' .. route.uri .. ' ' .. route.action,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = 'Route Details & Controller Preview',
      get_buffer_by_name = function(_, entry)
        return entry.value.uri
      end,
      define_preview = function(self, entry, status)
        local route = entry.value
        local lines = {
          '# Route Information',
          '',
          '**Method:**    ' .. route.method,
          '**URI:**       ' .. route.uri,
          '**Name:**      ' .. (route.name ~= '' and route.name or 'Not named'),
          '**Action:**    ' .. route.action,
          '',
        }
        
        local controller, method = parse_controller_action(route.action)
        if controller then
          table.insert(lines, '## Controller Information')
          table.insert(lines, '')
          table.insert(lines, '**Controller:** ' .. controller)
          if method then
            table.insert(lines, '**Method:**     ' .. method)
          end
          table.insert(lines, '')
          
          local laravel_root = find_laravel_root()
          local file = find_controller_file(controller, laravel_root)
          if file then
            table.insert(lines, '**File:** ' .. file:gsub(laravel_root .. '/', ''))
            table.insert(lines, '')
            
            if method then
              table.insert(lines, '## Method Source')
              table.insert(lines, '')
              table.insert(lines, '```php')
              
              local file_content = vim.fn.readfile(file)
              local in_method = false
              local brace_count = 0
              local method_lines = {}
              
              for i, line in ipairs(file_content) do
                if line:match('function%s+' .. method .. '%s*%(') then
                  in_method = true
                  table.insert(method_lines, string.format('%3d: %s', i, line))
                elseif in_method then
                  table.insert(method_lines, string.format('%3d: %s', i, line))
                  
                  local open_braces = select(2, line:gsub('{', ''))
                  local close_braces = select(2, line:gsub('}', ''))
                  brace_count = brace_count + open_braces - close_braces
                  
                  if brace_count < 0 or #method_lines > 30 then
                    break
                  end
                end
              end
              
              for _, method_line in ipairs(method_lines) do
                table.insert(lines, method_line)
              end
              table.insert(lines, '```')
            else
              table.insert(lines, '## Controller Preview')
              table.insert(lines, '')
              table.insert(lines, '```php')
              local file_content = vim.fn.readfile(file)
              for i = 1, math.min(15, #file_content) do
                table.insert(lines, string.format('%3d: %s', i, file_content[i]))
              end
              if #file_content > 15 then
                table.insert(lines, '... (showing first 15 lines)')
              end
              table.insert(lines, '```')
            end
          else
            table.insert(lines, '⚠️  Controller file not found')
          end
        else
          table.insert(lines, '## Action Type')
          table.insert(lines, '')
          if route.action:match('Closure') then
            table.insert(lines, '🔒 **Closure Route** - Defined inline')
          else
            table.insert(lines, '❓ **Unknown Action Format**')
          end
        end
        
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(self.state.bufnr, 'filetype', 'markdown')
      end,
    }),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          open_controller_method(selection.value)
        end
      end)
      
      -- Copy route URI
      map('i', '<C-u>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          vim.fn.setreg('+', selection.value.uri)
          print('Copied route URI: ' .. selection.value.uri)
        end
      end)
      
      -- Copy route name
      map('i', '<C-y>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          local name = selection.value.name ~= '' and selection.value.name or selection.value.uri
          vim.fn.setreg('+', name)
          print('Copied: ' .. name)
        end
      end)
      
      return true
    end,
  }):find()
end

-- Simple route list function
function M.route_list()
  local laravel_root = find_laravel_root()
  if not laravel_root then
    print('Laravel project not found')
    return
  end
  
  vim.cmd('!' .. string.format('cd "%s" && php artisan route:list', laravel_root))
end

-- Debug function
function M.debug()
  local laravel_root = find_laravel_root()
  print('=== Laravel Routes Debug ===')
  print('Laravel root: ' .. (laravel_root or 'NOT FOUND'))
  
  if laravel_root then
    print('Artisan file: ' .. laravel_root .. '/artisan')
    print('Working directory: ' .. vim.fn.getcwd())
    
    local routes, error_msg = get_routes()
    if routes then
      print('Routes found: ' .. #routes)
      if #routes > 0 then
        print('First few routes:')
        for i = 1, math.min(3, #routes) do
          print('  ' .. routes[i].full_display)
        end
      end
    else
      print('Error getting routes: ' .. (error_msg or 'Unknown'))
    end
  end
end

-- Setup function
function M.setup()
  -- Plugin is ready
end

return M