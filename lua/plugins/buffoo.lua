local M = {}

function M.setup()
  if M.loaded then return end
  M.loaded = true

  local buffoo = require('buffoo')
  buffoo.setup()

  vim.keymap.set('', '<Leader>w', function() buffoo.close() end, { desc = 'Quit buffer (buffoo)' })
  vim.keymap.set('', '<Leader>W', function() buffoo.close({ force = true }) end, { desc = 'Quit buffer w/o confirmation (buffoo)' })
  vim.keymap.set({ '', 'i' }, '<C-h>', function() buffoo.switch(vim.api.nvim_get_current_buf(), -1, { cycle = true }) end, { desc = 'Switch buffer left (buffoo)' })
  vim.keymap.set({ '', 'i' }, '<C-l>', function() buffoo.switch(vim.api.nvim_get_current_buf(), 1, { cycle = true }) end, { desc = 'Switch buffer right (buffoo)' })
end

return M
