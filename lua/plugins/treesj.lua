local M = {}

M.sources = { { src = 'https://github.com/Wansmer/treesj' } }

function M.setup()
  if M.loaded then return end
  M.loaded = true

  require('treesj').setup({ use_default_keymaps = false })

  vim.keymap.set('', 'gs', function() require('treesj').toggle() end, { desc = 'Split/join (treesj)' })
  vim.keymap.set('', 'gS', function() require('treesj').toggle({ split = { recursive = true } }) end, { desc = 'Split/join recursively (treesj)' })
end

return M
