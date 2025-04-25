local M = {}

local required_formatters = {
  prettier = "Prettier (JS, TSX, HTML)",
  stylua = "Stylua (Lua)",
  ["php-cs-fixer"] = "PHP CS Fixer",
  gofmt = "Gofmt (Go)",
  shfmt = "Shfmt (Shell)",
}

function M.check()
  for bin, label in pairs(required_formatters) do
    if vim.fn.executable(bin) == 0 then
      vim.notify(
        ("[Formatter Missing] %s (%s) not found in PATH"):format(bin, label),
        vim.log.levels.WARN,
        { title = "Formatter Check" }
      )
    end
  end
end

return M

