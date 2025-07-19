return {
  'stevearc/aerial.nvim',
  opts = {},
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons"
  },
  config = function()
    require("aerial").setup({
      -- Priority list of preferred backends for aerial.
      -- This can be a filetype map (see :help aerial-filetype-map)
      backends = { "lsp", "treesitter", "markdown", "asciidoc", "man" },

      layout = {
        -- These control the width of the aerial window.
        -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        -- min_width and max_width can be a list of mixed types.
        -- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
        max_width = { 40, 0.2 },
        width = nil,
        min_width = 10,

        -- key-value pairs of window-local options for aerial window (e.g. winhl)
        win_opts = {},

        -- Determines the default direction to open the aerial window. The 'prefer'
        -- options will open the window in the other direction *if* there is a
        -- different buffer in the way of the preferred direction
        -- Enum: prefer_right, prefer_left, right, left, float
        default_direction = "prefer_right",

        -- Determines where the aerial window will be opened
        -- Enum: edge, group, window
        --   edge   - open aerial at the far right/left of the editor
        --   group  - open aerial to the right/left of the group of windows containing the current buffer
        --   window - open aerial to the right/left of the current window
        placement = "window",

        -- When the symbols change, resize the aerial window (within min/max constraints) to fit
        resize_to_content = true,

        -- Preserve window size equality with (:help CTRL-W_=)
        preserve_equality = false,
      },

      -- Determines how the aerial window decides which buffer to display symbols for
      -- Enum: global, prefer-right, prefer-left, current, none
      --   global      - The aerial window displays symbols for the buffer in the active window
      --   prefer-right- The aerial window displays symbols for the buffer in the rightmost window
      --   prefer-left - The aerial window displays symbols for the buffer in the leftmost window
      --   current     - The aerial window displays symbols for the current buffer
      --   none        - The aerial window does not automatically switch buffers
      attach_mode = "window",

      -- List of enum values that configure when to auto-close the aerial window
      --   unfocus       - close aerial when you leave the original source window
      --   switch_buffer - close aerial when you change buffers in the source window
      --   unsupported   - close aerial when attaching to a buffer that doesn't have symbols
      close_automatic_events = {},

      -- Keymaps in aerial window. Can be any value that `vim.keymap.set` accepts OR a table of keymap
      -- options with a `callback` (e.g. { callback = function() ... end, desc = "", nowait = true })
      -- Additionally, if it is a string that matches "actions.<name>",
      -- it will use the mapping at require("aerial.actions").<name>
      -- Set to `false` to remove a keymap
      keymaps = {
        ["?"] = "actions.show_help",
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.jump",
        ["<2-LeftMouse>"] = "actions.jump",
        ["<C-v>"] = "actions.jump_vsplit",
        ["<C-s>"] = "actions.jump_split",
        ["p"] = "actions.scroll",
        ["<C-j>"] = "actions.down_and_scroll",
        ["<C-k>"] = "actions.up_and_scroll",
        ["{"] = "actions.prev",
        ["}"] = "actions.next",
        ["[["] = "actions.prev_up",
        ["]]"] = "actions.next_up",
        ["q"] = "actions.close",
        ["o"] = "actions.tree_toggle",
        ["za"] = "actions.tree_toggle",
        ["O"] = "actions.tree_toggle_recursive",
        ["zA"] = "actions.tree_toggle_recursive",
        ["l"] = "actions.tree_open",
        ["zo"] = "actions.tree_open",
        ["L"] = "actions.tree_open_recursive",
        ["zO"] = "actions.tree_open_recursive",
        ["h"] = "actions.tree_close",
        ["zc"] = "actions.tree_close",
        ["H"] = "actions.tree_close_recursive",
        ["zC"] = "actions.tree_close_recursive",
        ["zr"] = "actions.tree_increase_fold_level",
        ["zR"] = "actions.tree_open_all",
        ["zm"] = "actions.tree_decrease_fold_level",
        ["zM"] = "actions.tree_close_all",
        ["zx"] = "actions.tree_sync_folds",
        ["zX"] = "actions.tree_sync_folds",
      },

      -- When true, don't load aerial until a command is run or function is called
      -- Defaults to true, unless `on_attach` is provided, then it defaults to false
      lazy_load = true,

      -- Disable aerial on files with this many lines
      disable_max_lines = 10000,

      -- Disable aerial on files this size or larger (in bytes)
      disable_max_size = 2000000, -- Default 2MB

      -- A list of all symbols to display. Set to false to display all symbols.
      -- This can be a filetype map (see :help aerial-filetype-map)
      -- To see all available values, see :help SymbolKind
      filter_kind = {
        "Class",
        "Constructor",
        "Enum",
        "Function",
        "Interface",
        "Module",
        "Method",
        "Struct",
      },

      -- Determines line highlighting mode when multiple splits are visible.
      -- split_width   Each open window will have its cursor location marked in the
      --               aerial buffer. Each line will only be partially highlighted
      --               to indicate which window is at that location.
      -- full_width    Each open window will have its cursor location marked as a
      --               full-width highlight in the aerial buffer.
      -- last          Only the most-recently focused window will have its location
      --               marked in the aerial buffer.
      -- none          Do not show the cursor location in the aerial window.
      highlight_mode = "split_width",

      -- Highlight the closest symbol if the cursor is not exactly on one.
      highlight_closest = true,

      -- Highlight the symbol in the source buffer when cursor is in the aerial win
      highlight_on_hover = false,

      -- When jumping to a symbol, highlight the line for this many ms.
      -- Set to false to disable
      highlight_on_jump = 300,

      -- Options for opening aerial in a floating win
      float = {
        -- Controls border appearance. Passed to nvim_open_win
        border = "rounded",

        -- Determines location of floating window
        -- center      - opens float in center of editor
        -- cursor      - opens float near cursor
        -- editor      - opens float centered in editor, sized relative to editor
        -- win         - opens float centered in window, sized relative to window
        relative = "cursor",

        -- These control the height of the floating window.
        -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
        -- min_height and max_height can be a list of mixed types.
        -- min_height = {8, 0.1} means "the greater of 8 rows or 10% of total"
        max_height = 0.9,
        height = nil,
        min_height = { 8, 0.1 },

        override = function(conf, source_winid)
          -- This is the config that will be passed to nvim_open_win.
          -- Change values here to customize the layout
          return conf
        end,
      },

      lsp = {
        -- Fetch document symbols when LSP diagnostics update.
        -- If false, will update on buffer changes.
        diagnostics_trigger_update = true,

        -- Set to false to not update the symbols when there are LSP errors
        update_when_errors = true,

        -- How long to wait (in ms) after a buffer change before updating
        -- Only applies when diagnostics_trigger_update = false
        update_delay = 300,

        -- Map of LSP client name to priority. Default value is 10.
        -- Clients with higher (larger) priority will be used before those with lower priority.
        -- Set to false to disable the client.
        priority = {
          -- pyright = 10,
        },
      },

      treesitter = {
        -- How long to wait (in ms) after a buffer change before updating
        update_delay = 300,
      },

      markdown = {
        -- How long to wait (in ms) after a buffer change before updating
        update_delay = 300,
      },

      asciidoc = {
        -- How long to wait (in ms) after a buffer change before updating
        update_delay = 300,
      },

      man = {
        -- How long to wait (in ms) after a buffer change before updating
        update_delay = 300,
      },
    })

    -- You probably also want to set a keymap to toggle aerial
    vim.keymap.set("n", "<leader>o", "<cmd>AerialToggle!<CR>", { desc = "Toggle Aerial outline" })
    vim.keymap.set("n", "<leader>O", "<cmd>AerialNavToggle<CR>", { desc = "Toggle Aerial nav" })
    vim.keymap.set("n", "<leader>oo", "<cmd>AerialOpen<CR>", { desc = "Open Aerial outline" })
    vim.keymap.set("n", "<leader>oc", "<cmd>AerialClose<CR>", { desc = "Close Aerial outline" })
    vim.keymap.set("n", "<leader>of", "<cmd>AerialFocus<CR>", { desc = "Focus Aerial outline" })
    vim.keymap.set("n", "<leader>ot", "<cmd>Telescope aerial<CR>", { desc = "Telescope Aerial symbols" })
    
    -- Navigate between symbols
    vim.keymap.set("n", "<leader>[", "<cmd>AerialPrev<CR>", { desc = "Previous symbol" })
    vim.keymap.set("n", "<leader>]", "<cmd>AerialNext<CR>", { desc = "Next symbol" })
    vim.keymap.set("n", "<leader>[[", "<cmd>AerialPrevUp<CR>", { desc = "Previous symbol (up level)" })
    vim.keymap.set("n", "<leader>]]", "<cmd>AerialNextUp<CR>", { desc = "Next symbol (up level)" })
  end,
  
  -- Call the setup function to change the default behavior
  keys = {
    { "<leader>o", "<cmd>AerialToggle!<CR>", desc = "Toggle Aerial outline" },
    { "<leader>O", "<cmd>AerialNavToggle<CR>", desc = "Toggle Aerial nav" },
    { "<leader>oo", "<cmd>AerialOpen<CR>", desc = "Open Aerial outline" },
    { "<leader>oc", "<cmd>AerialClose<CR>", desc = "Close Aerial outline" },
    { "<leader>of", "<cmd>AerialFocus<CR>", desc = "Focus Aerial outline" },
    { "<leader>ot", "<cmd>Telescope aerial<CR>", desc = "Telescope Aerial symbols" },
    { "<leader>[", "<cmd>AerialPrev<CR>", desc = "Previous symbol" },
    { "<leader>]", "<cmd>AerialNext<CR>", desc = "Next symbol" },
    { "<leader>[[", "<cmd>AerialPrevUp<CR>", desc = "Previous symbol (up level)" },
    { "<leader>]]", "<cmd>AerialNextUp<CR>", desc = "Next symbol (up level)" },
  }
}