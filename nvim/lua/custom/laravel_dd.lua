-- Laravel DD (dump and die) helper for Neovim
-- Automatically inserts dd() with filename and line number for debugging

local M = {}

-- Function to insert dd() with file info
function M.insert_dd()
  local current_file = vim.fn.expand('%:t') -- Get filename only
  local current_line = vim.fn.line('.') -- Get current line number
  
  -- Create the dd statement
  local dd_statement = string.format("dd('%s:%d');", current_file, current_line)
  
  -- Get current line content and cursor position
  local line = vim.fn.getline('.')
  local col = vim.fn.col('.') - 1
  
  -- Insert dd statement at cursor position
  local new_line = string.sub(line, 1, col) .. dd_statement .. string.sub(line, col + 1)
  vim.fn.setline('.', new_line)
  
  -- Move cursor after the inserted text
  vim.fn.cursor(vim.fn.line('.'), col + string.len(dd_statement) + 1)
  
  print("DD inserted: " .. dd_statement)
end

-- Function to insert dd() on new line
function M.insert_dd_newline()
  local current_file = vim.fn.expand('%:t')
  local current_line = vim.fn.line('.') + 1 -- Next line number since we're adding new line
  
  local dd_statement = string.format("dd('%s:%d');", current_file, current_line)
  
  -- Insert new line and add dd statement
  vim.fn.append('.', dd_statement)
  
  -- Move cursor to the new line
  vim.fn.cursor(vim.fn.line('.') + 1, string.len(dd_statement) + 1)
  
  print("DD inserted on new line: " .. dd_statement)
end

-- Function to insert dd() with custom message
function M.insert_dd_with_message()
  local current_file = vim.fn.expand('%:t')
  local current_line = vim.fn.line('.')
  
  -- Prompt for custom message
  local message = vim.fn.input("DD message: ")
  if message == "" then
    message = "debug"
  end
  
  local dd_statement = string.format("dd('%s:%d - %s');", current_file, current_line, message)
  
  -- Insert on new line
  vim.fn.append('.', dd_statement)
  vim.fn.cursor(vim.fn.line('.') + 1, string.len(dd_statement) + 1)
  
  print("DD with message inserted: " .. dd_statement)
end

-- Function to insert dd() with variable dump
function M.insert_dd_variable()
  local current_file = vim.fn.expand('%:t')
  local current_line = vim.fn.line('.')
  
  -- Prompt for variable name
  local variable = vim.fn.input("Variable to dump: ")
  if variable == "" then
    variable = "$data"
  end
  
  local dd_statement = string.format("dd('%s:%d', %s);", current_file, current_line, variable)
  
  -- Insert on new line
  vim.fn.append('.', dd_statement)
  vim.fn.cursor(vim.fn.line('.') + 1, string.len(dd_statement) + 1)
  
  print("DD with variable inserted: " .. dd_statement)
end

-- Function to remove all dd() statements from current file
function M.remove_all_dd()
  local lines = vim.fn.getline(1, '$')
  local new_lines = {}
  local removed_count = 0
  
  for _, line in ipairs(lines) do
    -- Check if line contains dd() call (simple pattern matching)
    if not string.match(line, "dd%(.*%).*;?") then
      table.insert(new_lines, line)
    else
      removed_count = removed_count + 1
    end
  end
  
  -- Replace all lines
  vim.fn.setline(1, new_lines)
  
  -- Remove empty lines at the end
  vim.cmd('silent! %s/\\n\\+\\%$//e')
  
  print(string.format("Removed %d dd() statements", removed_count))
end

-- Setup function to register keymaps
function M.setup()
  -- Basic dd() insertion
  vim.keymap.set('n', '<leader>dd', M.insert_dd, { 
    desc = '[D]ebug [D]ump - Insert dd() at cursor with file:line' 
  })
  
  -- dd() on new line
  vim.keymap.set('n', '<leader>dN', M.insert_dd_newline, { 
    desc = '[D]ebug [N]ew line - Insert dd() on new line with file:line' 
  })
  
  -- dd() with custom message
  vim.keymap.set('n', '<leader>dm', M.insert_dd_with_message, { 
    desc = '[D]ebug [M]essage - Insert dd() with custom message' 
  })
  
  -- dd() with variable
  vim.keymap.set('n', '<leader>dv', M.insert_dd_variable, { 
    desc = '[D]ebug [V]ariable - Insert dd() with variable dump' 
  })
  
  -- Remove all dd() statements
  vim.keymap.set('n', '<leader>dc', M.remove_all_dd, { 
    desc = '[D]ebug [C]lean - Remove all dd() statements from file' 
  })
end

return M