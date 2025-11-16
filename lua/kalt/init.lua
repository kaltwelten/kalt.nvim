local M = {}

function M.setup()
  if M.loaded then return end
  M.loaded = true

  require('kalt.config')
end

return M
