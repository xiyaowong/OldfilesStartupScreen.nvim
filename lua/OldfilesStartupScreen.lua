local api = vim.api
local fn = vim.fn

local M = {}

local oldfiles = { "Create New File" }
local win
local buf

M.display = function()
  if fn.argc() > 0 or #vim.v.oldfiles == 1 then
    return
  end

  for _, file in pairs(vim.v.oldfiles) do
    if vim.loop.fs_stat(file) then
      table.insert(oldfiles, file)
    end
  end

  if #oldfiles == 1 then
    return
  end

  -- TODO: icon
  local lines = oldfiles

  buf = api.nvim_create_buf(true, true)
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  for name, val in pairs({ filetype = "OldfilesStartupScreen", modifiable = false, buflisted = false }) do
    vim.bo[buf][name] = val
  end

  for _, key in ipairs({ "q", "o", "s", "v"}) do
    api.nvim_buf_set_keymap(
      buf,
      "n",
      key,
      string.format([[:lua require("OldfilesStartupScreen").do_map('%s')<cr>)]], key),
      { noremap = true, silent = true }
    )
  end

  win = api.nvim_get_current_win()
  vim.wo[win].colorcolumn = ""
  vim.wo[win].signcolumn = "no"
  api.nvim_win_set_buf(win, buf)
end

M.do_map = function(key)
  local target = oldfiles[fn.getpos(".")[2]]

  if key == "q" then
    vim.cmd('quit')
  elseif target == "Create New File" then
    vim.cmd("enew")
  elseif key == "o" then
    vim.cmd("edit " .. target)
  elseif key == "s" then
    vim.cmd("split " .. target)
  elseif key == "v" then
    vim.cmd("vsplit " .. target)
  end
end

M.delete_buf = function()
  if api.nvim_buf_is_valid(buf) and api.nvim_win_is_valid(win) then
    if api.nvim_win_get_buf(win) ~= buf then
      api.nvim_buf_delete(buf, {})
      vim.cmd([[augroup OldfilesStartupScreen | autocmd! | augroup END]])
    end
  end
end

return M
