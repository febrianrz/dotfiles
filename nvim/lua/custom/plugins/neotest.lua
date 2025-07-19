return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    -- Test adapters
    'V13Axel/neotest-pest',
    'olimorris/neotest-phpunit',
  },
  config = function()
    require('neotest').setup({
      adapters = {
        require('neotest-pest')({
          pest_cmd = function()
            -- Check if pest is available in vendor/bin first
            if vim.fn.filereadable('./vendor/bin/pest') == 1 then
              return './vendor/bin/pest'
            end
            -- Fallback to global pest
            return 'pest'
          end,
          sail_enabled = function()
            return vim.fn.filereadable('./vendor/bin/sail') == 1
          end,
          sail_executable = './vendor/bin/sail',
          parallel = true,
          compact = false,
        }),
        require('neotest-phpunit')({
          phpunit_cmd = function()
            -- Check if phpunit is available in vendor/bin first
            if vim.fn.filereadable('./vendor/bin/phpunit') == 1 then
              return './vendor/bin/phpunit'
            end
            -- Fallback to global phpunit
            return 'phpunit'
          end,
          sail_enabled = function()
            return vim.fn.filereadable('./vendor/bin/sail') == 1
          end,
          sail_executable = './vendor/bin/sail',
        }),
      },
      discovery = {
        enabled = true,
        concurrent = 1,
      },
      running = {
        concurrent = true,
      },
      summary = {
        animated = true,
        enabled = true,
        expand_errors = true,
        follow = true,
        mappings = {
          attach = 'a',
          clear_marked = 'M',
          clear_target = 'T',
          debug = 'd',
          debug_marked = 'D',
          expand = { '<CR>', '<2-LeftMouse>' },
          expand_all = 'e',
          jumpto = 'i',
          mark = 'm',
          next_failed = 'J',
          output = 'o',
          prev_failed = 'K',
          run = 'r',
          run_marked = 'R',
          short = 'O',
          stop = 'u',
          target = 't',
          watch = 'w',
        },
      },
      output = {
        enabled = true,
        open_on_run = 'short',
      },
      output_panel = {
        enabled = true,
        open = 'botright split | resize 15',
      },
      quickfix = {
        enabled = true,
        open = false,
      },
      status = {
        enabled = true,
        signs = true,
        virtual_text = false,
      },
      strategies = {
        integrated = {
          height = 40,
          width = 120,
        },
      },
      icons = {
        child_indent = '│',
        child_prefix = '├',
        collapsed = '─',
        expanded = '╮',
        failed = '✖',
        final_child_indent = ' ',
        final_child_prefix = '╰',
        non_collapsible = '─',
        passed = '✓',
        running = '󰑮',
        running_animated = { '/', '|', '\\', '-', '/', '|', '\\', '-' },
        skipped = '○',
        unknown = '?',
      },
    })
  end,
  keys = {
    {
      '<leader>tt',
      function()
        require('neotest').run.run()
      end,
      desc = '[T]est [T]est - Run nearest test',
    },
    {
      '<leader>tf',
      function()
        require('neotest').run.run(vim.fn.expand('%'))
      end,
      desc = '[T]est [F]ile - Run current file tests',
    },
    {
      '<leader>ta',
      function()
        require('neotest').run.run(vim.fn.getcwd())
      end,
      desc = '[T]est [A]ll - Run all tests',
    },
    {
      '<leader>ts',
      function()
        require('neotest').summary.toggle()
      end,
      desc = '[T]est [S]ummary - Toggle test summary',
    },
    {
      '<leader>to',
      function()
        require('neotest').output.open({ enter = true, auto_close = true })
      end,
      desc = '[T]est [O]utput - Show test output',
    },
    {
      '<leader>tO',
      function()
        require('neotest').output_panel.toggle()
      end,
      desc = '[T]est [O]utput Panel - Toggle output panel',
    },
    {
      '<leader>td',
      function()
        require('neotest').run.run({ strategy = 'dap' })
      end,
      desc = '[T]est [D]ebug - Debug nearest test',
    },
    {
      '<leader>tS',
      function()
        require('neotest').run.stop()
      end,
      desc = '[T]est [S]top - Stop running tests',
    },
    {
      '<leader>tw',
      function()
        require('neotest').watch.toggle(vim.fn.expand('%'))
      end,
      desc = '[T]est [W]atch - Watch current file',
    },
  },
}