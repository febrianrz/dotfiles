-- DD Counter - Laravel Debug Helper
-- Count and manage dd() calls in files

local M = {}

-- Count dd( occurrences in current buffer
function M.count_dd()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local filename = vim.fn.expand('%:t')
  
  local count = 0
  local dd_lines = {}
  
  for line_num, line in ipairs(lines) do
    -- Look for dd( patterns (including variations)
    local matches = {}
    for match in line:gmatch('dd%s*%(') do
      table.insert(matches, match)
    end
    
    if #matches > 0 then
      count = count + #matches
      table.insert(dd_lines, {
        line_num = line_num,
        content = vim.trim(line),
        count = #matches
      })
    end
  end
  
  if count == 0 then
    print("✅ No dd() found in " .. filename)
  else
    print("🐛 Found " .. count .. " dd() in " .. filename .. ":")
    for _, dd_line in ipairs(dd_lines) do
      local indicator = dd_line.count > 1 and (" (" .. dd_line.count .. "x)") or ""
      print("  Line " .. dd_line.line_num .. indicator .. ": " .. dd_line.content)
    end
    
    if count > 5 then
      print("⚠️  Warning: Many dd() calls found - consider cleaning up!")
    end
  end
  
  return count, dd_lines
end

-- Find all dd( with Telescope
function M.find_all_dd()
  local has_telescope, telescope = pcall(require, 'telescope')
  if not has_telescope then
    print("Telescope not found - using simple search")
    M.count_dd()
    return
  end
  
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local filename = vim.fn.expand('%:t')
  
  local dd_entries = {}
  
  for line_num, line in ipairs(lines) do
    if line:match('dd%s*%(') then
      table.insert(dd_entries, {
        line_num = line_num,
        content = vim.trim(line),
        display = string.format("%3d: %s", line_num, vim.trim(line))
      })
    end
  end
  
  if #dd_entries == 0 then
    print("✅ No dd() found in " .. filename)
    return
  end
  
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local previewers = require('telescope.previewers')
  
  pickers.new({}, {
    prompt_title = 'DD Calls in ' .. filename .. ' (' .. #dd_entries .. ' found)',
    layout_strategy = 'horizontal',
    layout_config = {
      horizontal = {
        prompt_position = 'top',
        preview_width = 0.6,
        results_width = 0.4,
      },
      width = 0.9,
      height = 0.8,
    },
    finder = finders.new_table({
      results = dd_entries,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.display,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = 'Code Context',
      get_buffer_by_name = function(_, entry)
        return entry.value.line_num
      end,
      define_preview = function(self, entry, status)
        local line_num = entry.value.line_num
        local start_line = math.max(1, line_num - 10)
        local end_line = math.min(#lines, line_num + 10)
        
        local preview_lines = {}
        for i = start_line, end_line do
          local prefix = i == line_num and ">>> " or "    "
          local line_content = lines[i] or ""
          table.insert(preview_lines, string.format("%s%3d: %s", prefix, i, line_content))
        end
        
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)
        vim.api.nvim_buf_set_option(self.state.bufnr, 'filetype', 'php')
        
        -- Highlight the dd line
        if vim.api.nvim_buf_is_valid(self.state.bufnr) then
          vim.api.nvim_buf_add_highlight(self.state.bufnr, -1, 'Error', 10, 0, -1)
        end
      end,
    }),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.api.nvim_win_set_cursor(0, {selection.value.line_num, 0})
          vim.cmd('normal! zz')
        end
      end)
      
      -- Delete selected dd line
      map('i', '<C-d>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          actions.close(prompt_bufnr)
          local line_num = selection.value.line_num
          vim.api.nvim_buf_set_lines(bufnr, line_num - 1, line_num, false, {})
          print("Removed dd() from line " .. line_num)
        end
      end)
      
      return true
    end,
  }):find()
end

-- Clean all dd( from current file
function M.clean_dd()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local filename = vim.fn.expand('%:t')
  
  local count, dd_lines = M.count_dd()
  
  if count == 0 then
    return
  end
  
  -- Ask for confirmation
  local response = vim.fn.input("Remove " .. count .. " dd() calls from " .. filename .. "? (y/N): ")
  if response:lower() ~= 'y' and response:lower() ~= 'yes' then
    print("Cancelled")
    return
  end
  
  local new_lines = {}
  local removed_count = 0
  
  for line_num, line in ipairs(lines) do
    -- Remove lines that only contain dd() (and whitespace)
    if line:match('^%s*dd%s*%(.*%)%s*;?%s*$') then
      removed_count = removed_count + 1
      -- Skip this line (don't add to new_lines)
    else
      -- For lines with dd() mixed with other code, remove just the dd() part
      local cleaned_line = line
      local original_line = line
      
      -- Remove dd() patterns
      cleaned_line = cleaned_line:gsub('dd%s*%([^)]*%)%s*;?%s*', '')
      cleaned_line = cleaned_line:gsub('%s*,%s*dd%s*%([^)]*%)%s*;?%s*', '')
      cleaned_line = cleaned_line:gsub('^%s*dd%s*%([^)]*%)%s*;?%s*,?%s*', '')
      
      if cleaned_line ~= original_line then
        removed_count = removed_count + 1
      end
      
      -- Only keep non-empty lines
      if vim.trim(cleaned_line) ~= '' then
        table.insert(new_lines, cleaned_line)
      end
    end
  end
  
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
  print("✅ Removed " .. removed_count .. " dd() calls from " .. filename)
end

-- Count dd( in project (all PHP files)
function M.count_project_dd()
  local cmd = 'find . -name "*.php" -exec grep -l "dd(" {} \\;'
  local handle = io.popen(cmd)
  if not handle then
    print("Failed to search project")
    return
  end
  
  local files_with_dd = {}
  for line in handle:lines() do
    table.insert(files_with_dd, line)
  end
  handle:close()
  
  if #files_with_dd == 0 then
    print("✅ No dd() found in project PHP files")
    return
  end
  
  print("🐛 Found dd() in " .. #files_with_dd .. " files:")
  for _, file in ipairs(files_with_dd) do
    local count_cmd = 'grep -o "dd(" "' .. file .. '" | wc -l'
    local count_handle = io.popen(count_cmd)
    if count_handle then
      local count = tonumber(count_handle:read('*all'):match('%d+')) or 0
      count_handle:close()
      print("  " .. file .. " (" .. count .. " dd calls)")
    end
  end
end

-- Setup function
function M.setup()
  -- Add commands
  vim.api.nvim_create_user_command('DDCount', M.count_dd, { desc = 'Count dd() in current file' })
  vim.api.nvim_create_user_command('DDFind', M.find_all_dd, { desc = 'Find all dd() with Telescope' })
  vim.api.nvim_create_user_command('DDClean', M.clean_dd, { desc = 'Remove all dd() from current file' })
  vim.api.nvim_create_user_command('DDProject', M.count_project_dd, { desc = 'Count dd() in entire project' })
end

return M