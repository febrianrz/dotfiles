-- Laravel Logs Viewer
-- View Laravel log files with Telescope integration (similar to git changes)

local M = {}

-- Function to find Laravel log directory
local function find_laravel_log_dir()
  local current_dir = vim.fn.getcwd()
  
  -- Check common Laravel log locations
  local possible_paths = {
    current_dir .. '/storage/logs',
    current_dir .. '/laravel/storage/logs',
    current_dir .. '/../storage/logs',
  }
  
  for _, path in ipairs(possible_paths) do
    if vim.fn.isdirectory(path) == 1 then
      return path
    end
  end
  
  -- Try to find artisan file and deduce storage/logs from there
  local artisan_paths = vim.fn.globpath(current_dir, '**/artisan', 0, 1)
  for _, artisan_path in ipairs(artisan_paths) do
    local project_root = vim.fn.fnamemodify(artisan_path, ':h')
    local log_path = project_root .. '/storage/logs'
    if vim.fn.isdirectory(log_path) == 1 then
      return log_path
    end
  end
  
  return nil
end

-- Function to get log files with modification time
local function get_log_files()
  local log_dir = find_laravel_log_dir()
  if not log_dir then
    return {}
  end
  
  local log_files = {}
  local files = vim.fn.globpath(log_dir, '*.log', 0, 1)
  
  for _, file in ipairs(files) do
    local stat = vim.loop.fs_stat(file)
    if stat then
      table.insert(log_files, {
        path = file,
        name = vim.fn.fnamemodify(file, ':t'),
        size = stat.size,
        mtime = stat.mtime.sec,
        mtime_str = os.date('%Y-%m-%d %H:%M:%S', stat.mtime.sec)
      })
    end
  end
  
  -- Sort by modification time (newest first)
  table.sort(log_files, function(a, b)
    return a.mtime > b.mtime
  end)
  
  return log_files
end

-- Function to parse log entries from file
local function parse_log_entries(file_path, limit)
  limit = limit or 50
  local entries = {}
  
  if vim.fn.filereadable(file_path) == 0 then
    return entries
  end
  
  local lines = vim.fn.readfile(file_path)
  local current_entry = nil
  local entry_count = 0
  
  -- Parse from end to beginning for latest entries first
  for i = #lines, 1, -1 do
    local line = lines[i]
    
    -- Laravel log pattern: [YYYY-MM-DD HH:MM:SS] environment.LEVEL: message
    local date, time, env, level, message = line:match('%[(%d%d%d%d%-%d%d%-%d%d) (%d%d:%d%d:%d%d)%] ([^%.]+)%.([^:]+): (.+)')
    
    if date and time and env and level and message then
      -- If we have a current entry, save it (since we're going backwards)
      if current_entry then
        table.insert(entries, 1, current_entry)
        entry_count = entry_count + 1
        if entry_count >= limit then
          break
        end
      end
      
      -- Start new entry
      current_entry = {
        timestamp = date .. ' ' .. time,
        environment = env,
        level = level,
        message = message,
        stack_trace = {},
        line_number = i
      }
    elseif current_entry and line:match('^%s+') then
      -- This is likely a stack trace line
      table.insert(current_entry.stack_trace, 1, line)
    elseif current_entry then
      -- Non-indented line that's not a log header, might be continuation
      if not line:match('^%s*$') then
        current_entry.message = line .. ' ' .. current_entry.message
      end
    end
  end
  
  -- Don't forget the last entry
  if current_entry and entry_count < limit then
    table.insert(entries, 1, current_entry)
  end
  
  return entries
end

-- Function to get level color/icon
local function get_level_display(level)
  local level_upper = level:upper()
  local displays = {
    ERROR = { icon = '🔴', color = 'ErrorMsg' },
    CRITICAL = { icon = '💥', color = 'ErrorMsg' },
    ALERT = { icon = '🚨', color = 'ErrorMsg' },
    EMERGENCY = { icon = '⚠️', color = 'ErrorMsg' },
    WARNING = { icon = '🟡', color = 'WarningMsg' },
    NOTICE = { icon = '🔵', color = 'Normal' },
    INFO = { icon = '💡', color = 'Normal' },
    DEBUG = { icon = '🐛', color = 'Comment' },
  }
  
  return displays[level_upper] or { icon = '📝', color = 'Normal' }
end

-- Telescope picker for log files
function M.log_files_picker()
  local has_telescope, telescope = pcall(require, 'telescope')
  if not has_telescope then
    vim.notify('Telescope not found', vim.log.levels.ERROR)
    return
  end
  
  local log_files = get_log_files()
  if #log_files == 0 then
    vim.notify('No Laravel log files found', vim.log.levels.WARN)
    return
  end
  
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local previewers = require('telescope.previewers')
  
  pickers.new({}, {
    prompt_title = 'Laravel Log Files',
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
      results = log_files,
      entry_maker = function(entry)
        local size_mb = string.format('%.2f MB', entry.size / 1024 / 1024)
        local display = string.format('%s (%s) - %s', entry.name, size_mb, entry.mtime_str)
        
        return {
          value = entry,
          display = display,
          ordinal = entry.name .. ' ' .. entry.mtime_str,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = 'Recent Log Entries',
      get_buffer_by_name = function(_, entry)
        return entry.value.name
      end,
      define_preview = function(self, entry, status)
        local log_entries = parse_log_entries(entry.value.path, 20)
        local lines = {}
        
        table.insert(lines, '# ' .. entry.value.name)
        table.insert(lines, '')
        table.insert(lines, '**File:** ' .. entry.value.path)
        table.insert(lines, '**Size:** ' .. string.format('%.2f MB', entry.value.size / 1024 / 1024))
        table.insert(lines, '**Last Modified:** ' .. entry.value.mtime_str)
        table.insert(lines, '')
        table.insert(lines, '## Recent Entries (Latest First)')
        table.insert(lines, '')
        
        for _, log_entry in ipairs(log_entries) do
          local level_display = get_level_display(log_entry.level)
          table.insert(lines, string.format('%s **[%s]** `%s.%s`', 
            level_display.icon, 
            log_entry.timestamp, 
            log_entry.environment, 
            log_entry.level:upper()
          ))
          table.insert(lines, '')
          table.insert(lines, log_entry.message)
          
          if #log_entry.stack_trace > 0 then
            table.insert(lines, '')
            table.insert(lines, '```')
            for _, trace_line in ipairs(log_entry.stack_trace) do
              table.insert(lines, trace_line)
            end
            table.insert(lines, '```')
          end
          
          table.insert(lines, '')
          table.insert(lines, '---')
          table.insert(lines, '')
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
          M.log_entries_picker(selection.value.path)
        end
      end)
      
      -- Open file in editor
      map('i', '<C-o>', function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.cmd('edit ' .. selection.value.path)
        end
      end)
      
      -- Clear log file
      map('i', '<C-d>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          local response = vim.fn.input('Clear log file "' .. selection.value.name .. '"? (y/N): ')
          if response:lower() == 'y' then
            vim.fn.writefile({}, selection.value.path)
            vim.notify('Log file cleared: ' .. selection.value.name, vim.log.levels.INFO)
            actions.close(prompt_bufnr)
          end
        end
      end)
      
      return true
    end,
  }):find()
end

-- Telescope picker for log entries from specific file
function M.log_entries_picker(file_path)
  file_path = file_path or (find_laravel_log_dir() and find_laravel_log_dir() .. '/laravel.log')
  
  if not file_path or vim.fn.filereadable(file_path) == 0 then
    vim.notify('Log file not found: ' .. (file_path or 'unknown'), vim.log.levels.ERROR)
    return
  end
  
  local has_telescope, telescope = pcall(require, 'telescope')
  if not has_telescope then
    vim.notify('Telescope not found', vim.log.levels.ERROR)
    return
  end
  
  local log_entries = parse_log_entries(file_path, 100)
  if #log_entries == 0 then
    vim.notify('No log entries found in: ' .. file_path, vim.log.levels.WARN)
    return
  end
  
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local previewers = require('telescope.previewers')
  
  pickers.new({}, {
    prompt_title = 'Laravel Log Entries (' .. vim.fn.fnamemodify(file_path, ':t') .. ')',
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
      results = log_entries,
      entry_maker = function(entry)
        local level_display = get_level_display(entry.level)
        local short_message = entry.message:sub(1, 60)
        if #entry.message > 60 then
          short_message = short_message .. '...'
        end
        
        local display = string.format('%s [%s] %s.%s: %s',
          level_display.icon,
          entry.timestamp:sub(12, 19), -- Just time part
          entry.environment,
          entry.level:upper(),
          short_message
        )
        
        return {
          value = entry,
          display = display,
          ordinal = entry.timestamp .. ' ' .. entry.level .. ' ' .. entry.message,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = 'Log Entry Details',
      get_buffer_by_name = function(_, entry)
        return entry.value.timestamp .. '_' .. entry.value.level
      end,
      define_preview = function(self, entry, status)
        local log_entry = entry.value
        local level_display = get_level_display(log_entry.level)
        
        local lines = {
          '# Log Entry Details',
          '',
          '**Timestamp:** ' .. log_entry.timestamp,
          '**Environment:** ' .. log_entry.environment,
          '**Level:** ' .. level_display.icon .. ' ' .. log_entry.level:upper(),
          '',
          '## Message',
          '',
          log_entry.message,
          '',
        }
        
        if #log_entry.stack_trace > 0 then
          table.insert(lines, '## Stack Trace')
          table.insert(lines, '')
          table.insert(lines, '```')
          for _, trace_line in ipairs(log_entry.stack_trace) do
            table.insert(lines, trace_line)
          end
          table.insert(lines, '```')
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
          -- Open log file at specific line
          vim.cmd('edit +' .. selection.value.line_number .. ' ' .. file_path)
        end
      end)
      
      -- Copy log entry to clipboard
      map('i', '<C-y>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          local log_text = string.format('[%s] %s.%s: %s\n%s',
            selection.value.timestamp,
            selection.value.environment,
            selection.value.level:upper(),
            selection.value.message,
            table.concat(selection.value.stack_trace, '\n')
          )
          vim.fn.setreg('+', log_text)
          vim.notify('Log entry copied to clipboard', vim.log.levels.INFO)
        end
      end)
      
      return true
    end,
  }):find()
end

-- Watch laravel.log in real-time (tail -f equivalent)
function M.tail_log()
  local log_dir = find_laravel_log_dir()
  if not log_dir then
    vim.notify('Laravel project not found', vim.log.levels.ERROR)
    return
  end
  
  local laravel_log = log_dir .. '/laravel.log'
  if vim.fn.filereadable(laravel_log) == 0 then
    vim.notify('Laravel log file not found: ' .. laravel_log, vim.log.levels.ERROR)
    return
  end
  
  -- Open in new tab
  vim.cmd('tabnew')
  vim.cmd('terminal tail -f ' .. vim.fn.shellescape(laravel_log))
  vim.cmd('startinsert')
end

-- Clear all log files
function M.clear_all_logs()
  local log_dir = find_laravel_log_dir()
  if not log_dir then
    vim.notify('Laravel project not found', vim.log.levels.ERROR)
    return
  end
  
  local response = vim.fn.input('Clear all Laravel log files? (y/N): ')
  if response:lower() ~= 'y' then
    return
  end
  
  local log_files = vim.fn.globpath(log_dir, '*.log', 0, 1)
  local cleared_count = 0
  
  for _, file in ipairs(log_files) do
    vim.fn.writefile({}, file)
    cleared_count = cleared_count + 1
  end
  
  vim.notify(string.format('Cleared %d log files', cleared_count), vim.log.levels.INFO)
end

-- Setup function
function M.setup()
  -- Commands
  vim.api.nvim_create_user_command('LaravelLogs', M.log_files_picker, { desc = 'Browse Laravel log files' })
  vim.api.nvim_create_user_command('LaravelLogEntries', function(opts)
    M.log_entries_picker(opts.args ~= '' and opts.args or nil)
  end, { desc = 'Browse Laravel log entries', nargs = '?' })
  vim.api.nvim_create_user_command('LaravelLogTail', M.tail_log, { desc = 'Tail Laravel log file' })
  vim.api.nvim_create_user_command('LaravelLogClear', M.clear_all_logs, { desc = 'Clear all Laravel log files' })
end

return M