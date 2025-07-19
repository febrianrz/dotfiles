-- Laravel Route Management Tools
-- Route listing, navigation, and route-related utilities

local M = {}

-- Function to find Laravel project root
local function find_laravel_root()
  -- Start from vim's working directory (where nvim was opened)
  local start_dir = vim.fn.getcwd()
  
  -- First check current directory directly
  if vim.fn.filereadable(start_dir .. '/artisan') == 1 then
    return start_dir
  end
  
  -- Search upwards for artisan file
  local function search_upwards(dir)
    local artisan_path = dir .. '/artisan'
    if vim.fn.filereadable(artisan_path) == 1 then
      return dir
    end
    
    local parent = vim.fn.fnamemodify(dir, ':h')
    if parent == dir then
      return nil -- reached root
    end
    return search_upwards(parent)
  end
  
  return search_upwards(start_dir)
end

-- Function to get route list from artisan
local function get_routes()
  -- Check if artisan exists in current working directory (same as aR command)
  if vim.fn.filereadable('./artisan') == 0 then
    print("Not in a Laravel project (no artisan file found)")
    return {}
  end
  
  -- Use same command as aR but capture output (no cd needed if working directory is correct)
  local cmd = 'php -d error_reporting=0 artisan route:list 2>/dev/null'
  local handle = io.popen(cmd)
  if not handle then
    print("Failed to execute artisan command")
    return {}
  end
  
  local routes = {}
  local line_count = 0
  local debug_lines = {}
  
  for line in handle:lines() do
    line_count = line_count + 1
    table.insert(debug_lines, line)
    
    -- Skip empty lines and separators
    if line and line:match('%S') and not line:match('^[+%-|%s]*$') then
      -- Parse compact format: METHOD URI NAME ACTION
      -- Example: GET|HEAD        / .......... 
      -- Example: POST            api/aanwijzing api.aanwijzing.store › Controller...
      
      -- Extract method (everything before first space sequence)
      local method_part, rest = line:match('^(%S+)%s+(.+)$')
      if method_part and rest then
        -- Extract URI (next non-space sequence)
        local uri, remaining = rest:match('^(%S+)%s*(.*)$')
        if uri and remaining then
          -- Find action part (after › or similar indicators)
          local action = remaining:match('›%s*(.+)$') or remaining:match('%.%.%.%s*(.+)$') or remaining
          local name = ''
          
          -- Try to extract route name if present (before › or action)
          local name_part = remaining:match('^([^›]+)%s*›') or remaining:match('^([^%.]+)%s*%.%.%.')
          if name_part then
            name = vim.trim(name_part)
            if name == '' or name:match('^%.+$') then
              name = ''
            end
          end
          
          -- Clean up action
          if action then
            action = vim.trim(action)
          else
            action = uri -- fallback
          end
          
          -- Skip obviously invalid lines (but be less restrictive for debugging)
          if uri ~= '' and method_part ~= '' then
            table.insert(routes, {
              method = method_part,
              uri = uri,
              name = name,
              action = action,
              display = string.format('[%s] %s -> %s', method_part, uri, action)
            })
          end
        end
      end
    end
  end
  
  handle:close()
  
  if #routes == 0 then
    print("No routes parsed from " .. line_count .. " lines. First few lines:")
    for i = 1, math.min(#debug_lines, 5) do
      print("  Line " .. i .. ": '" .. debug_lines[i] .. "'")
    end
    print("Debug with: <leader>rq")
  end
  
  return routes
end

-- Function to extract controller and method from action
local function parse_action(action)
  -- Handle different action formats
  if action:match('Closure') then
    return nil, nil
  end
  
  -- App\Http\Controllers\UserController@index
  local controller, method = action:match('([^@]+)@([^@]+)')
  if controller and method then
    return controller, method
  end
  
  -- App\Http\Controllers\UserController::class, 'index'
  controller = action:match('([^:]+)::class')
  if controller then
    return controller, nil
  end
  
  return nil, nil
end

-- Function to find controller file
local function find_controller_file(controller_name)
  if not controller_name then
    return nil
  end
  
  -- Use current working directory (same approach as aR command)
  local cwd = vim.fn.getcwd()
  
  -- Convert namespace to file path
  local file_path = controller_name:gsub('App\\Http\\Controllers\\', ''):gsub('\\', '/')
  local possible_files = {
    cwd .. '/app/Http/Controllers/' .. file_path .. '.php',
    cwd .. '/app/Controllers/' .. file_path .. '.php', -- Alternative structure
  }
  
  for _, file in ipairs(possible_files) do
    if vim.fn.filereadable(file) == 1 then
      return file
    end
  end
  
  return nil
end

-- Function to jump to controller method
local function goto_controller_method(controller, method)
  local file = find_controller_file(controller)
  if not file then
    print('Controller file not found: ' .. (controller or 'unknown'))
    return
  end
  
  vim.cmd('edit ' .. file)
  
  if method then
    -- Search for the method in the file
    vim.cmd('normal! gg')
    local search_pattern = 'function\\s\\+' .. method .. '\\s*('
    if vim.fn.search(search_pattern) > 0 then
      vim.cmd('normal! zz') -- Center the line
      print('Found method: ' .. method)
    else
      print('Method not found: ' .. method)
    end
  else
    print('Opened controller: ' .. file)
  end
end

-- Function to show routes with Telescope
function M.route_picker()
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
  
  local routes = get_routes()
  
  if #routes == 0 then
    print("No routes found. Make sure you're in a Laravel project.")
    return
  end
  
  pickers.new({}, {
    prompt_title = 'Laravel Routes',
    layout_strategy = 'horizontal',
    layout_config = {
      horizontal = {
        prompt_position = 'top',
        preview_width = 0.7,  -- Preview takes 70% of width (wider)
        results_width = 0.3,  -- Results takes 30% of width (narrower)
      },
      width = 0.95,  -- Use 95% of screen width
      height = 0.85, -- Use 85% of screen height
    },
    finder = finders.new_table({
      results = routes,
      entry_maker = function(entry)
        -- Compact display for narrow left panel
        local method_short = entry.method:sub(1, 3) -- GET -> GET, POST -> POS
        local uri_short = entry.uri
        
        -- Truncate long URIs
        if string.len(uri_short) > 25 then
          uri_short = string.sub(uri_short, 1, 22) .. '...'
        end
        
        local compact_display = string.format('%s %s', method_short, uri_short)
        
        return {
          value = entry,
          display = compact_display,
          ordinal = entry.uri .. ' ' .. entry.action .. ' ' .. entry.method,
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
        
        -- Add controller info if available
        local controller, method = parse_action(route.action)
        if controller then
          table.insert(lines, '## Controller Information')
          table.insert(lines, '')
          table.insert(lines, '**Controller:** ' .. controller)
          if method then
            table.insert(lines, '**Method:**     ' .. method)
          end
          table.insert(lines, '')
          
          -- Try to show controller file content
          local file = find_controller_file(controller)
          if file then
            table.insert(lines, '**File:** ' .. file)
            table.insert(lines, '')
            
            -- Show method if found
            if method then
              local file_content = vim.fn.readfile(file)
              local method_found = false
              local method_lines = {}
              local brace_count = 0
              local in_method = false
              
              for i, line in ipairs(file_content) do
                if line:match('function%s+' .. method .. '%s*%(') then
                  in_method = true
                  method_found = true
                  table.insert(method_lines, string.format('%3d: %s', i, line))
                elseif in_method then
                  table.insert(method_lines, string.format('%3d: %s', i, line))
                  
                  -- Count braces to find method end
                  local open_braces = 0
                  local close_braces = 0
                  for char in line:gmatch('.') do
                    if char == '{' then
                      open_braces = open_braces + 1
                    elseif char == '}' then
                      close_braces = close_braces + 1
                    end
                  end
                  
                  brace_count = brace_count + open_braces - close_braces
                  
                  if brace_count < 0 then
                    in_method = false
                    break
                  end
                end
                
                if #method_lines > 25 then -- Limit preview size
                  table.insert(method_lines, '... (truncated)')
                  break
                end
              end
              
              if method_found and #method_lines > 0 then
                table.insert(lines, '## Method Source')
                table.insert(lines, '')
                table.insert(lines, '```php')
                for _, method_line in ipairs(method_lines) do
                  table.insert(lines, method_line)
                end
                table.insert(lines, '```')
              else
                table.insert(lines, '## Method Source')
                table.insert(lines, '')
                table.insert(lines, '⚠️  Method not found in controller file')
              end
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
            table.insert(lines, '')
            table.insert(lines, 'Raw action: ' .. route.action)
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
          local route = selection.value
          local controller, method = parse_action(route.action)
          if controller then
            goto_controller_method(controller, method)
          else
            print('No controller found for route: ' .. route.uri)
          end
        end
      end)
      
      -- Copy route name
      map('i', '<C-y>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          vim.fn.setreg('+', selection.value.name)
          print('Copied route name: ' .. selection.value.name)
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
      
      return true
    end,
  }):find()
end

-- Function to generate route helper in current buffer
function M.insert_route_helper()
  local routes = get_routes()
  if #routes == 0 then
    print("No routes found")
    return
  end
  
  -- Simple picker for route names
  local route_names = {}
  for _, route in ipairs(routes) do
    if route.name and route.name ~= '' then
      table.insert(route_names, route.name)
    end
  end
  
  if #route_names == 0 then
    print("No named routes found")
    return
  end
  
  -- For now, use input. Could be enhanced with completion
  local route_name = vim.fn.input('Route name: ')
  if route_name == '' then
    return
  end
  
  local helper = "route('" .. route_name .. "')"
  
  -- Insert at cursor
  local line = vim.fn.getline('.')
  local col = vim.fn.col('.') - 1
  local new_line = string.sub(line, 1, col) .. helper .. string.sub(line, col + 1)
  vim.fn.setline('.', new_line)
  
  -- Move cursor after the helper
  vim.fn.cursor(vim.fn.line('.'), col + string.len(helper) + 1)
end

-- Function to show route middleware
function M.show_route_middleware()
  local handle = io.popen('php artisan route:list --columns=uri,name,middleware 2>/dev/null')
  if not handle then
    print("Could not get route middleware")
    return
  end
  
  local content = {}
  for line in handle:lines() do
    table.insert(content, line)
  end
  handle:close()
  
  if #content == 0 then
    print("No route middleware information found")
    return
  end
  
  -- Show in a floating window
  local buf = vim.api.nvim_create_buf(false, true)
  local win_height = math.min(#content + 2, 30)
  local win_width = 100
  
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = win_width,
    height = win_height,
    col = (vim.o.columns - win_width) / 2,
    row = (vim.o.lines - win_height) / 2,
    style = 'minimal',
    border = 'rounded',
    title = ' Route Middleware ',
    title_pos = 'center',
  })
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  
  -- Close with q or Escape
  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, silent = true })
  vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf, silent = true })
end

-- Debug function to check Laravel setup
function M.debug_laravel()
  local cwd = vim.fn.getcwd()
  local artisan_exists = vim.fn.filereadable('./artisan') == 1
  local artisan_path = cwd .. '/artisan'
  local artisan_exists2 = vim.fn.filereadable(artisan_path) == 1
  
  print("=== Laravel Route Debug ===")
  print("Current directory: " .. cwd)
  print("Artisan file './artisan' exists: " .. (artisan_exists and "YES" or "NO"))
  print("Artisan file '" .. artisan_path .. "' exists: " .. (artisan_exists2 and "YES" or "NO"))
  
  if artisan_exists then
    local routes_output = vim.fn.system('php -d error_reporting=0 artisan route:list 2>&1')
    print("Route command output preview:")
    print(string.sub(routes_output, 1, 500) .. (string.len(routes_output) > 500 and "..." or ""))
  else
    print("Cannot run artisan command - file not found")
  end
end

-- Quick route list for debugging
function M.quick_route_list()
  print("=== Quick Route List Debug ===")
  
  -- Show raw artisan output first
  print("Raw artisan output (first 10 lines):")
  local cmd = 'php -d error_reporting=0 artisan route:list 2>/dev/null'
  local handle = io.popen(cmd)
  if handle then
    local count = 0
    for line in handle:lines() do
      count = count + 1
      if count <= 10 then
        print("Line " .. count .. ": '" .. line .. "'")
      else
        break
      end
    end
    handle:close()
  end
  
  print("\nParsed routes:")
  local routes = get_routes()
  print("Found " .. #routes .. " routes:")
  for i = 1, math.min(#routes, 5) do
    print("  " .. routes[i].display)
  end
  if #routes > 5 then
    print("  ... and " .. (#routes - 5) .. " more")
  end
end

-- Setup function
function M.setup()
  -- Route picker
  vim.keymap.set('n', '<leader>rr', M.route_picker, {
    desc = '[R]oute [R]outes - Browse Laravel routes'
  })
  
  -- Debug tools
  vim.keymap.set('n', '<leader>rd', M.debug_laravel, {
    desc = '[R]oute [D]ebug - Debug Laravel route setup'
  })
  
  vim.keymap.set('n', '<leader>rq', M.quick_route_list, {
    desc = '[R]oute [Q]uick - Quick route list'
  })
  
  -- Insert route helper
  vim.keymap.set('n', '<leader>ri', M.insert_route_helper, {
    desc = '[R]oute [I]nsert - Insert route() helper'
  })
  
  -- Show route middleware
  vim.keymap.set('n', '<leader>rm', M.show_route_middleware, {
    desc = '[R]oute [M]iddleware - Show route middleware'
  })
  
  -- Quick artisan route commands
  vim.keymap.set('n', '<leader>rl', '<cmd>!php -d error_reporting=0 artisan route:list<cr>', {
    desc = '[R]oute [L]ist - Show route list in terminal'
  })
  
  vim.keymap.set('n', '<leader>rc', '<cmd>!php -d error_reporting=0 artisan route:cache<cr>', {
    desc = '[R]oute [C]ache - Cache routes'
  })
  
  vim.keymap.set('n', '<leader>rC', '<cmd>!php -d error_reporting=0 artisan route:clear<cr>', {
    desc = '[R]oute [C]lear - Clear route cache'
  })
end

return M