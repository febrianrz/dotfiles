-- Laravel Tinker for Neovim
-- Provides functionality to create, edit and run Laravel Tinker commands from a file

local M = {}

-- Function to set up Laravel Tinker functionality
function M.setup()
  -- Open or create .tinker.php file
  vim.keymap.set('n', '<leader>tw', function()
    local tinker_path = vim.fn.getcwd() .. '/.tinker.php'
    if vim.fn.filereadable(tinker_path) == 0 then
      vim.fn.writefile({
        '<?php',
        '',
        '// Laravel Tinker playground',
        '// Write PHP code below',
        '',
      }, tinker_path)
    end

    -- Check .gitignore and add .tinker.php if not present
    local gitignore_path = vim.fn.getcwd() .. '/.gitignore'
    local gitignore_exists = vim.fn.filereadable(gitignore_path) == 1

    if gitignore_exists then
      local gitignore_content = vim.fn.readfile(gitignore_path)
      local tinker_ignored = false

      -- Check if .tinker.php is already in .gitignore
      for _, line in ipairs(gitignore_content) do
        if line == '.tinker.php' then
          tinker_ignored = true
          vim.notify('.tinker.php already in .gitignore', vim.log.levels.INFO, { title = 'Laravel Tinker' })
          break
        end
      end

      -- Add .tinker.php to .gitignore if not present
      if not tinker_ignored then
        table.insert(gitignore_content, '.tinker.php')
        vim.fn.writefile(gitignore_content, gitignore_path)
        print '.tinker.php added to .gitignore'
      end
    else
      -- Create .gitignore if it doesn't exist
      vim.fn.writefile({ '.tinker.php' }, gitignore_path)
      print '.gitignore created with .tinker.php'
      vim.notify('Created .gitignore with .tinker.php', vim.log.levels.INFO, { title = 'Laravel Tinker' })
    end

    vim.cmd('edit ' .. tinker_path)
  end, { noremap = true, silent = true, desc = 'Open .tinker.php' })

  -- Run .tinker.php in Laravel Tinker
  vim.keymap.set('n', '<leader>tr', function()
    local original_path = vim.fn.getcwd() .. '/.tinker.php'

    local cmd = 'php artisan tinker --execute="require \'' .. original_path .. '\'"'

    -- Eksekusi perintah Tinker dalam terminal
    local Terminal = require('toggleterm.terminal').Terminal
    local tinker_term = Terminal:new {
      cmd = cmd,
      hidden = true,
      direction = 'float',
      close_on_exit = false,
      on_exit = function()
        vim.notify('Laravel Tinker has been closed', vim.log.levels.INFO)
      end,
    }

    -- Toggle terminal
    tinker_term:toggle()
    vim.notify('Menjalankan Laravel Tinker...', vim.log.levels.INFO)
  end, { noremap = true, silent = true, desc = 'Run .tinker.php in Laravel Tinker, ignore <?php using temporary file' })
end

return M
