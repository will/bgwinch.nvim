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
  if vim.fn.has "mac" == 1 then
    local j = Job:new { command = "defaults", args = { "read", "-g", "AppleInterfaceStyle" } }
    j:sync()
    vim.o.background = j:result()[1] == "Dark" and "dark" or "light"
  elseif vim.fn.executable "dbus-send" == 1 then
    local j = Job:new {
      command = "dbus-send",
      args = {
        "--session",
        "--print-reply=literal",
        "--reply-timeout=1000",
        "--dest=org.freedesktop.portal.Desktop",
        "/org/freedesktop/portal/desktop",
        "org.freedesktop.portal.Settings.Read",
        "string:org.freedesktop.appearance",
        "string:color-scheme",
      },
    }
    j:sync()
    local result = table.concat(j:result(), " ")

    -- Parse dbus response: uint32 1 = dark, uint32 0/2 = light
    if string.match(result, "uint32 1") then
      vim.o.background = "dark"
    else
      vim.o.background = "light"
    end
  else
    vim.notify("dbus-send not found, cannot detect system theme", vim.log.levels.WARN)
  end
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
  group = nil
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
  params = params or {}

  if params.set_bg then
    M.set_bg = params.set_bg
  end

  M.enable()
end

return M
