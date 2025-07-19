-- DataGrip-style Database Management for Neovim
-- Inspired by JetBrains DataGrip

local M = {}

-- Database connections storage
M.connections = {}
M.current_connection = nil

-- Load connections from config file
local function load_connections()
  local config_path = vim.fn.stdpath('config') .. '/datagrip_connections.json'
  if vim.fn.filereadable(config_path) == 1 then
    local content = vim.fn.readfile(config_path)
    local ok, connections = pcall(vim.fn.json_decode, table.concat(content, '\n'))
    if ok then
      M.connections = connections
    end
  end
end

-- Save connections to config file
local function save_connections()
  local config_path = vim.fn.stdpath('config') .. '/datagrip_connections.json'
  local content = vim.fn.json_encode(M.connections)
  vim.fn.writefile(vim.split(content, '\n'), config_path)
end

-- Get database schema
local function get_schema(connection_url)
  local db_type = connection_url:match('^(%w+):')
  
  if db_type == 'mysql' then
    return {
      query = "SELECT table_name, table_type FROM information_schema.tables WHERE table_schema = DATABASE() ORDER BY table_name",
      columns_query = "SELECT column_name, data_type, is_nullable, column_default FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = '%s' ORDER BY ordinal_position"
    }
  elseif db_type == 'postgresql' then
    return {
      query = "SELECT tablename as table_name, 'BASE TABLE' as table_type FROM pg_tables WHERE schemaname = 'public' UNION SELECT viewname as table_name, 'VIEW' as table_type FROM pg_views WHERE schemaname = 'public' ORDER BY table_name",
      columns_query = "SELECT column_name, data_type, is_nullable, column_default FROM information_schema.columns WHERE table_schema = 'public' AND table_name = '%s' ORDER BY ordinal_position"
    }
  else
    return {
      query = "SELECT name as table_name, type as table_type FROM sqlite_master WHERE type IN ('table', 'view') ORDER BY name",
      columns_query = "PRAGMA table_info('%s')"
    }
  end
end

-- Execute query and return results
local function execute_query(query, connection_url)
  if not connection_url then
    return nil, "No connection selected"
  end
  
  local cmd = string.format('echo "%s" | nvim --headless -c "DB %s" -c "%%DB" -c "q" 2>/dev/null', 
    query:gsub('"', '\\"'), connection_url)
  
  local handle = io.popen(cmd)
  if not handle then
    return nil, "Failed to execute query"
  end
  
  local result = handle:read('*all')
  handle:close()
  
  return result, nil
end

-- Connection Manager
function M.connection_manager()
  local has_telescope, telescope = pcall(require, 'telescope')
  if not has_telescope then
    print("Telescope not found")
    return
  end
  
  load_connections()
  
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local previewers = require('telescope.previewers')
  
  local connection_list = {}
  for name, conn in pairs(M.connections) do
    table.insert(connection_list, {
      name = name,
      url = conn.url,
      description = conn.description or '',
      display = string.format('%s - %s', name, conn.url:gsub('://[^@]*@', '://***@'))
    })
  end
  
  pickers.new({}, {
    prompt_title = 'Database Connections',
    layout_strategy = 'horizontal',
    layout_config = {
      horizontal = {
        prompt_position = 'top',
        preview_width = 0.5,
        results_width = 0.5,
      },
      width = 0.9,
      height = 0.8,
    },
    finder = finders.new_table({
      results = connection_list,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.display,
          ordinal = entry.name .. ' ' .. entry.url,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = 'Connection Details',
      get_buffer_by_name = function(_, entry)
        return entry.value.name
      end,
      define_preview = function(self, entry, status)
        local conn = entry.value
        local lines = {
          '# Connection Details',
          '',
          '**Name:** ' .. conn.name,
          '**URL:** ' .. conn.url,
          '**Description:** ' .. conn.description,
          '',
          '## Connection Test',
          '',
          'Press Enter to connect and browse schema',
          'Press Ctrl+T to test connection',
          'Press Ctrl+E to edit connection',
          'Press Ctrl+D to delete connection',
        }
        
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(self.state.bufnr, 'filetype', 'markdown')
      end,
    }),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          M.current_connection = selection.value
          M.schema_browser()
        end
      end)
      
      -- Test connection
      map('i', '<C-t>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          local result, error = execute_query('SELECT 1 as test', selection.value.url)
          if error then
            print('Connection failed: ' .. error)
          else
            print('Connection successful!')
          end
        end
      end)
      
      -- Edit connection
      map('i', '<C-e>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          actions.close(prompt_bufnr)
          M.edit_connection(selection.value.name)
        end
      end)
      
      -- Delete connection
      map('i', '<C-d>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          local response = vim.fn.input('Delete connection "' .. selection.value.name .. '"? (y/N): ')
          if response:lower() == 'y' then
            M.connections[selection.value.name] = nil
            save_connections()
            actions.close(prompt_bufnr)
            M.connection_manager()
          end
        end
      end)
      
      return true
    end,
  }):find()
end

-- Schema Browser (DataGrip-style)
function M.schema_browser()
  if not M.current_connection then
    print("No connection selected")
    return
  end
  
  local schema = get_schema(M.current_connection.url)
  local result, error = execute_query(schema.query, M.current_connection.url)
  
  if error then
    print("Failed to get schema: " .. error)
    return
  end
  
  -- Parse result to get tables
  local tables = {}
  for line in result:gmatch('[^\r\n]+') do
    if line and not line:match('^%s*$') and not line:match('^[+%-|%s]*$') then
      local parts = {}
      for part in line:gmatch('|%s*([^|]-)%s*') do
        if part and part ~= '' then
          table.insert(parts, vim.trim(part))
        end
      end
      
      if #parts >= 2 and parts[1] ~= 'table_name' then
        table.insert(tables, {
          name = parts[1],
          type = parts[2],
          display = string.format('%s (%s)', parts[1], parts[2])
        })
      end
    end
  end
  
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
  
  pickers.new({}, {
    prompt_title = 'Database Schema - ' .. M.current_connection.name,
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
      results = tables,
      entry_maker = function(entry)
        local icon = entry.type == 'VIEW' and '👁' or '📋'
        return {
          value = entry,
          display = icon .. ' ' .. entry.name,
          ordinal = entry.name,
        }
      end,
    }),
    sorter = conf.generic_sorter({}),
    previewer = previewers.new_buffer_previewer({
      title = 'Table Structure',
      get_buffer_by_name = function(_, entry)
        return entry.value.name
      end,
      define_preview = function(self, entry, status)
        local table_name = entry.value.name
        local schema = get_schema(M.current_connection.url)
        local columns_query = string.format(schema.columns_query, table_name)
        
        local result, error = execute_query(columns_query, M.current_connection.url)
        
        local lines = {
          '# Table: ' .. table_name,
          '',
          '**Type:** ' .. entry.value.type,
          '**Connection:** ' .. M.current_connection.name,
          '',
          '## Columns',
          '',
        }
        
        if error then
          table.insert(lines, 'Error getting columns: ' .. error)
        else
          table.insert(lines, '```sql')
          table.insert(lines, 'Column Name | Data Type | Nullable | Default')
          table.insert(lines, '----------- | --------- | -------- | -------')
          
          for line in result:gmatch('[^\r\n]+') do
            if line and not line:match('^%s*$') and not line:match('^[+%-|%s]*$') then
              local parts = {}
              for part in line:gmatch('|%s*([^|]-)%s*') do
                if part and part ~= '' then
                  table.insert(parts, vim.trim(part))
                end
              end
              
              if #parts >= 3 and parts[1] ~= 'column_name' then
                local col_line = string.format('%s | %s | %s | %s', 
                  parts[1] or '', 
                  parts[2] or '', 
                  parts[3] or '',
                  parts[4] or 'NULL'
                )
                table.insert(lines, col_line)
              end
            end
          end
          
          table.insert(lines, '```')
        end
        
        table.insert(lines, '')
        table.insert(lines, '## Actions')
        table.insert(lines, '')
        table.insert(lines, '- **Enter**: Open query editor for this table')
        table.insert(lines, '- **Ctrl+S**: SELECT * FROM ' .. table_name)
        table.insert(lines, '- **Ctrl+D**: DESCRIBE ' .. table_name)
        table.insert(lines, '- **Ctrl+C**: Copy table name to clipboard')
        
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(self.state.bufnr, 'filetype', 'markdown')
      end,
    }),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          M.query_editor('SELECT * FROM ' .. selection.value.name .. ' LIMIT 100;')
        end
      end)
      
      -- Quick SELECT
      map('i', '<C-s>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          actions.close(prompt_bufnr)
          M.query_editor('SELECT * FROM ' .. selection.value.name .. ' LIMIT 100;')
        end
      end)
      
      -- Describe table
      map('i', '<C-d>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          actions.close(prompt_bufnr)
          M.query_editor('DESCRIBE ' .. selection.value.name .. ';')
        end
      end)
      
      -- Copy table name
      map('i', '<C-c>', function()
        local selection = action_state.get_selected_entry()
        if selection then
          vim.fn.setreg('+', selection.value.name)
          print('Copied table name: ' .. selection.value.name)
        end
      end)
      
      return true
    end,
  }):find()
end

-- Query Editor
function M.query_editor(initial_query)
  if not M.current_connection then
    print("No connection selected")
    return
  end
  
  -- Create new buffer for query
  local bufnr = vim.api.nvim_create_buf(false, true)
  local win_height = math.floor(vim.o.lines * 0.8)
  local win_width = math.floor(vim.o.columns * 0.9)
  
  local win = vim.api.nvim_open_win(bufnr, true, {
    relative = 'editor',
    width = win_width,
    height = win_height,
    col = (vim.o.columns - win_width) / 2,
    row = (vim.o.lines - win_height) / 2,
    style = 'minimal',
    border = 'rounded',
    title = ' DataGrip Query Editor - ' .. M.current_connection.name .. ' ',
    title_pos = 'center',
  })
  
  -- Set initial query
  if initial_query then
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(initial_query, '\n'))
  end
  
  -- Set SQL filetype
  vim.api.nvim_buf_set_option(bufnr, 'filetype', 'sql')
  vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')
  
  -- Keymaps for query editor
  local opts = { buffer = bufnr, silent = true }
  
  -- Execute query
  vim.keymap.set('n', '<F5>', function() M.execute_current_query(bufnr) end, opts)
  vim.keymap.set('n', '<C-Return>', function() M.execute_current_query(bufnr) end, opts)
  
  -- Close editor
  vim.keymap.set('n', 'q', '<cmd>close<cr>', opts)
  vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', opts)
  
  -- Help
  vim.keymap.set('n', '<F1>', function()
    print("Query Editor Help:")
    print("F5 / Ctrl+Enter: Execute query")
    print("q / Esc: Close editor")
    print("Connection: " .. M.current_connection.name)
  end, opts)
  
  print("Query Editor opened. Press F5 to execute, q to close")
end

-- Execute current query
function M.execute_current_query(bufnr)
  if not M.current_connection then
    print("No connection selected")
    return
  end
  
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local query = table.concat(lines, '\n')
  
  if vim.trim(query) == '' then
    print("No query to execute")
    return
  end
  
  print("Executing query...")
  local result, error = execute_query(query, M.current_connection.url)
  
  if error then
    print("Query failed: " .. error)
    return
  end
  
  -- Show results in new buffer
  M.show_query_results(result, query)
end

-- Show query results
function M.show_query_results(result, query)
  local bufnr = vim.api.nvim_create_buf(false, true)
  local win_height = math.floor(vim.o.lines * 0.6)
  local win_width = math.floor(vim.o.columns * 0.9)
  
  local win = vim.api.nvim_open_win(bufnr, true, {
    relative = 'editor',
    width = win_width,
    height = win_height,
    col = (vim.o.columns - win_width) / 2,
    row = vim.o.lines - win_height - 2,
    style = 'minimal',
    border = 'rounded',
    title = ' Query Results ',
    title_pos = 'center',
  })
  
  local result_lines = vim.split(result, '\n')
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, result_lines)
  
  vim.api.nvim_buf_set_option(bufnr, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
  
  -- Close keymaps
  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = bufnr, silent = true })
  vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = bufnr, silent = true })
  
  print("Query executed successfully. Press q to close results.")
end

-- Add new connection
function M.add_connection()
  local name = vim.fn.input('Connection name: ')
  if name == '' then return end
  
  local url = vim.fn.input('Database URL (e.g., mysql://user:pass@host:port/db): ')
  if url == '' then return end
  
  local description = vim.fn.input('Description (optional): ')
  
  load_connections()
  M.connections[name] = {
    url = url,
    description = description
  }
  save_connections()
  
  print('Connection "' .. name .. '" added successfully!')
end

-- Edit connection
function M.edit_connection(name)
  load_connections()
  local conn = M.connections[name]
  if not conn then
    print('Connection not found: ' .. name)
    return
  end
  
  local new_url = vim.fn.input('Database URL: ', conn.url)
  if new_url == '' then return end
  
  local new_description = vim.fn.input('Description: ', conn.description or '')
  
  M.connections[name] = {
    url = new_url,
    description = new_description
  }
  save_connections()
  
  print('Connection "' .. name .. '" updated successfully!')
end

-- Setup function
function M.setup()
  load_connections()
  
  -- Commands
  vim.api.nvim_create_user_command('DataGrip', M.connection_manager, { desc = 'Open DataGrip-style database browser' })
  vim.api.nvim_create_user_command('DataGripAdd', M.add_connection, { desc = 'Add new database connection' })
  vim.api.nvim_create_user_command('DataGripQuery', function() M.query_editor() end, { desc = 'Open query editor' })
  
  print("DataGrip-style database browser ready!")
end

return M