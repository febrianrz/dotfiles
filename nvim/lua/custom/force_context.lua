-- Force enable treesitter-context permanently
-- This file ensures treesitter-context is ALWAYS enabled

local M = {}

M.force_enable = function()
  local context = require('treesitter-context')
  
  -- Set global flag
  vim.g.treesitter_context_forced = true
  
  -- Enable immediately
  context.enable()
  
  -- Create persistent autocmd
  vim.api.nvim_create_autocmd({"BufEnter", "TabEnter", "WinEnter", "VimEnter"}, {
    group = vim.api.nvim_create_augroup("ForceTreesitterContext", { clear = true }),
    callback = function()
      if vim.g.treesitter_context_forced then
        local success, ctx = pcall(require, 'treesitter-context')
        if success and not ctx.enabled() then
          ctx.enable()
        end
      end
    end,
  })
  
  -- Create timer to check every 2 seconds
  local timer = vim.loop.new_timer()
  timer:start(0, 2000, vim.schedule_wrap(function()
    if vim.g.treesitter_context_forced then
      local success, ctx = pcall(require, 'treesitter-context')
      if success and not ctx.enabled() then
        ctx.enable()
      end
    end
  end))
  
  vim.notify("🚀 Treesitter context PERMANENTLY ENABLED!", vim.log.levels.INFO)
end

-- Auto-run on require
M.force_enable()

return M