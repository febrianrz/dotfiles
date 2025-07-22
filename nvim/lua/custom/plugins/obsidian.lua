return {
  "epwalsh/obsidian.nvim",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    -- Simple setup with safe error handling
    local success, obsidian = pcall(require, "obsidian")
    if not success then
      vim.notify("❌ Failed to load obsidian.nvim", vim.log.levels.ERROR)
      return
    end
    
    -- No need to create directories - using existing Obsidian vaults
    
    local setup_ok, err = pcall(obsidian.setup, {
      workspaces = {
        {
          name = "main",
          path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian",
        },
        {
          name = "work", 
          path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Work",
        },
        {
          name = "nextcloud",
          path = "~/Nextcloud2/Project Doc/Obsidian",
        },
        {
          name = "amazing",
          path = "~/Nextcloud2/Project Doc/Obsidian/Amazing",
        },
        {
          name = "project",
          path = "~/Nextcloud2/Project Doc/Obsidian/Amazing/Project",
        },
      },

      notes_subdir = nil, -- Don't force a subdirectory, use vault root
      log_level = vim.log.levels.INFO,

      daily_notes = {
        folder = "dailies",
        date_format = "%Y-%m-%d",
        alias_format = "%B %-d, %Y",
        default_tags = { "daily-notes" },
        template = nil
      },

      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },

      mappings = {
        ["gf"] = {
          action = function()
            return require("obsidian").util.gf_passthrough()
          end,
          opts = { noremap = false, expr = true, buffer = true },
        },
        ["<leader>ch"] = {
          action = function()
            return require("obsidian").util.toggle_checkbox()
          end,
          opts = { buffer = true },
        },
        ["<cr>"] = {
          action = function()
            return require("obsidian").util.smart_action()
          end,
          opts = { buffer = true, expr = true },
        }
      },

      new_notes_location = "notes_subdir",

      note_id_func = function(title)
        local suffix = ""
        if title ~= nil then
          suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
        else
          for _ = 1, 4 do
            suffix = suffix .. string.char(math.random(65, 90))
          end
        end
        return tostring(os.time()) .. "-" .. suffix
      end,

      note_path_func = function(spec)
        local path = spec.dir / tostring(spec.id)
        return path:with_suffix(".md")
      end,

      wiki_link_func = "use_alias_only",
      preferred_link_style = "wiki",
      disable_frontmatter = false,

      templates = {
        folder = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
        substitutions = {},
      },

      follow_url_func = function(url)
        vim.fn.jobstart({"open", url})  -- Mac
      end,

      use_advanced_uri = false,
      open_app_foreground = false,
      finder = "telescope.nvim",
      sort_by = "modified",
      sort_reversed = true,
      open_notes_in = "current",

      ui = {
        enable = true,
        update_debounce = 200,
        max_file_length = 5000,
        checkboxes = {
          [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
          ["x"] = { char = "", hl_group = "ObsidianDone" },
          [">"] = { char = "", hl_group = "ObsidianRightArrow" },
          ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
          ["!"] = { char = "", hl_group = "ObsidianImportant" },
        },
        bullets = { char = "•", hl_group = "ObsidianBullet" },
        external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
        reference_text = { hl_group = "ObsidianRefText" },
        highlight_text = { hl_group = "ObsidianHighlightText" },
        tags = { hl_group = "ObsidianTag" },
        block_ids = { hl_group = "ObsidianBlockID" },
        hl_groups = {
          ObsidianTodo = { bold = true, fg = "#f78c6c" },
          ObsidianDone = { bold = true, fg = "#89ddff" },
          ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
          ObsidianTilde = { bold = true, fg = "#ff5370" },
          ObsidianImportant = { bold = true, fg = "#d73128" },
          ObsidianBullet = { bold = true, fg = "#89ddff" },
          ObsidianRefText = { underline = true, fg = "#c792ea" },
          ObsidianExtLinkIcon = { fg = "#c792ea" },
          ObsidianTag = { italic = true, fg = "#89ddff" },
          ObsidianBlockID = { italic = true, fg = "#89ddff" },
          ObsidianHighlightText = { bg = "#75662e" },
        },
      },

      attachments = {
        img_folder = "assets/imgs",
        img_text_func = function(client, path)
          path = client:vault_relative_path(path) or path
          return string.format("![%s](%s)", path.name, path)
        end,
      },
    })

    if not setup_ok then
      vim.notify("❌ Obsidian setup failed: " .. tostring(err), vim.log.levels.ERROR)
      return
    end

    
    -- Set conceallevel for Obsidian UI features
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function()
        vim.opt_local.conceallevel = 2
        vim.opt_local.concealcursor = 'nv'
      end,
    })

    -- Basic keymaps
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
    end

    -- Use <leader>m (memo/markdown) prefix to avoid conflicts with aerial
    map("n", "<leader>mo", "<cmd>ObsidianOpen<cr>", "Open in Obsidian")
    map("n", "<leader>mn", "<cmd>ObsidianNew<cr>", "New Obsidian note")
    map("n", "<leader>mq", "<cmd>ObsidianQuickSwitch<cr>", "Quick switch notes")
    map("n", "<leader>mf", "<cmd>ObsidianFollowLink<cr>", "Follow link")
    map("n", "<leader>mb", "<cmd>ObsidianBacklinks<cr>", "Show backlinks")
    map("n", "<leader>ms", "<cmd>ObsidianSearch<cr>", "Search notes")
    map("n", "<leader>md", "<cmd>ObsidianToday<cr>", "Open today's daily note")
    map("n", "<leader>my", "<cmd>ObsidianYesterday<cr>", "Open yesterday's daily note")
    map("n", "<leader>mt", "<cmd>ObsidianTemplate<cr>", "Insert template")
    map("n", "<leader>mp", "<cmd>ObsidianPasteImg<cr>", "Paste image")
    map("n", "<leader>mr", "<cmd>ObsidianRename<cr>", "Rename note")
    map("n", "<leader>mw", "<cmd>ObsidianWorkspace<cr>", "Switch workspace")
    
    -- Keep some common ones under <leader>o for convenience
    map("n", "<leader>on", "<cmd>ObsidianNew<cr>", "New Obsidian note")
    map("n", "<leader>os", "<cmd>ObsidianSearch<cr>", "Search notes")
    map("n", "<leader>od", "<cmd>ObsidianToday<cr>", "Open today's daily note")

    -- Test command
    vim.api.nvim_create_user_command("ObsidianTest", function()
      local client = obsidian.get_client()
      if client then
        vim.notify("✅ Obsidian client is working!", vim.log.levels.INFO)
      else
        vim.notify("❌ Obsidian client not found", vim.log.levels.ERROR)
      end
    end, { desc = "Test Obsidian integration" })
    
    -- List available workspaces
    vim.api.nvim_create_user_command("ObsidianWorkspaces", function()
      local client = obsidian.get_client()
      if client then
        local workspaces = client.opts.workspaces
        local workspace_list = "📁 Available Obsidian Workspaces:\n"
        for _, ws in ipairs(workspaces) do
          local current = client.current_workspace and ws.name == client.current_workspace.name and " (current)" or ""
          workspace_list = workspace_list .. string.format("• %s: %s%s\n", ws.name, ws.path, current)
        end
        vim.notify(workspace_list, vim.log.levels.INFO, { title = "Obsidian Workspaces" })
      else
        vim.notify("❌ Obsidian client not found", vim.log.levels.ERROR)
      end
    end, { desc = "List Obsidian workspaces" })
    
    -- Quick switch to specific workspace
    map("n", "<leader>mws", "<cmd>ObsidianWorkspaces<cr>", "List workspaces")
    map("n", "<leader>mww", "<cmd>ObsidianWorkspace<cr>", "Switch workspace")
    
    -- Toggle conceallevel for markdown files
    vim.api.nvim_create_user_command("ObsidianToggleConceal", function()
      if vim.bo.filetype == "markdown" then
        if vim.opt_local.conceallevel:get() == 0 then
          vim.opt_local.conceallevel = 2
          vim.notify("✅ Obsidian UI features enabled (conceallevel=2)", vim.log.levels.INFO)
        else
          vim.opt_local.conceallevel = 0
          vim.notify("📝 Raw markdown view (conceallevel=0)", vim.log.levels.INFO)
        end
      else
        vim.notify("❌ Not a markdown file", vim.log.levels.WARN)
      end
    end, { desc = "Toggle Obsidian conceallevel" })
    
    map("n", "<leader>mc", "<cmd>ObsidianToggleConceal<cr>", "Toggle conceallevel")

  end,
}