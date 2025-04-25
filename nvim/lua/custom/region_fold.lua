-- lua/custom/region_fold.lua

local M = {}

function M.region_fold_expr(lnum)
  local line = vim.fn.getline(lnum)
  if line:match '^%s*//region' then
    return 'a1'
  elseif line:match '^%s*//endregion' then
    return 's1'
  else
    return '='
  end
end

return M
