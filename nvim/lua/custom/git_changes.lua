-- Git Changes Buffer Utility for Neovim
-- Shows list of modified Git files with changes and diff preview

local M = {}

-- Function to get git status files
local function get_git_changed_files()
  local handle = io.popen('git status --porcelain 2>/dev/null')
  if not handle then
    return {}
  end
  
  local result = handle:read('*a')
  handle:close()
  
  if not result or result == '' then
    return {}
  end
  
  local files = {}
  for line in result:gmatch('[^\r\n]+') do
    local status = line:sub(1, 2)
    local file = line:sub(4)
    
    -- Skip deleted files
    if not status:match('D') then
      table.insert(files, {
        status = status,
        file = file,
        display = string.format('[%s] %s', status, file)
      })
    end
  end
  
  return files
end

-- Function to show git diff for a file
local function show_git_diff(file)
  local cmd = string.format('git diff HEAD -- %s 2>/dev/null', vim.fn.shellescape(file))
  local handle = io.popen(cmd)
  if not handle then
    return "Error: Could not get git diff"
  end
  
  local diff = handle:read('*a')
  handle:close()
  
  if diff == '' then
    -- Try staged diff if no unstaged changes
    cmd = string.format('git diff --cached -- %s 2>/dev/null', vim.fn.shellescape(file))
    handle = io.popen(cmd)
    if handle then
      diff = handle:read('*a')
      handle:close()
    end
  end
  
  return diff ~= '' and diff or "No changes to show"
end

-- Function to open git changed files with Telescope
function M.git_changed_files_telescope()
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
  
  local files = get_git_changed_files()
  
  if #files == 0 then
    print("No git changes found")
    return
  end
  
  pickers.new({}, {
    prompt_title = 'Git Changed Files',
    layout_strategy = 'horizontal',
    layout_config = {
      horizontal = {
        prompt_position = 'top',
        preview_width = 0.7,  -- Preview takes 70% of width
        results_width = 0.3,  -- Results takes 30% of width
      },
      width = 0.95,  -- Use 95% of screen width
      height = 0.85, -- Use 85% of screen height
    },
    finder = finders.new_table({
      results = files,
      entry_maker = function(entry)
        -- Compact display for narrow left panel
        local filename = vim.fn.fnamemodify(entry.file, ':t') -- Just filename
        local dir = vim.fn.fnamemodify(entry.file, ':h')      -- Directory
        local compact_display
        
        if dir == '.' then
          compact_display = string.format('%s %s', entry.status, filename)
        else
          -- Truncate long directory paths
          local short_dir = string.len(dir) > 15 and '...' .. string.sub(dir, -12) or dir
          compact_display = string.format('%s %s/%s', entry.status, short_dir, filename)
        end
        
        return {
          value = entry,
          display = compact_display,
          ordinal = entry.file,
          path = entry.file,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = 'Git Diff',
      get_buffer_by_name = function(_, entry)
        return entry.path
      end,
      define_preview = function(self, entry, status)
        local diff = show_git_diff(entry.path)
        local lines = vim.split(diff, '\n')
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        
        -- Set filetype for syntax highlighting
        vim.api.nvim_buf_set_option(self.state.bufnr, 'filetype', 'diff')
      end,
    }),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.cmd('edit ' .. selection.path)
        end
      end)
      
      -- Custom mapping to show full diff in split
      map('i', '<C-d>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          actions.close(prompt_bufnr)
          vim.cmd('vsplit')
          vim.cmd('enew')
          local diff = show_git_diff(selection.path)
          local lines = vim.split(diff, '\n')
          vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
          vim.bo.filetype = 'diff'
          vim.bo.buftype = 'nofile'
          vim.bo.bufhidden = 'wipe'
        end
      end)
      
      -- Custom mapping to stage file
      map('i', '<C-s>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          vim.fn.system('git add ' .. vim.fn.shellescape(selection.path))
          print('Staged: ' .. selection.path)
        end
      end)
      
      return true
    end,
  }):find()
end

-- Simple function to list git changes in quickfix
function M.git_changed_files_quickfix()
  local files = get_git_changed_files()
  
  if #files == 0 then
    print("No git changes found")
    return
  end
  
  local qf_list = {}
  for _, file in ipairs(files) do
    table.insert(qf_list, {
      filename = file.file,
      text = file.display,
      lnum = 1,
      col = 1,
    })
  end
  
  vim.fn.setqflist(qf_list)
  vim.cmd('copen')
  print(string.format("Found %d changed files", #files))
end

-- Function to open git changes in buffer list
function M.git_changed_files_buffers()
  local files = get_git_changed_files()
  
  if #files == 0 then
    print("No git changes found")
    return
  end
  
  -- Open each file in buffer
  for _, file in ipairs(files) do
    vim.cmd('badd ' .. file.file)
  end
  
  -- Open buffer list with telescope if available
  local has_telescope = pcall(require, 'telescope.builtin')
  if has_telescope then
    require('telescope.builtin').buffers()
  else
    vim.cmd('ls')
  end
  
  print(string.format("Loaded %d changed files into buffers", #files))
end

-- Function to show git status in floating window
function M.git_status_float()
  local files = get_git_changed_files()
  
  if #files == 0 then
    print("No git changes found")
    return
  end
  
  -- Create content
  local content = {'Git Status:', ''}
  for _, file in ipairs(files) do
    table.insert(content, file.display)
  end
  table.insert(content, '')
  table.insert(content, 'Press q to close, Enter to open file')
  
  -- Create floating window
  local buf = vim.api.nvim_create_buf(false, true)
  local win_height = math.min(#content + 2, 20)
  local win_width = 60
  
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = win_width,
    height = win_height,
    col = (vim.o.columns - win_width) / 2,
    row = (vim.o.lines - win_height) / 2,
    style = 'minimal',
    border = 'rounded',
    title = ' Git Changes ',
    title_pos = 'center',
  })
  
  -- Set content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  vim.api.nvim_buf_set_option(buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
  
  -- Set keymaps for the floating window
  local opts = { buffer = buf, silent = true }
  vim.keymap.set('n', 'q', '<cmd>close<cr>', opts)
  vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', opts)
  
  -- Handle Enter to open file
  vim.keymap.set('n', '<CR>', function()
    local line = vim.fn.getline('.')
    local file_match = line:match('%] (.+)$')
    if file_match then
      vim.api.nvim_win_close(win, true)
      vim.cmd('edit ' .. file_match)
    end
  end, opts)
end

-- Function with different layout (wider preview)
function M.git_changed_files_wide()
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
  
  local files = get_git_changed_files()
  
  if #files == 0 then
    print("No git changes found")
    return
  end
  
  pickers.new({}, {
    prompt_title = 'Git Changed Files (Wide)',
    layout_strategy = 'horizontal',
    layout_config = {
      horizontal = {
        prompt_position = 'top',
        preview_width = 0.8,  -- Even wider preview (80%)
        results_width = 0.2,  -- Narrower results (20%)
      },
      width = 0.98,  -- Use almost full screen width
      height = 0.9,  -- Use 90% of screen height
    },
    finder = finders.new_table({
      results = files,
      entry_maker = function(entry)
        -- Ultra compact display for very narrow left panel
        local filename = vim.fn.fnamemodify(entry.file, ':t')
        local status_icon = entry.status:gsub(' ', '') -- Remove spaces
        
        return {
          value = entry,
          display = status_icon .. ' ' .. filename,
          ordinal = entry.file,
          path = entry.file,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = 'Git Diff',
      get_buffer_by_name = function(_, entry)
        return entry.path
      end,
      define_preview = function(self, entry, status)
        local diff = show_git_diff(entry.path)
        local lines = vim.split(diff, '\n')
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(self.state.bufnr, 'filetype', 'diff')
      end,
    }),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.cmd('edit ' .. selection.path)
        end
      end)
      
      map('i', '<C-d>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          actions.close(prompt_bufnr)
          vim.cmd('vsplit')
          vim.cmd('enew')
          local diff = show_git_diff(selection.path)
          local lines = vim.split(diff, '\n')
          vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
          vim.bo.filetype = 'diff'
          vim.bo.buftype = 'nofile'
          vim.bo.bufhidden = 'wipe'
        end
      end)
      
      map('i', '<C-s>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          vim.fn.system('git add ' .. vim.fn.shellescape(selection.path))
          print('Staged: ' .. selection.path)
        end
      end)
      
      return true
    end,
  }):find()
end

-- Setup function to register keymaps
function M.setup()
  -- Main telescope picker for git changes (compact)
  vim.keymap.set('n', '<leader>gc', M.git_changed_files_telescope, {
    desc = '[G]it [C]hanges - Show changed files with diff preview'
  })
  
  -- Wide layout version
  vim.keymap.set('n', '<leader>gC', M.git_changed_files_wide, {
    desc = '[G]it [C]hanges Wide - Extra wide diff preview'
  })
  
  -- Alternative: quickfix list
  vim.keymap.set('n', '<leader>gq', M.git_changed_files_quickfix, {
    desc = '[G]it [Q]uickfix - Show changed files in quickfix'
  })
  
  -- Load changed files into buffers
  vim.keymap.set('n', '<leader>gb', M.git_changed_files_buffers, {
    desc = '[G]it [B]uffers - Load changed files into buffers'
  })
  
  -- Floating window git status
  vim.keymap.set('n', '<leader>gs', M.git_status_float, {
    desc = '[G]it [S]tatus - Show git status in floating window'
  })
end

return M