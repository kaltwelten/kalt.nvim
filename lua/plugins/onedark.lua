local M = {}

M.sources = { { src = 'https://github.com/navarasu/onedark.nvim' } }

function M.setup()
  if M.loaded then return end
  M.loaded = true

  require('onedark').setup({ style = 'warm' })
  require('onedark').load()
end

return M
