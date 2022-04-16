M = {}
local group

M.debounce = function(ms, fn)
  local running = false
  return function()
    if running then
      return
    end
    vim.defer_fn(function()
      running = false
    end, ms)
    running = true
    vim.schedule(fn)
  end
end

local Job = require "plenary.job"
M.set_bg = function()
  local j = Job:new { command = "defaults", args = { "read", "-g", "AppleInterfaceStyle" } }
  j:sync()
  vim.o.background = j:result()[1] == "Dark" and "dark" or "light"
end

M.enable = function()
  group = vim.api.nvim_create_augroup("BackgroundWatch", { clear = true })
  vim.api.nvim_create_autocmd("Signal", {
    pattern = "SIGWINCH",
    callback = M.debounce(500, M.set_bg),
    group = group,
  })
end

M.disable = function()
  if not group then
    return
  end
  vim.api.nvim_del_augroup_by_id(group)
end

M.toggle_bg = function()
  vim.o.bg = (vim.o.bg == "dark") and "light" or "dark"
end

M.disable_and_toggle_bg = function()
  M.disable()
  M.toggle_bg()
end

M.reenable = function()
  M.enable()
  M.set_bg()
end

M.setup = function(params)
  if params.set_bg then
    M.set_bg = params.set_bg
  end

  M.enable()
end

return M
