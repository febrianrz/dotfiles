local M = {}

function M.clean()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local use_lines = {} -- { line_number = "ClassName" }
  local cleaned_lines = vim.deepcopy(lines)

  -- Step 1: cari semua baris `use`
  for i, line in ipairs(lines) do
    local class_path = line:match '^%s*use%s+([%w_\\]+);'
    if class_path then
      local class_name = class_path:match '([%w_]+)$'
      if class_name then
        use_lines[i] = class_name
      end
    end
  end

  -- Step 2: cek pemakaian class dari baris selain baris `use`
  for line_num, class_name in pairs(use_lines) do
    local is_used = false
    for i, line in ipairs(lines) do
      if i ~= line_num and line:match('%f[%w_]' .. class_name .. '%f[^%w_]') then
        is_used = true
        break
      end
    end

    if not is_used then
      cleaned_lines[line_num] = nil
    end
  end

  -- Step 3: apply hasil
  local new_lines = vim.tbl_filter(function(line)
    return line ~= nil
  end, cleaned_lines)

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, new_lines)
  vim.notify('✅ Unused `use` statements removed', vim.log.levels.INFO)
end

return M
