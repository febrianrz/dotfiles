-- Laravel Debug Tools
-- Enhanced debugging utilities for Laravel development

local M = {}

-- Function to insert Laravel debug statements
function M.insert_laravel_debug()
  local debug_options = {
    'dd()',
    'dump()',
    'logger()->info()',
    'logger()->debug()',
    'logger()->error()',
    'Log::info()',
    'Log::debug()',
    'Log::error()',
    'Ray::debug()',
  }
  
  -- Simple picker (could be enhanced with telescope)
  print("Debug options:")
  for i, option in ipairs(debug_options) do
    print(i .. ": " .. option)
  end
  
  local choice = vim.fn.input("Choose debug option (1-" .. #debug_options .. "): ")
  local choice_num = tonumber(choice)
  
  if choice_num and choice_num >= 1 and choice_num <= #debug_options then
    local debug_statement = debug_options[choice_num]
    local current_file = vim.fn.expand('%:t')
    local current_line = vim.fn.line('.')
    
    -- Customize debug statement based on choice
    if debug_statement:match('dd%(%)') then
      debug_statement = string.format("dd('%s:%d', $data);", current_file, current_line)
    elseif debug_statement:match('dump%(%)') then
      debug_statement = string.format("dump('%s:%d', $data);", current_file, current_line)
    elseif debug_statement:match('logger%(%)') or debug_statement:match('Log::') then
      local log_message = vim.fn.input("Log message: ")
      if log_message ~= '' then
        if debug_statement:match('logger%(%)') then
          debug_statement = string.format("logger()->%s('%s:%d - %s', $data);", 
            debug_statement:match('(%w+)%(%)$'), current_file, current_line, log_message)
        else
          debug_statement = string.format("Log::%s('%s:%d - %s', $data);", 
            debug_statement:match('::(%w+)%(%)$'), current_file, current_line, log_message)
        end
      end
    elseif debug_statement:match('Ray::') then
      debug_statement = string.format("Ray::debug('%s:%d', $data);", current_file, current_line)
    end
    
    -- Insert the debug statement
    vim.fn.append('.', debug_statement)
    vim.fn.cursor(vim.fn.line('.') + 1, string.len(debug_statement) + 1)
    print("Inserted: " .. debug_statement)
  end
end

-- Function to remove all debug statements from current file
function M.clean_debug_statements()
  local debug_patterns = {
    'dd%(.*%);?',
    'dump%(.*%);?',
    'logger%(%)%->%w+%(.*%);?',
    'Log::%w+%(.*%);?',
    'Ray::%w+%(.*%);?',
    'var_dump%(.*%);?',
    'print_r%(.*%);?',
  }
  
  local lines = vim.fn.getline(1, '$')
  local new_lines = {}
  local removed_count = 0
  
  for _, line in ipairs(lines) do
    local is_debug = false
    for _, pattern in ipairs(debug_patterns) do
      if line:match(pattern) then
        is_debug = true
        removed_count = removed_count + 1
        break
      end
    end
    
    if not is_debug then
      table.insert(new_lines, line)
    end
  end
  
  vim.fn.setline(1, new_lines)
  print(string.format("Removed %d debug statements", removed_count))
end

-- Function to show Laravel logs in real-time
function M.tail_laravel_logs()
  local log_file = vim.fn.getcwd() .. '/storage/logs/laravel.log'
  
  if vim.fn.filereadable(log_file) == 0 then
    print("Laravel log file not found: " .. log_file)
    return
  end
  
  -- Open log file in split and tail it
  vim.cmd('split ' .. log_file)
  vim.cmd('normal! G') -- Go to end of file
  
  -- Set up auto-reload for log file
  vim.api.nvim_create_autocmd({'FocusGained', 'BufEnter'}, {
    buffer = vim.api.nvim_get_current_buf(),
    callback = function()
      vim.cmd('checktime')
      vim.cmd('normal! G')
    end,
  })
  
  print("Watching Laravel logs - press 'q' to close")
end

-- Function to clear Laravel logs
function M.clear_laravel_logs()
  local log_file = vim.fn.getcwd() .. '/storage/logs/laravel.log'
  
  if vim.fn.filereadable(log_file) == 1 then
    local confirm = vim.fn.input("Clear Laravel logs? (y/N): ")
    if confirm:lower() == 'y' then
      vim.fn.writefile({}, log_file)
      print("Laravel logs cleared")
    end
  else
    print("Laravel log file not found")
  end
end

-- Function to show Laravel config values
function M.show_laravel_config()
  local config_key = vim.fn.input("Config key (e.g., app.name): ")
  if config_key == '' then
    return
  end
  
  local cmd = 'php artisan tinker --execute="echo config(\'' .. config_key .. '\');"'
  local result = vim.fn.system(cmd)
  
  -- Show result in floating window
  local lines = vim.split(result, '\n')
  local content = {'Config: ' .. config_key, ''}
  for _, line in ipairs(lines) do
    if line:match('%S') then -- Only non-empty lines
      table.insert(content, line)
    end
  end
  
  local buf = vim.api.nvim_create_buf(false, true)
  local win_height = math.min(#content + 2, 15)
  local win_width = 60
  
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = win_width,
    height = win_height,
    col = (vim.o.columns - win_width) / 2,
    row = (vim.o.lines - win_height) / 2,
    style = 'minimal',
    border = 'rounded',
    title = ' Laravel Config ',
    title_pos = 'center',
  })
  
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  
  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, silent = true })
  vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf, silent = true })
end

-- Function to run Laravel queue work in terminal
function M.run_queue_worker()
  local Terminal = require('toggleterm.terminal').Terminal
  
  local queue_term = Terminal:new({
    cmd = 'php artisan queue:work --verbose',
    direction = 'horizontal',
    size = 15,
    close_on_exit = false,
    on_open = function()
      print("Laravel queue worker started")
    end,
    on_exit = function()
      print("Laravel queue worker stopped")
    end,
  })
  
  queue_term:toggle()
end

-- Function to show Laravel environment info
function M.show_env_info()
  local env_commands = {
    'php artisan env',
    'php artisan about',
    'php --version',
    'composer --version',
  }
  
  local content = {'Laravel Environment Info', ''}
  
  for _, cmd in ipairs(env_commands) do
    local result = vim.fn.system(cmd .. ' 2>/dev/null')
    if result ~= '' then
      table.insert(content, '# ' .. cmd)
      for line in result:gmatch('[^\r\n]+') do
        table.insert(content, line)
      end
      table.insert(content, '')
    end
  end
  
  -- Show in buffer
  vim.cmd('new')
  vim.api.nvim_buf_set_lines(0, 0, -1, false, content)
  vim.bo.filetype = 'markdown'
  vim.bo.buftype = 'nofile'
  vim.bo.bufhidden = 'wipe'
  vim.bo.modifiable = false
end

-- Function to open Laravel telescope (if installed)
function M.open_laravel_telescope()
  local url = 'http://localhost:8000/telescope'
  local cmd
  
  if vim.fn.has('macunix') == 1 then
    cmd = 'open ' .. url
  elseif vim.fn.has('unix') == 1 then
    cmd = 'xdg-open ' .. url
  else
    print("Telescope URL: " .. url)
    return
  end
  
  vim.fn.system(cmd)
  print("Opening Laravel Telescope: " .. url)
end

-- Function to profile current request (for debugging performance)
function M.insert_profiling_code()
  local profiling_options = {
    'Microtime start/end',
    'Memory usage',
    'Database query log',
    'Debugbar profiling',
  }
  
  print("Profiling options:")
  for i, option in ipairs(profiling_options) do
    print(i .. ": " .. option)
  end
  
  local choice = vim.fn.input("Choose profiling option (1-" .. #profiling_options .. "): ")
  local choice_num = tonumber(choice)
  
  if choice_num and choice_num >= 1 and choice_num <= #profiling_options then
    local code_lines = {}
    
    if choice_num == 1 then
      -- Microtime profiling
      table.insert(code_lines, '$start = microtime(true);')
      table.insert(code_lines, '// Your code here')
      table.insert(code_lines, '$end = microtime(true);')
      table.insert(code_lines, 'logger()->info("Execution time: " . ($end - $start) . " seconds");')
    elseif choice_num == 2 then
      -- Memory usage
      table.insert(code_lines, 'logger()->info("Memory usage: " . memory_get_usage(true) . " bytes");')
      table.insert(code_lines, 'logger()->info("Peak memory: " . memory_get_peak_usage(true) . " bytes");')
    elseif choice_num == 3 then
      -- Database query log
      table.insert(code_lines, 'DB::enableQueryLog();')
      table.insert(code_lines, '// Your database operations here')
      table.insert(code_lines, 'logger()->info("Database queries: ", DB::getQueryLog());')
    elseif choice_num == 4 then
      -- Debugbar profiling
      table.insert(code_lines, 'Debugbar::startMeasure("custom_operation", "Custom Operation");')
      table.insert(code_lines, '// Your code here')
      table.insert(code_lines, 'Debugbar::stopMeasure("custom_operation");')
    end
    
    -- Insert the profiling code
    local current_line = vim.fn.line('.')
    vim.fn.append(current_line, code_lines)
    print("Inserted profiling code")
  end
end

-- Setup function
function M.setup()
  -- Debug statement insertion
  vim.keymap.set('n', '<leader>xi', M.insert_laravel_debug, {
    desc = 'Debug [I]nsert - Insert Laravel debug statement'
  })
  
  -- Clean debug statements
  vim.keymap.set('n', '<leader>xc', M.clean_debug_statements, {
    desc = 'Debug [C]lean - Remove all debug statements'
  })
  
  -- Laravel logs
  vim.keymap.set('n', '<leader>xl', M.tail_laravel_logs, {
    desc = 'Debug [L]ogs - Watch Laravel logs'
  })
  
  vim.keymap.set('n', '<leader>xC', M.clear_laravel_logs, {
    desc = 'Debug [C]lear logs - Clear Laravel logs'
  })
  
  -- Laravel config
  vim.keymap.set('n', '<leader>xg', M.show_laravel_config, {
    desc = 'Debug [G]et config - Show Laravel config value'
  })
  
  -- Queue worker
  vim.keymap.set('n', '<leader>xq', M.run_queue_worker, {
    desc = 'Debug [Q]ueue - Run Laravel queue worker'
  })
  
  -- Environment info
  vim.keymap.set('n', '<leader>xe', M.show_env_info, {
    desc = 'Debug [E]nv - Show Laravel environment info'
  })
  
  -- Laravel Telescope
  vim.keymap.set('n', '<leader>xt', M.open_laravel_telescope, {
    desc = 'Debug [T]elescope - Open Laravel Telescope'
  })
  
  -- Profiling
  vim.keymap.set('n', '<leader>xp', M.insert_profiling_code, {
    desc = 'Debug [P]rofiling - Insert profiling code'
  })
  
  -- Quick Artisan commands for debugging
  vim.keymap.set('n', '<leader>xr', '<cmd>!php artisan route:cache<cr>', {
    desc = 'Debug [R]oute cache - Clear and cache routes'
  })
  
  vim.keymap.set('n', '<leader>xv', '<cmd>!php artisan view:clear<cr>', {
    desc = 'Debug [V]iew clear - Clear view cache'
  })
  
  vim.keymap.set('n', '<leader>xa', '<cmd>!php artisan config:clear && php artisan cache:clear<cr>', {
    desc = 'Debug [A]ll clear - Clear all caches'
  })
end

return M